#!/bin/bash -e
#
# Install python_mysql
#
function install_python_mysql_1_2_5() {
    echo Installing python_mysql
    local install_dir=$1/python_mysqldb/1.2.5
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.5.zip
    unzip MySQL-python-1.2.5.zip
    mkdir -p $install_dir/lib/python
    local old_pythonpath=$PYTHONPATH
    export PYTHONPATH=$PYTHONPATH:$install_dir/lib/python
    cd MySQL-python-1.2.5
    python setup.py install --install-lib $install_dir/lib/python --install-scripts $install_dir/bin
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    export PYTHONPATH=$old_pythonpath
    # Make setup file
    cat > $1/python_mysqldb/1.2.5/env.sh <<EOF
#!/bin/sh
# Source this to setup python_mysqldb/1.2.5
echo Setting up python_mysqldb 1.2.5
export PATH=$install_dir/bin:\$PATH
export PYTHONPATH=$install_dir/lib/python:\$PYTHONPATH
#
EOF
}
