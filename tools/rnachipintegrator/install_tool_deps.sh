#!/bin/bash -e
#
# Install the tool dependencies for RnaChipIntegrator for testing from command line
# Installer functions
. $(dirname $0)/../../local_dependency_installers/rnachipintegrator.sh
. $(dirname $0)/../../local_dependency_installers/xlsxwriter.sh
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
# RnaChipIntegrator 1.0.0
install_rnachipintegrator_1_0_0 $TOP_DIR
# xlsxwriter 0.8.4
install_xlsxwriter_0_8_4 $TOP_DIR
##
#
