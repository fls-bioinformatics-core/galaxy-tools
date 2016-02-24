#!/bin/bash
#
# Install the tool dependencies for Weeder2 for testing from command line
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
# Weeder 2.0
INSTALL_DIR=$TOP_DIR/weeder/2.0
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget http://159.149.160.51/modtools/downloads/weeder2.0.tar.gz
tar xfz weeder2.0.tar.gz
g++ weeder2.cpp -o weeder2 -O3
mkdir $INSTALL_DIR/bin
mv weeder2 $INSTALL_DIR/bin
mv FreqFiles $INSTALL_DIR/
cd ..
popd
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > weeder/2.0/env.sh <<EOF
#!/bin/sh
# Source this to setup weeder/2.0
export PATH=$INSTALL_DIR/bin:\$PATH
export WEEDER_DIR=$INSTALL_DIR
export WEEDER_FREQFILES_DIR=$INSTALL_DIR/FreqFiles
#
EOF
##
#
