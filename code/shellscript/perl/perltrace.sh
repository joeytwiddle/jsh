echo "t to trace, c to run, b <full_sub_name|...> to set breakpoint, h h for help"
echo "Also see: http://perl.plover.com/Trace/"
echo "  perl -d:Trace <program> <args>.."
perl -dS "$@"
