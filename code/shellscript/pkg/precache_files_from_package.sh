#!/bin/bash

collect_deps_from_package() {

  if [ -z "$precache_depth" ]
  then precache_depth=1
  fi

  if [ "$precache_depth" -gt 2 ]
  then return
  fi

  echo "Checking deps for packages at depth $precache_depth: $*" >&2

  local all_child_packages=$(
    for pkg
    do dpkg-query -W -f='${Depends}\n' "$pkg"
    done |
    betweenthe ', ' | betweenthe ' | ' | beforefirst ' (' |
    trimempty |
    removeduplicatelines
  )

  printf "%s\n" "$all_child_packages"

  precache_depth=$((precache_depth + 1))

  collect_deps_from_package $all_child_packages

  precache_depth=$((precache_depth - 1))

}

precache_files_from_package() {
  for pkg
  do
    echo "Caching package: $pkg" >&2
    dpkg -L "$pkg" | filesonly -inclinks | withalldo tar c >/dev/null
  done
}

#collect_deps_from_package "$@"
all_deps=$(collect_deps_from_package "$@")
echo "[precache_files_from_package] all_deps: $all_deps"

precache_files_from_package $all_deps
