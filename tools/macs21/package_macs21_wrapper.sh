#!/bin/sh
#
# Package MACS 2.1 files into tgz file for upload to
# Galaxy toolshed
#
VERSION=$(grep "^<tool" macs21_wrapper.xml | grep -o -e version=\".*\" | cut -d= -f2 | tr -d \")
TGZ=macs21-${VERSION}.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    macs21_wrapper.xml \
    macs21_wrapper.py \
    test-data
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
