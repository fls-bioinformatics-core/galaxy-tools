#!/bin/bash
#
# Install dependencies and set up environment for
# weeder2 tool, then run tests using planemo
#
# Note that any arguments supplied to the script are
# passed directly to the "planemo test..." invocation
#
# e.g. --install_galaxy (to get planemo to create a
#                        Galaxy instance to run tests)
#
#      --galaxy_root DIR (to run tests using existing
#                         Galaxy instance)
#
INSTALL_DIR=$(pwd)/test.tool_dependencies/weeder2
if [ -e $INSTALL_DIR ] ; then
    echo $INSTALL_DIR already exists >&2
else
    # Download and install weeder2
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget http://159.149.160.51/modtools/downloads/weeder2.0.tar.gz
    tar xvfz weeder2.0.tar.gz
    g++ weeder2.cpp -o weeder2 -O3
    mkdir $INSTALL_DIR/bin
    mv weeder2 $INSTALL_DIR/bin
    mv FreqFiles $INSTALL_DIR/
    cd ..
    popd
    rm -rf $wd/*
    rmdir $wd
fi
# Set up the environment
export PATH=$INSTALL_DIR/bin:$PATH
export WEEDER_DIR=$INSTALL_DIR
export WEEDER_FREQFILES_DIR=$INSTALL_DIR/FreqFiles
# Run the planemo tests
planemo test $@ $(dirname $0)/weeder2_wrapper.xml
##
#
