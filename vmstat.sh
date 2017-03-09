#!/bin/sh

# kill a process with SIGTERM, if fail, send SIGKILL
function killproc() {
    local pid=$1

    [ -z "$pid" ] && return

    kill -TERM $pid

    # give some time to terminate
    sleep 1

    if kill -0 $pid 2 > /dev/null; then
	kill -KILL $pid;
    fi
}

# make sure DL_DIR parameter is provided
if [ ! $# -eq 1 ]; then
    cat << EOF
Usage: $0 DL_DIR

DL_DIR: The 'download directory used by Poky (use the one most populated to minimize downloads)

EOF
    exit 1
fi

# check tools
which vmstat > /dev/null || { echo "Install vmstat before running $0"; exit 1; }

# download directory
DL_DIR=$1
DL_DIR=$(realpath -e $DL_DIR)

# plot CPU/Memory info
lscpu
free

# clone poky
if [ ! -d poky ]; then
    git clone git://git.yoctoproject.org/poky
fi

# fetch those missing upstream projects
cd poky/
BUILD=$PWD/build
[ -d $BUILD ] && { echo "ERROR: Build folder ($PWD/build) present, remove it and execute $0 again";  exit 1; }
. $PWD/oe-init-build-env $BUILD

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
killproc $pid_vmstat


vmstat=$(basename $VMSTAT_LOG .log)
cat <<EOF

vmstat data collected into $VMSTAT_LOG, you can plot it with

$ tail -n +3 $VMSTAT_LOG > $vmstat.clean
$ gnuplot -e "data='$vmstat.clean'" vmstat.gnu

EOF

# Disable the trap on a normal exit.
trap - EXIT
trap - INT
