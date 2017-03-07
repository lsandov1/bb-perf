# General Settings
set terminal pngcairo enhanced font 'Verdana,8'
set xlabel 'Building time (s)'

# Procs
set term png size 1300, 650
set output 'vmstat-procs.png'
set title 'Processing Jobs' font 'Verdana,14'
set ylabel 'Number of Processes'
plot data using 1 with lines title 'Runnable (r)', \
     data using 2 with lines title 'Uninterruptible sleep (b)'
unset title
unset ylabel

# Memory
set term png size 1000, 1100
set output 'vmstat-memory.png'
set ylabel 'GB'
set multiplot layout 4,1 rowsfirst title 'Memory Usage' font 'Verdana,14'
set title 'Idle Memory'
plot data using ($4/1048576.) with lines title 'Idle Memory (free)'
set title 'Cache Memory'
plot data using ($6/1048576.) with lines title 'Idle Memory (cache)'
set ylabel 'MB'
set title 'Swapped Memory'
plot data using ($3/1024) with lines title 'Virtual Memory Used (swpd)'
set title 'Buffer Memory'
plot data using ($5/1024.) with lines title 'Idle Memory (buff)'
unset ylabel
unset multiplot
unset title

# Swap
set term png size 1000, 700
set output 'vmstat-swap.png'
set multiplot layout 2,1 rowsfirst title 'Sent/Retrieved Memory From Swap' font 'Verdana,14'
set title 'Swapped In'
plot data using 7 with lines title 'Swapped in from disk (si)'
set title 'Swapped Out'
plot data using 8 with lines title 'Swapped to disk (so)'
unset multiplot
unset title

# IO
set term png size 1000, 800
set output 'vmstat-io.png'
set multiplot layout 2,1 rowsfirst title 'IO Activity' font 'Verdana,14'
set title 'Reading'
set ylabel '# Blocks read per second'
plot data using 9 with lines title  'Blocks received from a block device (bi)'
set title 'Writting'
set ylabel '# Blocks written per second (x1000)'
plot data using ($10/1000.) with lines title 'Blocks sent to a block device (bo)'
unset multiplot
unset ylabel
unset title

# System
set output 'vmstat-system.png'
set multiplot layout 2,1 rowsfirst title 'System Operations' font 'Verdana,14'
set title 'System Interrupts'
set ylabel '# Interrupts per second (x1000)'
plot data using ($11/1000.) with lines title 'Interrupts per second (in)
set ylabel '# Context switches per second (x1000)'
set title 'Context Switches'
plot data  using ($12/1000.) with lines title 'Context switches per second (cs)'
unset ylabel
unset multiplot
unset title

# CPU
set term png size 1500, 650
set output 'vmstat-cpu.png'
set ylabel '% of CPU time'
set multiplot layout 2,2 rowsfirst title "CPU Resources"
set title 'User time'
plot data using 13 with lines title 'Time spent running non-kernel-code (us)'
set title 'System time'
plot data using 14 with lines title 'Time spent running kernel-code (sy)'
set title 'CPU idle time'
plot data using 15 with lines title 'Time spent idle (id)'
set title 'CPU waiting time'
plot data using 16 with lines title 'Time spent waiting for IO (wa)'
unset multiplot
unset ylabel
unset title
