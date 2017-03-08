#!/usr/bin/python

import sys
import glob
import operator
import argparse

def main(top):
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


    #sort data
    sorted_tasks = dict()
    for task, data in tasks.items():
        sorted_tasks[task] = sorted(data.items(), key=operator.itemgetter(1), reverse=True)

    for task, data in sorted_tasks.items():
        for i in xrange(1):
            syscall, seconds = data[i]
            print '%s %s %s' % (task, syscall, seconds)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Sum syscall per bb tasks and print the top ones')
    parser.add_argument('--top', dest='top', default=1, help='top n')
    args = parser.parse_args()
    sys.exit(main(args.top))
