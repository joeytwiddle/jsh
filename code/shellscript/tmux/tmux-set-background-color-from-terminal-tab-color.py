#!/usr/bin/env python3
"""tmux-set-background-color-from-terminal-tab-color: tint a tmux session's status bar to match its terminal tab.

If the session was started from a terminal tab that has a tab colour, set the session's
status-bg to that colour at half brightness. Supported terminals: iTerm2 and KDE Konsole.
Exits 1 when no colour was found (not a supported terminal, no tab colour, API unavailable),
so a caller can fall back to something else.

Usage:
  tmux-set-background-color-from-terminal-tab-color [-v] [-n] [-f] [SESSION]

  SESSION   tmux target session (default: the current one)
  -v        explain what happened, on stderr
  -n        dry run: report the colour but do not set it
  -f        full brightness: use the tab colour as it is, without darkening it

Wired up in .tmux.conf with a session-created hook. The tab is found from variables in the
session's own environment (recorded via tmux's update-environment): ITERM_SESSION_ID for
iTerm2, KONSOLE_DBUS_SERVICE and KONSOLE_DBUS_SESSION for Konsole. For iTerm2 it can also
fall back to the tty of the client attached to the session, so older sessions can be run on by hand too.

iTerm2 needs the `iterm2` Python package. If the running python3 lacks it, this re-runs itself
under a private venv at ~/.cache/tmux-iterm-tab-color/venv when that exists.
Konsole needs qdbus6, qdbus or gdbus.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys

NAME = "tmux-set-background-color-from-terminal-tab-color"
VENV_PYTHON = os.path.expanduser("~/.cache/tmux-iterm-tab-color/venv/bin/python")
REEXEC_FLAG = "TMUX_ITERM_TAB_COLOR_REEXEC"
BRIGHTNESS = 0.5


def main():
	args = parse_args()
	say = (lambda msg: print(f"{NAME}: {msg}", file=sys.stderr)) if args.verbose else (lambda msg: None)

	rgb = konsole_tab_rgb(args.session, say) or iterm_tab_rgb(args.session, say)
	if rgb is None:
		return 1

	brightness = 1.0 if args.full else BRIGHTNESS
	dimmed = tuple(round(c * brightness) for c in rgb)
	colour = tmux_colour(*dimmed)
	say(f"tab rgb{rgb} → {'full' if args.full else 'half'} brightness rgb{dimmed} → {colour}")
	if args.dry_run:
		return 0
	target = ["-t", args.session] if args.session else []
	return subprocess.run(["tmux", "set-option", *target, "status-bg", colour], capture_output=True).returncode


def parse_args():
	p = argparse.ArgumentParser(add_help=True, description=__doc__.splitlines()[0])
	p.add_argument("session", nargs="?", default="", help="tmux target session (default: the current one)")
	p.add_argument("-v", "--verbose", action="store_true", help="explain what happened, on stderr")
	p.add_argument("-n", "--dry-run", action="store_true", help="report the colour but do not set it")
	p.add_argument("-f", "--full", action="store_true", help="use the tab colour as it is, without darkening it")
	return p.parse_args()


def konsole_tab_rgb(session, say):
	"""The tab colour of the Konsole tab that created the session, as 8-bit RGB; None if none."""
	service = session_env(session, "KONSOLE_DBUS_SERVICE")
	path = session_env(session, "KONSOLE_DBUS_SESSION")
	if not service or not path:
		return None
	say(f"finding the Konsole tab by D-Bus {service} {path}")
	colour = dbus_call(service, path, "org.kde.konsole.Session.tabColor")
	if colour is None:
		say("could not ask Konsole for the tab colour (Konsole too old, or no qdbus/gdbus)")
		return None
	# Konsole reports an unset tab colour as black: it is the name of an invalid QColor.
	if colour.lower() in ("", "#000000"):
		say("tab has no colour set")
		return None
	return hex_rgb(colour)


def iterm_tab_rgb(session, say):
	"""The tab colour of the iTerm2 tab the session is in, as 8-bit RGB; None if none."""
	value = session_env(session, "ITERM_SESSION_ID")
	uuid = value.split(":", 1)[1] if ":" in value else value
	tty = "" if uuid else attached_client_tty(session)
	if not uuid and not tty:
		say("session has no ITERM_SESSION_ID or KONSOLE_DBUS_SESSION and no attached client — cannot tell which tab it is in")
		return None
	iterm2 = import_iterm2(say)
	if iterm2 is None:
		return None
	say(f"finding the iTerm2 tab by {'ITERM_SESSION_ID ' + uuid if uuid else 'client tty ' + tty}")
	return query_iterm(iterm2, uuid, tty, say)


def session_env(session, var):
	"""A variable from the tmux session's own environment, or "".

	Only the session-level value is trusted: tmux's global environment holds whichever tab
	started the server, which is the wrong tab for any later session.
	"""
	target = ["-t", session] if session else []
	r = subprocess.run(["tmux", "show-environment", *target, var], capture_output=True, text=True)
	line = r.stdout.strip()
	if r.returncode != 0 or not line.startswith(f"{var}="):
		return ""
	return line.split("=", 1)[1]


def dbus_call(service, path, method):
	"""The string returned by a no-argument D-Bus method on the session bus, or None on failure."""
	for qdbus in ("qdbus6", "qdbus", "qdbus-qt6", "qdbus-qt5"):
		if shutil.which(qdbus):
			r = subprocess.run([qdbus, service, path, method], capture_output=True, text=True)
			return r.stdout.strip() if r.returncode == 0 else None
	if shutil.which("gdbus"):
		r = subprocess.run(["gdbus", "call", "--session", "--dest", service, "--object-path", path, "--method", method],
		                   capture_output=True, text=True)
		m = re.fullmatch(r"\('(.*)',\)", r.stdout.strip())  # gdbus prints a tuple: ('#rrggbb',)
		return m.group(1) if r.returncode == 0 and m else None
	return None


def hex_rgb(colour):
	"""(r, g, b) from "#rrggbb", or None."""
	m = re.fullmatch(r"#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})", colour)
	return tuple(int(c, 16) for c in m.groups()) if m else None


def attached_client_tty(session):
	"""The tty of the most recently active client attached to the session, or "".

	For sessions created before ITERM_SESSION_ID was recorded: a client's tty is the same
	device as the iTerm2 tab displaying it, so it identifies the tab just as well.
	"""
	target = ["-t", session] if session else []
	r = subprocess.run(["tmux", "list-clients", *target, "-F", "#{client_activity} #{client_tty}"],
	                   capture_output=True, text=True)
	clients = sorted((line.split(" ", 1) for line in r.stdout.splitlines() if " " in line),
	                 key=lambda c: int(c[0]) if c[0].isdigit() else 0, reverse=True)
	return clients[0][1] if clients else ""


def import_iterm2(say):
	"""The iterm2 module, re-running under the private venv if this python lacks it."""
	try:
		import iterm2
		return iterm2
	except ImportError:
		pass
	if os.environ.get(REEXEC_FLAG) or not os.access(VENV_PYTHON, os.X_OK):
		say(f"iterm2 Python package not found; create the venv: python3 -m venv {os.path.dirname(os.path.dirname(VENV_PYTHON))} && its pip install iterm2")
		return None
	os.environ[REEXEC_FLAG] = "1"
	os.execv(VENV_PYTHON, [VENV_PYTHON, os.path.abspath(__file__), *sys.argv[1:]])


def query_iterm(iterm2, uuid, tty, say):
	"""The tab colour of the iTerm2 session identified by `uuid`, or failing that by `tty`,
	as 8-bit RGB; None if it has none."""
	result = {}

	async def find_by_tty(app):
		for window in app.terminal_windows:
			for tab in window.tabs:
				for session in tab.sessions:
					if await session.async_get_variable("tty") == tty:
						return session
		return None

	async def query(connection):
		app = await iterm2.async_get_app(connection)
		session = app.get_session_by_id(uuid) if uuid else await find_by_tty(app)
		if session is None:
			say(f"iTerm2 has no session {uuid or 'on ' + tty}")
			return
		props = (await session.async_get_profile()).all_properties
		# A profile can keep separate tab colours for light and dark mode, and iTerm2 then shows
		# the one for its current appearance — the plain "Tab Color" is not what is on screen.
		key = "Tab Color"
		if props.get("Use Separate Colors for Light and Dark Mode"):
			theme = (await app.async_get_variable("effectiveTheme") or "").split()
			key = "Tab Color (Dark)" if "dark" in theme else "Tab Color (Light)"
		colour = props.get(key)
		if not props.get(f"Use {key}") or not isinstance(colour, dict):
			say("tab has no colour set")
			return
		result["rgb"] = tuple(round(colour[f"{c} Component"] * 255) for c in ("Red", "Green", "Blue"))
		say(f"using {key!r}")

	try:
		iterm2.run_until_complete(query, retry=False)
	except Exception as e:  # API disabled, iTerm2 not running, permission refused
		say(f"could not query iTerm2: {e}")
		return None
	return result.get("rgb")


def tmux_colour(r, g, b):
	"""The exact colour as #rrggbb, not the nearest xterm-256 one.

	At half brightness these colours are dark and muted, where the 256-colour palette is
	coarsest: the nearest entry often lands on a neighbouring hue (lime came out yellow) or on
	the grey ramp (purple and red both came out grey). Terminals with RGB support show these
	exactly, and tmux itself converts them for any client that lacks it.
	"""
	return f"#{r:02x}{g:02x}{b:02x}"


if __name__ == "__main__":
	sys.exit(main())
