#!/bin/sh
distill -compresstext on -colorres 1200 -grayres 1200 -monores 1200 "$@"
# distill -compresstext on -colorres 600 -grayres 600 -monores 600 "$@"
# ps2pdf -r600 "$@"
