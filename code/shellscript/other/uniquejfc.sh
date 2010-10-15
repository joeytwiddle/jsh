#!/bin/sh
jfc simple oneway  $1 $2  $3 $4 $5 $6 $7 $8 $9 >  $1.unique
jfc simple oneway  $2 $1  $3 $4 $5 $6 $7 $8 $9 >  $2.unique