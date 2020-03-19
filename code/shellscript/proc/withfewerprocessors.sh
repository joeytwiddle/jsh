#!/usr/bin/env bash

num_cpus="$(cat /proc/cpuinfo  | grep processor | tail -n 1 | cut -d' ' -f 2)"

num_cpus=$((num_cpus + 1))

# Use only the second half of the processors
first_cpu="$((num_cpus / 2))"
last_cpu="$((num_cpus - 1))"

taskset -c "${first_cpu}-${last_cpu}" "$@"
