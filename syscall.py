#!/usr/bin/python

syscall_dict = {}

import glob

strace_files = glob.glob('*.do_*')

for f in strace_files:
    with open(f) as fd:
        fd.readline()
        fd.readline()
        for line in fd:

            if '---' in line:
                break

            seconds = None
            syscall = None
            data = line.split()
            if len(data) == 6:
                time, seconds, usec_per_call, calls, errors, syscall = data
            else:
                time, seconds, usec_per_call, calls, syscall = data

            seconds = float(seconds)
            if not syscall_dict.has_key(syscall):
                syscall_dict[syscall] = seconds
            else:
                syscall_dict[syscall] += seconds


for syscall, seconds in syscall_dict.items():
    print '%s %s' % (seconds, syscall)
