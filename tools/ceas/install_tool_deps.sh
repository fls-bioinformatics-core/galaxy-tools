#!/bin/bash
#
# Install the tool dependencies for CEAS for testing from command line
#
# Installer functions
. $(dirname $0)/../../local_dependency_installers/bx_python.sh
. $(dirname $0)/../../local_dependency_installers/python_mysql.sh
. $(dirname $0)/../../local_dependency_installers/ceas.sh
. $(dirname $0)/../../local_dependency_installers/R.sh
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
# bx_python 0.7.1
install_bx_python_0_7_1 $TOP_DIR
# python_mysqldb 1.2.5
install_python_mysql_1_2_5 $TOP_DIR
# cistrome_ceas 1.0.2.d8c0751
install_cistrome_ceas_1_0_2_d8c0751 $TOP_DIR
# R 3.1.2
install_R_3_1_2 $TOP_DIR
# fetchChromSizes (UCSC tool)
install_ucsc_fetchChromSizes_1_0 $TOP_DIR
##
#
