#!/bin/bash -e
#
# Install Numpy
#
function install_numpy_1_9() {
    echo Installing numpy
    mkdir -p $1/numpy
    local install_dir=$1/numpy/1.9
    virtualenv $install_dir
    . $install_dir/bin/activate
    pip install numpy==1.9
    deactivate
    cat > $1/numpy/1.9/env.sh <<EOF
#!/bin/sh
# Source this to setup numpy/1.9
echo Setting up Numpy 1.9
export PYTHONPATH=$install_dir/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
}
