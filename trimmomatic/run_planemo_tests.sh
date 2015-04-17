#!/bin/sh
#
# Install dependencies and set up environment for
# trimmomatic tool
#
INSTALL_DIR=$(pwd)/tool_dependencies/trimmomatic/0.32
if [ -e $INSTALL_DIR ] ; then
    echo $INSTALL_DIR already exists >&2
    exit 1
fi
mkdir -p $INSTALL_DIR
#
# Download and install Trimmomatic
wd=$(mktemp -d)
echo Moving to $wd
pushd $wd
wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.32.zip
unzip Trimmomatic-0.32.zip
mv Trimmomatic-0.32/trimmomatic-0.32.jar $INSTALL_DIR/
mv Trimmomatic-0.32/adapters/ $INSTALL_DIR/
popd
#rm -rf $wd/*
#rmdir $wd
# Set up the environment
export TRIMMOMATIC_DIR=$INSTALL_DIR
export TRIMMOMATIC_ADAPTERS_DIR=$INSTALL_DIR/adapters
# Run the planemo testsls
planemo test --install_galaxy trimmomatic.xml
##
#
