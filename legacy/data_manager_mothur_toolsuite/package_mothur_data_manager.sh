#!/bin/sh
#
# Package Mothur data manager files into tgz file for upload to
# Galaxy toolshed
#
TGZ=mothur_data_manager.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.markdown \
    tool_data_table_conf.xml.sample \
    data_manager_conf.xml \
    data_manager/data_manager_fetch_mothur_reference_data.xml \
    data_manager/fetch_mothur_reference_data.py \
    tool-data
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
