#!/bin/sh
#
# Package ceas tool files into tgz file for upload to
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
