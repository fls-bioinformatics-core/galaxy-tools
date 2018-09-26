#!/bin/sh
#
# Package weeder2 tool files into tgz file for upload to
# Galaxy toolshed
#
VERSION=$(grep "^<tool" weeder2_wrapper.xml | grep -o -e version=\".*\" | cut -d= -f2 | tr -d \")
TGZ=weeder2-${VERSION}.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    weeder2_wrapper.sh \
    weeder2_wrapper.xml \
    tool_data_table_conf.xml.sample \
    tool_data_table_conf.xml.test \
    tool-data/weeder2.loc.sample \
    test-data \
    --exclude=*~
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
