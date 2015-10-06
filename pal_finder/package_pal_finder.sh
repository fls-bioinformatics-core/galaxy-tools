#!/bin/sh
#
# Package pal_finder tool files into tgz file for upload to
# Galaxy toolshed
#
TGZ=pal_finder.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    pal_finder_wrapper.sh \
    pal_finder_wrapper.xml \
    pal_finder_filter_and_assembly.py \
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
