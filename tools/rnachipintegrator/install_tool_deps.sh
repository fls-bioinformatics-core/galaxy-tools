#!/bin/bash -e
#
# Install the tool dependencies for RnaChipIntegrator for testing from command line
#
# Installation directory
TOP_DIR=$1
if [ -z "$TOP_DIR" ] ; then
    echo Usage: $(basename $0) DIR
    exit
fi
if [ -z "$(echo $TOP_DIR | grep ^/)" ] ; then
    TOP_DIR=$(pwd)/$TOP_DIR
fi
if [ ! -d "$TOP_DIR" ] ; then
    mkdir -p $TOP_DIR
fi
cd $TOP_DIR
# RnaChipIntegrator 1.0.0
VERSION=1.0.0
INSTALL_DIR=$TOP_DIR/rnachipintegrator/$VERSION
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget https://pypi.python.org/packages/source/R/RnaChipIntegrator/RnaChipIntegrator-${VERSION}.tar.gz
tar zxf RnaChipIntegrator-${VERSION}.tar.gz
cd RnaChipIntegrator-$VERSION
pip install --no-use-wheel --install-option "--prefix=$INSTALL_DIR" .
popd
rm -rf $wd/*
rmdir $wd
cat > rnachipintegrator/$VERSION/env.sh <<EOF
#!/bin/sh
# Source this to setup rnachipintegrator/$VERSION
echo Setting up RnaChipIntegrator $VERSION
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
# xlsxwriter 0.8.4
INSTALL_DIR=$TOP_DIR/xlsxwriter/0.8.4
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget -q https://pypi.python.org/packages/source/X/XlsxWriter/XlsxWriter-0.8.4.tar.gz
tar xzf XlsxWriter-0.8.4.tar.gz
cd XlsxWriter-0.8.4
OLD_PYTHONPATH=$PYTHONPATH
mkdir -p $INSTALL_DIR/lib/python
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python
python setup.py install --install-lib $INSTALL_DIR/lib/python --install-scripts $INSTALL_DIR/bin
popd
rm -rf $wd/*
rmdir $wd
export PYTHONPATH=$OLD_PYTHONPATH
cat > xlsxwriter/0.8.4/env.sh <<EOF
#!/bin/sh
# Source this to setup xlsxwriter/0.8.4
echo Setting up xlsxwriter 0.8.4
export PYTHONPATH=$INSTALL_DIR/lib/python:\$PYTHONPATH
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
##
#
