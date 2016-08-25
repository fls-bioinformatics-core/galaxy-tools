#!/bin/bash -e
#
# Install bx_python
#
function install_bx_python_0_7_1() {
    echo Installing bx_python
    mkdir -p $1/bx_python
    local install_dir=$1/bx_python/0.7.1
    virtualenv $install_dir
    . $install_dir/bin/activate
    pip install numpy==1.7.1
    pip install bx-python==0.7.1
    deactivate
    cat > $1/bx_python/0.7.1/env.sh <<EOF
#!/bin/sh
# Source this to setup bx_python/0.7.1
echo Setting up bx_python 0.7.1
export PYTHONPATH=$install_dir/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
}

