## Observed that passing no args to . parseargs_base_impl, actually means current get passed.
## Observed that shifting in . parseargs_base_impl gets passed back.  =)
## TODO: check this is true for all sh's
## TODO: what about optional regex =)

echo "Before: -$*- b=$BLAH u=$USE"

. parseargs_base_impl << !
parses command line arguments into env vars
bool BLAH "do  summat"
opt USE "use xyz" "none"
!

echo "After: -$*- b=$BLAH u=$USE"
