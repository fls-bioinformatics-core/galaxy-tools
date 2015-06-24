#!/bin/bash
#
# Install the tool dependencies for CEAS for testing from command line
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
# bx_python 0.7.1
mkdir bx_python
virtualenv bx_python/0.7.1
. bx_python/0.7.1/bin/activate
pip install numpy==1.7.1
pip install bx-python==0.7.1
deactivate
cat > bx_python/0.7.1/env.sh <<EOF
#!/bin/sh
# Source this to setup bx_python/0.7.1
echo Setting up bx_python 0.7.1
export PYTHONPATH=$TOP_DIR/bx_python/0.7.1/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
# python_mysqldb 1.2.5
INSTALL_DIR=$TOP_DIR/python_mysqldb/1.2.5
mkdir -p $INSTALL_DIR/lib/python
wd=$(mktemp -d)
pushd $wd
wget -q https://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.5.zip
unzip MySQL-python-1.2.5.zip
OLD_PYTHONPATH=$PYTHONPATH
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python
cd MySQL-python-1.2.5
python setup.py install --install-lib $INSTALL_DIR/lib/python --install-scripts $INSTALL_DIR/bin
popd
# Clean up
rm -rf $wd/*
rmdir $wd
export PYTHONPATH=$OLD_PYTHONPATH
# Make setup file
cat > python_mysqldb/1.2.5/env.sh <<EOF
#!/bin/sh
# Source this to setup python_mysqldb/1.2.5
echo Setting up python_mysqldb 1.2.5
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR/lib/python:\$PYTHONPATH
#
EOF
# cistrome_ceas 1.0.2.d8c0751
INSTALL_DIR=$TOP_DIR/cistrome_ceas/1.0.2.d8c0751
mkdir -p $INSTALL_DIR/lib/python
wd=$(mktemp -d)
pushd $wd
hg clone https://bitbucket.org/cistrome/cistrome-applications-harvard cistrome_ceas
OLD_PYTHONPATH=$PYTHONPATH
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python
cd cistrome_ceas/published-packages/CEAS/
python setup.py install --install-lib $INSTALL_DIR/lib/python --install-scripts $INSTALL_DIR/bin
popd
# Clean up
rm -rf $wd/*
rmdir $wd
export PYTHONPATH=$OLD_PYTHONPATH
# Make setup file
cat > cistrome_ceas/1.0.2.d8c0751/env.sh <<EOF
#!/bin/sh
# Source this to setup cistrome_ceas/1.0.2.d8c0751/env.sh
echo Setting up cistrome_ceas 1.0.2.d8c0751
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR/lib/python:\$PYTHONPATH
#
EOF
# R 3.1.2
INSTALL_DIR=$TOP_DIR/R/3.1.2
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
##wget -q https://depot.galaxyproject.org/package/linux/x86_64/R/R-3.1.2-Linux-x84_64.tgz
##tar xzf R-3.1.2-Linux-x84_64.tgz
##rm -f R-3.1.2-Linux-x84_64.tgz
##mv * $INSTALL_DIR
wget -q http://cran.r-project.org/src/base/R-3/R-3.1.2.tar.gz
tar xzf R-3.1.2.tar.gz
cd R-3.1.2
./configure --prefix=$INSTALL_DIR
make
make install
popd
# Clean up
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > R/3.1.2/env.sh <<EOF
#!/bin/sh
# Source this to setup R/3.1.2
echo Setting up R 3.1.2
export PATH=$INSTALL_DIR/bin:\$PATH
export TCL_LIBRARY=$INSTALL_DIR/lib/libtcl8.4.so
export TK_LIBRARY=$INSTALL_DIR/lib/libtk8.4.so
#
EOF
# fetchChromSizes (UCSC tool)
INSTALL_DIR=$TOP_DIR/ucsc_fetchChromSizes/1.0
mkdir -p $INSTALL_DIR/bin
cd $INSTALL_DIR/bin
wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes
chmod 755 fetchChromSizes
cd $TOP_DIR
# Make setup file
cat > ucsc_fetchChromSizes/1.0/env.sh <<EOF
#!/bin/sh
# Source this to setup fetchChromSizes/1.0
echo Setting up fetchChromSizes 1.0
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
##
#
