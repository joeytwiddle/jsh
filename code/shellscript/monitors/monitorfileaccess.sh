#!/bin/sh
jwatch listopenfiles -mergethreads . 2>/dev/null | grep -v "\<listopenfiles\>"
