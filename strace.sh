#!/bin/sh

# plot HW info
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

# patch
cd poky
git am ../patches/0001-buildhistory.bbclass-strace-c-every-task.patch
if [ $? -ne 0 ]; then
   echo "strace not enable, patch $STRACE_PATCH manually or check if already present"
   exit 1
fi

# fetch those missing upstream projects
BUILD=$PWD/build
[ -d $BUILD] && { echo "ERROR: Build folder ($PWD/build) present, remove it and execute $0 again";  exit 1; }
. $PWD/oe-init-build-env $BUILD
cat > conf/auto.conf << EOF
DL_DIR = "$DL_DIR"
EOF
bitbake core-image-minimal -c fetchall

# disable network access
cat >> conf/auto.conf << EOF
BB_NO_NETWORK = "1"
EOF

# start build in background
bitbake core-image-minimal 1>/dev/null
pid_bitbake=$!

# If this script is killed, kill both process.
trap "kill $pid_bitbake 2> /dev/null" EXIT
trap "kill $pid_bitbake 2> /dev/null" INT

cat <<EOF

strace data is collected into /tmp/strace.

# Forky tasks
grep -r execve /tmp/strace | awk '{print $5,$1}' | sort -n -r | head -25

EOF

# Disable the trap on a normal exit.
trap - EXIT
trap - INT
