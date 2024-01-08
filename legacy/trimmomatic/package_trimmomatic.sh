#!/bin/sh
#
# Package Trimmomatic tool files into tgz file for upload to
# Galaxy toolshed
#
TOOL_VERSION=$(grep "@TOOL_VERSION@" trimmomatic_macros.xml | cut -f 2 -d'>' | cut -f 1 -d'<')
VERSION_SUFFIX=$(grep "@VERSION_SUFFIX@" trimmomatic_macros.xml | cut -f 2 -d'>' | cut -f 1 -d'<')
TGZ=trimmomatic-${TOOL_VERSION}+galaxy${VERSION_SUFFIX}.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    trimmomatic.xml \
    trimmomatic_macros.xml \
    test-data
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to create $TGZ >&2
    exit 1
fi
##
#
