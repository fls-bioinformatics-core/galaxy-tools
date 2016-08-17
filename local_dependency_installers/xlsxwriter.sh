#!/bin/bash -e
#
# Install XlsxWriter
#
function install_xlsxwriter_0_8_4() {
    echo Installing XlsxWriter
    local version=1.0.0
    local install_dir=$1/xlsxwriter/0.8.4
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://pypi.python.org/packages/source/X/XlsxWriter/XlsxWriter-0.8.4.tar.gz
    tar xzf XlsxWriter-0.8.4.tar.gz
    cd XlsxWriter-0.8.4
    local old_pythonpath=$PYTHONPATH
    mkdir -p $install_dir/lib/python
    export PYTHONPATH=$install_dir/lib/python
    python setup.py install --install-lib $install_dir/lib/python --install-scripts $install_dir/bin
    popd
    rm -rf $wd/*
    rmdir $wd
    export PYTHONPATH=$old_pythonpath
    cat > $1/xlsxwriter/0.8.4/env.sh <<EOF
#!/bin/sh
# Source this to setup xlsxwriter/0.8.4
echo Setting up xlsxwriter 0.8.4
export PYTHONPATH=$install_dir/lib/python:\$PYTHONPATH
export PATH=$install_dir/bin:\$PATH
#
EOF
}
