#!/bin/sh
#
# Package RnaChipIntegrator files into tgz file for upload to
# Galaxy toolshed
#
VERSION=$(grep "@VERSION@" rnachipintegrator_macros.xml | cut -d'>' -f2 | cut -d'<' -f1)
TGZ=rnachipintegrator-${VERSION}.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    rnachipintegrator_macros.xml \
    rnachipintegrator_wrapper.xml \
    rnachipintegrator_canonical_genes.xml \
    rnachipintegrator_wrapper.sh \
    tool_dependencies.xml \
    data_manager \
    data_manager_conf.xml \
    tool-data \
    tool_data_table_conf.xml.sample \
    test-data \
    --exclude=*~
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
