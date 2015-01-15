#!/bin/sh
#
# Package ceasbw tool files into tgz file for upload to
# Galaxy toolshed
#
TGZ=ceasbw.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.markdown \
    ceasbw_wrapper.xml \
    ceasbw_wrapper.sh \
    tool_data_table_conf.xml.sample \
    tool-data/ceas.loc.sample \
    tool_dependencies.xml
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
