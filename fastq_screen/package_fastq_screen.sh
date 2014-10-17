#!/bin/sh
#
# Package fastq_screen tool files into tgz file for upload to
# Galaxy toolshed
#
TGZ=fastq_screen.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.markdown \
    fastq_screen.xml \
    fastq_screen.sh \
    tool_data_table_conf.xml.sample \
    tool-data/fastq_screen.loc.sample \
    tool_dependencies.xml
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
