#!/bin/bash -e
#
# Install Pal_finder
#
function install_pal_finder_0_02_04() {
    echo Installing pal_finder
    local install_dir=$1/pal_finder/0.02.04
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://sourceforge.net/projects/palfinder/files/pal_finder_v0.02.04.tar.gz
    tar xzf pal_finder_v0.02.04.tar.gz
    mkdir $install_dir/bin
    mv pal_finder_v0.02.04/pal_finder_v0.02.04.pl $install_dir/bin
    mkdir $install_dir/data
    mv pal_finder_v0.02.04/config.txt $install_dir/data/
    mv pal_finder_v0.02.04/simple.ref $install_dir/data/
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/pal_finder/0.02.04/env.sh <<EOF
#!/bin/sh
# Source this to setup pal_finder/0.02.04
echo Setting up pal_finder 0.02.04
export PATH=$install_dir/bin:\$PATH
export PALFINDER_SCRIPT_DIR=$install_dir/bin
export PALFINDER_DATA_DIR=$install_dir/data
#
EOF
}
