#!/bin/sh
## Makes memo-ing faster by importing its scripts as shell functions
## Also makes memoing possible on functions, e.g. "memo my_function <my_args>".
. jgettmpdir -top
. importshfn rememo
. importshfn memo
## Other niceities:
export IKNOWIDONTHAVEATTY=1
export MEMO_IGNORE_DIR=1
