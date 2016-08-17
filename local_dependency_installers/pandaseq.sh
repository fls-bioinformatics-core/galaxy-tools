#!/bin/bash -e
#
# Install PandaSEQ
#
function install_pandaseq_2_8_1() {
    echo Installing PandaSeq
    local install_dir=$1/pandaseq/2.8.1
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://github.com/neufeld/pandaseq/archive/v2.8.1.tar.gz
    tar xzf v2.8.1.tar.gz
    cd pandaseq-2.8.1
    ./autogen.sh >/dev/null 2>&1
    ./configure --prefix=$install_dir >/dev/null 2>&1
    make; make install >/dev/null 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/pandaseq/2.8.1/env.sh <<EOF
#!/bin/sh
# Source this to setup pandaseq/2.8.1
echo Setting up pandaseq 2.8.1
export PATH=$install_dir/bin:\$PATH
export LD_LIBRARY_PATH=$install_dir/lib:\$LD_LIBRARY_PATH
#
EOF
}
