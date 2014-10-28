#!/bin/sh
#
# Package weeder2 tool files into tgz file for upload to
# Galaxy toolshed
#
TGZ=weeder2.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.markdown \
    weeder2_wrapper.sh \
    weeder2_wrapper.xml \
    tool_dependencies.xml
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
