#!/bin/bash -e
#
# Install Weeder
#
function install_weeder_2_0() {
    echo Installing Weeder2
    local install_dir=$1/weeder/2.0
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget http://159.149.160.51/modtools/downloads/weeder2.0.tar.gz
    tar xfz weeder2.0.tar.gz
    g++ weeder2.cpp -o weeder2 -O3
    mkdir $install_dir/bin
    mv weeder2 $install_dir/bin
    mv FreqFiles $install_dir/
    cd ..
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/weeder/2.0/env.sh <<EOF
#!/bin/sh
# Source this to setup weeder/2.0
export PATH=$install_dir/bin:\$PATH
export WEEDER_DIR=$install_dir
export WEEDER_FREQFILES_DIR=$install_dir/FreqFiles
#
EOF
}
