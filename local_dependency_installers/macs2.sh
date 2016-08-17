#!/bin/bash -e
#
# Install MACS2
#
function install_macs2_2_1_0_20140616() {
    echo Installing MACS2
    local install_dir=$1/macs/2.1.0.20140616
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://pypi.python.org/packages/source/M/MACS2/MACS2-2.1.0.20140616.tar.gz
    tar zxf MACS2-2.1.0.20140616.tar.gz
    local old_pythonpath=$PYTHONPATH
    export PYTHONPATH=$PYTHONPATH:$install_dir/lib/python
    cd MACS2-2.1.0.20140616
    python setup.py install --install-lib $install_dir/lib/python --install-scripts $install_dir/bin
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    export PYTHONPATH=$old_pythonpath
    # Make setup file
    cat > $1/macs/2.1.0.20140616/env.sh <<EOF
#!/bin/sh
# Source this to setup macs/2.1.0.20140616
echo Setting up MACS 2.1.0.20140616
export PATH=$install_dir/bin:\$PATH
export PYTHONPATH=$install_dir/lib/python:\$PYTHONPATH
#
EOF
}
