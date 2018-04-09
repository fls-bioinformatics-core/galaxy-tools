#!/bin/sh
#
# Package motif_tools files into tgz file for upload to
# Galaxy toolshed
#
VERSION=$(grep "@VERSION@" motif_tools_macros.xml | cut -d'>' -f2 | cut -d '<' -f1)
TGZ=motif_tools-${VERSION}.tgz
if [ -f $TGZ ] ; then
    echo $TGZ: already exists, please remove >&2
    exit 1
fi
tar cvzf $TGZ \
    README.rst \
    CountUniqueIDs.xml \
    CountUniqueIDs.pl \
    Scan_IUPAC_output_each_match.xml \
    Scan_IUPAC_output_each_match.pl \
    Scan_IUPAC_output_matches_per_seq.xml \
    Scan_IUPAC_output_matches_per_seq.pl \
    TFBScluster_candidates_2TFBS.xml \
    TFBScluster_candidates_3TFBS.xml \
    TFBScluster_candidates.pl \
    motif_tools_macros.xml \
    test-data
if [ -f $TGZ ] ; then
    echo Created $TGZ
else
    echo Failed to created $TGZ >&2
    exit 1
fi
##
#
