#!/bin/bash -e
#
# Install Cistrome CEAS
#
function install_cistrome_ceas_1_0_2_d8c0751() {
    echo Installing Cistrome CEAS
    local install_dir=$1/cistrome_ceas/1.0.2.d8c0751
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    hg clone https://bitbucket.org/cistrome/cistrome-applications-harvard cistrome_ceas
    local old_pythonpath=$PYTHONPATH
    export PYTHONPATH=$PYTHONPATH:$install_dir/lib/python
    cd cistrome_ceas/published-packages/CEAS/
    python setup.py install --install-lib $install_dir/lib/python --install-scripts $install_dir/bin
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    export PYTHONPATH=$old_pythonpath
    # Make setup file
    cat > $1/cistrome_ceas/1.0.2.d8c0751/env.sh <<EOF
#!/bin/sh
# Source this to setup cistrome_ceas/1.0.2.d8c0751/env.sh
echo Setting up cistrome_ceas 1.0.2.d8c0751
export PATH=$install_dir/bin:\$PATH
export PYTHONPATH=$install_dir/lib/python:\$PYTHONPATH
#
EOF
}
