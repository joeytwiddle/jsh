## An alternative to scp, sloppycopy and sloppypaste allow you to transfer (small) files via two open xterms and unix copy/paste
## Files are checksummed in case of transfer-incompatability.
## But it should work fine because data will be (uu?) encoded to a generic charset.
## A clever header tells sloppypaste whether we are writing a single or multiple file(s).

## Oh of course I can just use uu(en|de)code

for X
do uuencode "$X" "$X"
done
