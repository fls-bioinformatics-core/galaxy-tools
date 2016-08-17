#!/bin/bash
#
# Install dependencies for Trimmomatic for testing from the command line
#
# Installer functions
. $(dirname $0)/../../local_dependency_installers/trimmomatic.sh
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
# Trimmomatic 0.32
install_trimmomatic_0_36 $TOP_DIR
##
#
