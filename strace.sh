#!/bin/sh

# make sure DL_DIR parameter is provided
if [ $# -eq 0 ]; then
    cat << EOF
Usage: $0 DL_DIR [--ignore-apply]

DL_DIR: The 'download directory used by Poky (use the one most populated to minimize downloads)
--ignore-apply: Ignore error when applying the strace patch

EOF
    exit 1
fi

# check tools
which strace > /dev/null || { echo "Install strace before running $0"; exit 1; }

# download directory
DL_DIR=$1
DL_DIR=$(realpath -e $DL_DIR)


# plot HW info
lscpu
free

# clone poky
if [ ! -d poky ]; then
    git clone git://git.yoctoproject.org/poky
fi

# patch
cd poky
git am ../patches/0001-buildhistory.bbclass-strace-c-every-task.patch 2>/dev/null
if [ $? -ne 0 -a -z "$2" ];  then
   cat <<EOF

strace patch was not applied; in case patch is present, include
--ignore-apply in the command line

EOF
   exit 1
fi

# fetch those missing upstream projects
BUILD=$PWD/build
[ -d $BUILD ] && { echo "ERROR: Build folder ($PWD/build) present, remove it and execute $0 again";  exit 1; }
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
