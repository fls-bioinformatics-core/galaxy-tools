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
# RnaChipIntegrator 0.5.0-alpha.3
INSTALL_DIR=$TOP_DIR/rnachipintegrator/0.5.0-alpha.3
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget https://github.com/fls-bioinformatics-core/RnaChipIntegrator/archive/v0.5.0-alpha.3.tar.gz
tar zxf v0.5.0-alpha.3.tar.gz
cd RnaChipIntegrator-0.5.0-alpha.3
pip install --no-use-wheel --install-option "--prefix=$INSTALL_DIR" .
popd
rm -rf $wd/*
rmdir $wd
cat > rnachipintegrator/0.5.0-alpha.3/env.sh <<EOF
#!/bin/sh
# Source this to setup rnachipintegrator/0.5.0-alpha.3
echo Setting up RnaChipIntegrator 0.5.0-alpha.3
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
# xlwt 0.7.5
INSTALL_DIR=$TOP_DIR/xlwt/0.7.5
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget -q https://pypi.python.org/packages/source/x/xlwt/xlwt-0.7.5.tar.gz
tar xzf xlwt-0.7.5.tar.gz
cd xlwt-0.7.5
OLD_PYTHONPATH=$PYTHONPATH
mkdir -p $INSTALL_DIR/lib/python
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python
python setup.py install --install-lib $INSTALL_DIR/lib/python --install-scripts $INSTALL_DIR/bin
popd
rm -rf $wd/*
rmdir $wd
export PYTHONPATH=$OLD_PYTHONPATH
cat > xlwt/0.7.5/env.sh <<EOF
#!/bin/sh
# Source this to setup xlwt/0.7.5
echo Setting up xlwt 0.7.5
export PYTHONPATH=$INSTALL_DIR/lib/python:\$PYTHONPATH
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
# xlrd 0.9.3
INSTALL_DIR=$TOP_DIR/xlrd/0.9.3
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget -q https://pypi.python.org/packages/source/x/xlrd/xlrd-0.9.3.tar.gz
tar xzf xlrd-0.9.3.tar.gz
cd xlrd-0.9.3
OLD_PYTHONPATH=$PYTHONPATH
mkdir -p $INSTALL_DIR/lib/python
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python
python setup.py install --install-lib $INSTALL_DIR/lib/python --install-scripts $INSTALL_DIR/bin
popd
rm -rf $wd/*
rmdir $wd
export PYTHONPATH=$OLD_PYTHONPATH
cat > xlrd/0.9.3/env.sh <<EOF
#!/bin/sh
# Source this to setup xlrd/0.9.3
echo Setting up xlrd 0.9.3
export PYTHONPATH=$INSTALL_DIR/lib/python:\$PYTHONPATH
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
# xlutils 1.7.1
INSTALL_DIR=$TOP_DIR/xlutils/1.7.1
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget -q https://pypi.python.org/packages/source/x/xlutils/xlutils-1.7.1.tar.gz
tar xzf xlutils-1.7.1.tar.gz
cd xlutils-1.7.1
OLD_PYTHONPATH=$PYTHONPATH
mkdir -p $INSTALL_DIR/lib/python
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python
python setup.py install --install-lib $INSTALL_DIR/lib/python --install-scripts $INSTALL_DIR/bin
popd
rm -rf $wd/*
rmdir $wd
export PYTHONPATH=$OLD_PYTHONPATH
cat > xlutils/1.7.1/env.sh <<EOF
#!/bin/sh
# Source this to setup xlutils/1.7.1
echo Setting up xlutils 1.7.1
export PYTHONPATH=$INSTALL_DIR/lib/python:\$PYTHONPATH
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
##
#
