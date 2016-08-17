#!/bin/bash
#
# Install the tool dependencies for Weeder2 for testing from command line
#
# Installer functions
. $(dirname $0)/../../local_dependency_installers/weeder.sh
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
# Weeder 2.0
install_weeder_2_0 $TOP_DIR
##
#
