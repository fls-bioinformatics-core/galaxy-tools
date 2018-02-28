#!/bin/bash
#
# Install the tool dependencies for CEAS for testing from command line
#
# Installer functions
. $(dirname $0)/../../local_dependency_installers/ceas.sh
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
# cistrome_ceas 1.0.2.d8c0751
install_cistrome_ceas_1_0_2_d8c0751 $TOP_DIR
##
#
