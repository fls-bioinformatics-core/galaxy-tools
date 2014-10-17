#!/bin/sh
#
# Package weeder tool files into tgz file for upload to
# Galaxy toolshed
#
TGZ=weeder.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.markdown \
    weeder_wrapper.sh \
    weeder_wrapper.xml \
    weeder2meme \
    weeder2meme_wrapper.sh \
    weeder2meme_wrapper.xml \
    tool_dependencies.xml \
    lib
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
