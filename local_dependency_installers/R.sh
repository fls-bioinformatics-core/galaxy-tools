#!/bin/bash -e
#
# Install R
#
function install_R_3_1_2() {
    echo Installing R
    local install_dir=$1/R/3.1.2
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    ##wget -q https://depot.galaxyproject.org/package/linux/x86_64/R/R-3.1.2-Linux-x84_64.tgz
    ##tar xzf R-3.1.2-Linux-x84_64.tgz
    ##rm -f R-3.1.2-Linux-x84_64.tgz
    ##mv * $install_dir
    wget -q http://cran.r-project.org/src/base/R-3/R-3.1.2.tar.gz
    tar xzf R-3.1.2.tar.gz
    cd R-3.1.2
    ./configure --prefix=$install_dir
    make
    make install
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $1/R/3.1.2/env.sh <<EOF
#!/bin/sh
# Source this to setup R/3.1.2
echo Setting up R 3.1.2
export PATH=$install_dir/bin:\$PATH
export TCL_LIBRARY=$install_dir/lib/libtcl8.4.so
export TK_LIBRARY=$install_dir/lib/libtk8.4.so
#
EOF
}
