#!/bin/sh

# plot CPU/Memory info
lscpu
free

# make sure DL_DIR parameter is provided
if [ ! $# -eq 1 ]; then
    echo "$0 DL_DIR"
    exit 1
fi

# check tools
which vmstat > /dev/null || { echo "Install vmstat before running $0"; exit 1; }

# download directory
DL_DIR=$1
DL_DIR=$(realpath -e $DL_DIR)

# clone poky
if [ ! -d poky ]; then
    git clone git://git.yoctoproject.org/poky
fi

# fetch those missing upstream projects
cd poky/
[ -d $PWD/build ] && { echo "ERROR: Build folder ($PWD/build) present, remove it and execute $0 again";  exit 1; }
. $PWD/oe-init-build-env build
cat > conf/auto.conf << EOF
DL_DIR = "$DL_DIR"
EOF
bitbake core-image-minimal -c fetchall

# start monitoring in background
VMSTAT_LOG="$PWD/vmstat.log"
vmstat -t -n 1 1>$VMSTAT_LOG &
pid_vmstat=$!

# disable network access
cat >> conf/auto.conf << EOF
BB_NO_NETWORK = "1"
EOF

# start build in background
bitbake core-image-minimal 1>/dev/null &
pid_bitbake=$!

# If this script is killed, kill both process.
trap "kill $pid_bitbake 2> /dev/null; kill $pid_vmstat 2> /dev/null" EXIT
trap "kill $pid_bitbake 2> /dev/null; kill $pid_vmstat 2> /dev/null" INT

# monitor while bb is running
echo ""
echo "Monitoring started"
while kill -0 $pid_bitbake 2> /dev/null; do
    tail -1 $VMSTAT_LOG
    sleep 2
done
echo "Monitoring finished"
echo ""

# kill the monitor system
kill -2 $pid_vmstat


vmstat=$(basename $VMSTAT_LOG .log)
cat <<EOF

vmstat data collected into $VMSTAT_LOG, you can plot it with

$ tail -n +3 $VMSTAT_LOG > $vmstat.clean
$ gnuplot -e "data='$vmstat.clean'" vmstat.gnu

EOF

# Disable the trap on a normal exit.
trap - EXIT
trap - INT