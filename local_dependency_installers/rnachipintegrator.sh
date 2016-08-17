#!/bin/bash -e
#
# Install RnaChipIntegrator
#
function install_rnachipintegrator_1_0_0() {
    echo Installing RnaChipIntegrator
    local version=1.0.0
    local install_dir=$1/rnachipintegrator/$version
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget https://pypi.python.org/packages/source/R/RnaChipIntegrator/RnaChipIntegrator-${version}.tar.gz
    tar zxf RnaChipIntegrator-${version}.tar.gz
    cd RnaChipIntegrator-$version
    pip install --no-use-wheel --install-option "--prefix=$install_dir" .
    popd
    rm -rf $wd/*
    rmdir $wd
cat > $1/rnachipintegrator/$version/env.sh <<EOF
#!/bin/sh
# Source this to setup rnachipintegrator/$version
echo Setting up RnaChipIntegrator $version
export PATH=$install_dir/bin:\$PATH
export PYTHONPATH=$install_dir/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
}