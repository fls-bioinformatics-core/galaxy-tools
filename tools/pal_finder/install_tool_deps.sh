#!/bin/bash
#
# Install the tool dependencies for pal_finder for testing from command line
#
# Installer functions
. $(dirname $0)/../../local_dependency_installers/perl.sh
. $(dirname $0)/../../local_dependency_installers/primer3_core.sh
. $(dirname $0)/../../local_dependency_installers/pal_finder.sh
. $(dirname $0)/../../local_dependency_installers/biopython.sh
. $(dirname $0)/../../local_dependency_installers/pandaseq.sh
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
# Perl 5.16.3
install_perl_5_16_3 $TOP_DIR
# primer3_core 2.0.0
install_primer3_core_2_0_0 $TOP_DIR
# Pal_finder 0.02.04
install_pal_finder_0_02_04 $TOP_DIR
# BioPython 1.65
install_biopython_1_65 $TOP_DIR
# PandaSeq 2.8
install_pandaseq_2_8_1 $TOP_DIR
##
#
