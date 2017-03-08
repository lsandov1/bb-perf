#!/usr/bin/python

import glob
import operator

tasks = dict()

strace_files = glob.glob('*.do_*')

for f in strace_files:
    task = f.split('.')[-2]
    if not tasks.has_key(task):
        tasks[task] = dict()
    syscall_dict = tasks[task]
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


sorted_tasks = dict()
for task, data in tasks.items():
    sorted_tasks[task] = sorted(data.items(), key=operator.itemgetter(1), reverse=True)

for task, data in sorted_tasks.items():
    for i in xrange(5):
        syscall, seconds = data[i]
        print '%s %s %s' % (task, syscall, seconds)
