#!/bin/bash
#
# Install the tool dependencies for MACS21 for testing from command line
#
# Installer functions
. $(dirname $0)/../../local_dependency_installers/numpy.sh
. $(dirname $0)/../../local_dependency_installers/macs2.sh
. $(dirname $0)/../../local_dependency_installers/ucsc_tools.sh
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
# Numpy 1.9
install_numpy_1_9 $TOP_DIR
# MACS21
. $TOP_DIR/numpy/1.9/env.sh # needs Numpy 1.9
install_macs2_2_1_0_20140616 $TOP_DIR
# UCSC tool subset
install_ucsc_tools_for_macs21_2_0 $TOP_DIR
##
#
