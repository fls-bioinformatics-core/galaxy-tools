#!/bin/sh
#
# Package MACS 2.1.0 files into tgz file for upload to
# Galaxy toolshed
#
TGZ=macs21_wrapper.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    macs21_wrapper.xml \
    macs21_wrapper.py \
    tool_dependencies.xml
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
