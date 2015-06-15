#!/bin/sh
#
# Package CEAS tool files into tgz file for upload to
# Galaxy toolshed
#
TGZ=ceas.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.markdown \
    ceas_wrapper.xml \
    ceas_wrapper.sh \
    tool_data_table_conf.xml.sample \
    tool-data/ceas.loc.sample \
    tool_dependencies.xml \
    data_manager_conf.xml \
    data_manager/data_manager_ceas_fetch_annotations.xml \
    data_manager/data_manager_ceas_fetch_annotations.py
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
