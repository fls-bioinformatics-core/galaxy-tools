#!/bin/bash -e
#
# Install Primer3_core
#
function install_primer3_core_2_0_0() {
    echo Installing primer3_core
    local install_dir=$1/primer3_core/2.0.0
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://sourceforge.net/projects/primer3/files/primer3/2.0.0-alpha/primer3-2.0.0-alpha.tar.gz
    tar xzf primer3-2.0.0-alpha.tar.gz
    cd primer3-2.0.0-alpha
    make -C src -f Makefile >/dev/null 2>&1
    mkdir $install_dir/bin
    mv src/primer3_core $install_dir/bin
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/primer3_core/2.0.0/env.sh <<EOF
#!/bin/sh
# Source this to setup primer3_core/2.0.0
echo Setting up primer3_core 2.0.0
export PATH=$install_dir/bin:\$PATH
#
EOF
}
