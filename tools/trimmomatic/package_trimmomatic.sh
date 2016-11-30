#!/bin/sh
#
# Package Trimmomatic tool files into tgz file for upload to
# Galaxy toolshed
#
TGZ=trimmomatic.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    trimmomatic.xml \
    trimmomatic_macros.xml \
    tool_dependencies.xml \
    test-data
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
