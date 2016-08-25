#!/bin/bash -e
#
# Install Biopython
#
function install_biopython_1_65() {
    echo Installing BioPython
    local install_dir=$1/biopython/1.65
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    pip install --install-option "--prefix=$install_dir" https://pypi.python.org/packages/source/b/biopython/biopython-1.65.tar.gz >/dev/null 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/biopython/1.65/env.sh <<EOF
#!/bin/sh
# Source this to setup biopython/1.65
echo Setting up biopython 1.65
export PYTHONPATH=$install_dir/lib/python2.7/site-packages:\$PYTHONPATH
export PYTHONPATH=$install_dir/lib64/python2.7/site-packages:\$PYTHONPATH
#
EOF
}
