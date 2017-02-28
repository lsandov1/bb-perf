# General Settings
#
set terminal pngcairo enhanced font 'Verdana,8'
set xlabel 'Time'

# Procs
set output 'vmstat-procs.png'
set title 'Procs'
plot  "../data/core-image-minimal.vmstat"  using 1 with lines title 'Runnable (r)', \
      "../data/core-image-minimal.vmstat"  using 2 with lines title 'Uninterruptible sleep (b)'

# Memory
set output 'vmstat-memory.png'
set title 'Memory'
set multiplot layout 2,2 rowsfirst
plot  "../data/core-image-minimal.vmstat"  using 3 with lines title 'Virtual Memory Used (swpd)'
plot  "../data/core-image-minimal.vmstat"  using 4 with lines title 'Idle Memory (free)'
plot  "../data/core-image-minimal.vmstat"  using 5 with lines title 'Idle Memory (buff)'
plot  "../data/core-image-minimal.vmstat"  using 6 with lines title 'Idle Memory (cache)'
unset multiplot

# Swap
set output 'vmstat-swap.png'
set title 'Swap'
set multiplot layout 2,1 rowsfirst
plot  "../data/core-image-minimal.vmstat"  using 7 with lines title 'Swapped in from disk (si)'
plot  "../data/core-image-minimal.vmstat"  using 8 with lines title 'Swapped to disk (so)'
unset multiplot

# IO
set output 'vmstat-io.png'
set title 'IO'
set multiplot layout 2,1 rowsfirst
plot  "../data/core-image-minimal.vmstat"  using 9 with lines title  'Blocks received from a block device (bi)'
plot  "../data/core-image-minimal.vmstat"  using 10 with lines title 'Blocks sent to a block device (bo)'
unset multiplot

# System
set output 'vmstat-system.png'
set title 'System'
set multiplot layout 2,1 rowsfirst
plot  "../data/core-image-minimal.vmstat"  using 11 with lines title 'Interrupts per second (in)
plot  "../data/core-image-minimal.vmstat"  using 12 with lines title 'Context switches per second (cs)'
unset multiplot

# CPU
set output 'vmstat-cpu.png'
set title 'CPU'
set multiplot layout 2,2 rowsfirst
plot  "../data/core-image-minimal.vmstat"  using 13 with lines title 'Time spent running non-kernel-code (us)'
plot  "../data/core-image-minimal.vmstat"  using 14 with lines title 'Time spent running kernel-code (sy)'
plot  "../data/core-image-minimal.vmstat"  using 15 with lines title 'Time spent idle (id)'
plot  "../data/core-image-minimal.vmstat"  using 16 with lines title 'Time spent waiting for IO (wa)'
unset multiplot

