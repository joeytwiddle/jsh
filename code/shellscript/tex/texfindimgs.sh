#!/bin/sh
grep 'images/' *.tex |
	after ':' | before '%' |
	after 'images/' | before ',' |
	trimempty
