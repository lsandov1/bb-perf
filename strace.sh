#!/bin/sh

function clonepull() {
    local poky=$1
    # clone poky
    if [ ! -d $poky ]; then
	git clone git://git.yoctoproject.org/poky $poky
    else
	cd $poky
	git reset --hard
	git pull
    fi
}

function fetchall() {
    local poky=$1
    # fetch those missing upstream projects
    build=$poky/build
    [ -d $build ] && { echo "ERROR: Build folder ($PWD/build) present, remove it and execute $0 again";  exit 1; }
    . $poky/oe-init-build-env $build
    cat > conf/auto.conf << EOF
DL_DIR = "$DL_DIR"
EOF
    bitbake core-image-minimal -c fetchall

}

function patch_poky() {
    local poky=$1
    local patch=$2
    cd $poky
    git apply $patch 2>/dev/null
    if [ $? -ne 0 -a -z "$2" ];  then
	cat <<EOF

strace patch was not applied; in case patch is present, include
--ignore-apply in the command line

EOF

    exit 1
fi
}

function run() {
    local poky=$1
    . $poky/oe-init-build-env $poky/build
    # disable network access
    cat >> conf/auto.conf << EOF
BB_NO_NETWORK = "1"
EOF

    # start build in background
    bitbake core-image-minimal 1>/dev/null
    return $!

}

function drop_kernel_caches() {
    sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

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

# set the repo variable
REPO=$(dirname $(realpath $0))
POKY=$REPO/poky
PATCH=$REPO/patches/strace.patch

clonepull $POKY
fetchall $POKY
patch_poky $POKY $PATCH
pid_bitbake=$(run $POKY)

# If this script is killed, kill both process.
trap "kill $pid_bitbake 2> /dev/null" EXIT
trap "kill $pid_bitbake 2> /dev/null" INT

cat <<EOF

strace data is collected into /tmp/strace.

# Forky tasks
grep -r execve /tmp/strace | awk '{print \$5,\$1}' | sort -n -r | head -25

EOF

# Disable the trap on a normal exit.
trap - EXIT
trap - INT
