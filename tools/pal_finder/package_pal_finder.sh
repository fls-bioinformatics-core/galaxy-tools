#!/bin/sh
#
# Package pal_finder tool files into tgz file for upload to
# Galaxy toolshed
#
VERSION=$(grep "^<tool" pal_finder_wrapper.xml | grep -o -e version=\".*\" | cut -d= -f2 | tr -d \")
TGZ=pal_finder-${VERSION}.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    pal_finder_wrapper.sh \
    pal_finder_wrapper_utils.sh \
    pal_finder_wrapper.xml \
    pal_finder_macros.xml \
    pal_filter.py \
    fastq_subset.py \
    test-data
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
