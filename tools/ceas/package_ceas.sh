#!/bin/sh
#
# Package CEAS tool files into tgz file for upload to
# Galaxy toolshed
#
VERSION=$(grep "^<tool" ceas_wrapper.xml | grep -o -e version=\".*\" | cut -d= -f2 | tr -d \")
TGZ=ceas-${VERSION}.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    ceas_wrapper.xml \
    ceas_wrapper.sh \
    tool_data_table_conf.xml.sample \
    tool_data_table_conf.xml.test \
    tool-data/ceas.loc.sample \
    data_manager_conf.xml \
    data_manager/data_manager_ceas_fetch_annotations.xml \
    data_manager/data_manager_ceas_fetch_annotations.py \
    test-data \
    --exclude=*~ \
    --exclude=test-data/make_test_data.sh
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
