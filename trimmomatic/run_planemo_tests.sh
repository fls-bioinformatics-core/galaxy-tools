#!/bin/bash
#
# Install dependencies and set up environment for
# trimmomatic tool, then run tests using planemo
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
INSTALL_DIR=$(pwd)/test.tool_dependencies/trimmomatic
if [ -e $INSTALL_DIR ] ; then
    echo WARNING $INSTALL_DIR already exists >&2
else
    # Download and install Trimmomatic
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    echo Installing trimmomatic
    wget -q http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.32.zip
    unzip -qq Trimmomatic-0.32.zip
    mv Trimmomatic-0.32/trimmomatic-0.32.jar $INSTALL_DIR/
    mv Trimmomatic-0.32/adapters/ $INSTALL_DIR/
    popd
    rm -rf $wd/*
    rmdir $wd
fi
# Set up the environment
export TRIMMOMATIC_DIR=$INSTALL_DIR
export TRIMMOMATIC_ADAPTERS_DIR=$INSTALL_DIR/adapters
# Run the planemo tests
planemo test $@ $(dirname $0)/trimmomatic.xml
##
#
