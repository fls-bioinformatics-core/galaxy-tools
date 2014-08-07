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
    README.markdown \
    trimmomatic.xml \
    trimmomatic.sh \
    trimmomatic_adapters.loc.sample \
    tool_dependencies.xml
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
