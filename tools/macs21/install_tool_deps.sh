#!/bin/bash
#
# Install the tool dependencies for MACS21 for testing from command line
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
# Numpy 1.9
mkdir numpy
virtualenv numpy/1.9
. numpy/1.9/bin/activate
pip install numpy==1.9
deactivate
cat > numpy/1.9/env.sh <<EOF
#!/bin/sh
# Source this to setup numpy/1.9
echo Setting up Numpy 1.9
export PYTHONPATH=$TOP_DIR/numpy/1.9/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
# MACS21
. numpy/1.9/env.sh # needs Numpy 1.9
INSTALL_DIR=$TOP_DIR/macs/2.1.0.20140616
mkdir -p $INSTALL_DIR/lib/python
wd=$(mktemp -d)
pushd $wd
wget -q https://pypi.python.org/packages/source/M/MACS2/MACS2-2.1.0.20140616.tar.gz
tar zxf MACS2-2.1.0.20140616.tar.gz
OLD_PYTHONPATH=$PYTHONPATH
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python
cd MACS2-2.1.0.20140616
python setup.py install --install-lib $INSTALL_DIR/lib/python --install-scripts $INSTALL_DIR/bin
popd
# Clean up
rm -rf $wd/*
rmdir $wd
export PYTHONPATH=$OLD_PYTHONPATH
# Make setup file
cat > macs/2.1.0.20140616/env.sh <<EOF
#!/bin/sh
# Source this to setup macs/2.1.0.20140616
echo Setting up MACS 2.1.0.20140616
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR/lib/python:\$PYTHONPATH
#
EOF
# UCSC tool subset
INSTALL_DIR=$TOP_DIR/ucsc_tools_for_macs21/1.0
mkdir -p $INSTALL_DIR/bin
cd $INSTALL_DIR/bin
wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes
wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedClip
wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig
for x in "fetchChromSizes bedClip bedGraphToBigWig" ; do
    chmod 755 $x
done
cd $TOP_DIR
# Make setup file
cat > ucsc_tools_for_macs21/1.0/env.sh <<EOF
#!/bin/sh
# Source this to setup ucsc_tools_for_macs21/1.0
echo Setting up UCSC Tools for MACS21 1.0
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
##
#
