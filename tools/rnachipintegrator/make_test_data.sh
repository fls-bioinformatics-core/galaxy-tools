#!/bin/bash -e
#
# List of dependencies
TOOL_DEPENDENCIES="rnachipintegrator/1.0.2
 xlsxwriter/0.8.4"
# Where to find them
TOOL_DEPENDENCIES_DIR=$(pwd)/test.tool_dependencies.rnachipintegrator
if [ ! -d $TOOL_DEPENDENCIES_DIR ] ; then
    echo WARNING $TOOL_DEPENDENCIES_DIR not found >&2
    echo Creating tool dependencies dir
    mkdir -p $TOOL_DEPENDENCIES_DIR
    echo Installing tool dependencies
    $(dirname $0)/install_tool_deps.sh $TOOL_DEPENDENCIES_DIR
fi
# Load dependencies
for dep in $TOOL_DEPENDENCIES ; do
    env_file=$TOOL_DEPENDENCIES_DIR/$dep/env.sh
    if [ -e $env_file ] ; then
	. $env_file
    else
	echo ERROR no env.sh file found for $dep >&2
	exit 1
    fi
done
#
# rnachipintegrator_canonical_genes
#
# Test #1
RnaChipIntegrator --name=mm9 \
		  --cutoff=50000 \
		  --number=4 \
		  --xlsx \
		  --compact \
		  test-data/mm9_canonical_genes.tsv test-data/mm9_summits.txt
mv mm9_gene_centric.txt test-data/mm9_summits_per_feature.out
mv mm9_peak_centric.txt test-data/mm9_features_per_summit.out
mv mm9.xlsx test-data/mm9_summits.xlsx
#
# Test #2
RnaChipIntegrator --name=mm9 \
		  --cutoff=50000 \
		  --number=4 \
		  --xlsx \
		  --compact \
		  test-data/mm9_canonical_genes.tsv test-data/mm9_peaks.txt
mv mm9_gene_centric.txt test-data/mm9_peaks_per_feature1.out
mv mm9_peak_centric.txt test-data/mm9_features_per_peak1.out
mv mm9.xlsx test-data/mm9_peaks1.xlsx
#
# Test #3
RnaChipIntegrator --name=mm9 \
		  --cutoff=50000 \
		  --number=4 \
		  --xlsx \
		  --summary \
		  --pad \
		  test-data/mm9_canonical_genes.tsv test-data/mm9_peaks.txt
mv mm9_gene_centric.txt test-data/mm9_peaks_per_feature3.out
mv mm9_peak_centric.txt test-data/mm9_features_per_peak3.out
mv mm9_gene_centric_summary.txt test-data/mm9_peaks_per_feature3.summary
mv mm9_peak_centric_summary.txt test-data/mm9_features_per_peak3.summary
mv mm9.xlsx test-data/mm9_peaks3.xlsx
#
# rnachipintegrator_wrapper
#
# Test #1
RnaChipIntegrator --name=test \
		  --cutoff=130000 \
		  --number=4 \
		  --promoter_region=-10000,2500 \
		  --xlsx \
		  --compact \
		  test-data/features.txt test-data/summits.txt
mv test_gene_centric.txt test-data/summits_per_feature.out
mv test_peak_centric.txt test-data/features_per_summit.out
mv test.xlsx test-data/summits.xlsx
#
# Test #2
RnaChipIntegrator --name=test \
		  --cutoff=130000 \
		  --number=4 \
		  --promoter_region=-10000,2500 \
		  --xlsx \
		  --compact \
		  test-data/features.txt test-data/peaks.txt
mv test_gene_centric.txt test-data/peaks_per_feature1.out
mv test_peak_centric.txt test-data/features_per_peak1.out
mv test.xlsx test-data/peaks1.xlsx
#
# Test #3
RnaChipIntegrator --name=test \
		  --cutoff=130000 \
		  --number=4 \
		  --xlsx \
		  test-data/features.txt test-data/peaks.txt
mv test_gene_centric.txt test-data/peaks_per_feature2.out
mv test_peak_centric.txt test-data/features_per_peak2.out
mv test.xlsx test-data/peaks2.xlsx
#
# Test #4
RnaChipIntegrator --name=test \
		  --cutoff=130000 \
		  --number=4 \
		  --only-DE \
		  --xlsx \
		  --compact \
		  test-data/features.txt test-data/peaks.txt
mv test_gene_centric.txt test-data/peaks_per_feature3.out
mv test_peak_centric.txt test-data/features_per_peak3.out
mv test.xlsx test-data/peaks3.xlsx
#
# Test #5
RnaChipIntegrator --name=test \
		  --cutoff=130000 \
		  --number=4 \
		  --xlsx \
		  --summary \
		  --pad \
		  test-data/features.txt test-data/peaks.txt
mv test_gene_centric.txt test-data/peaks_per_feature4.out
mv test_peak_centric.txt test-data/features_per_peak4.out
mv test_gene_centric_summary.txt test-data/peaks_per_feature4.summary
mv test_peak_centric_summary.txt test-data/features_per_peak4.summary
mv test.xlsx test-data/peaks4.xlsx
#
# Test #6
RnaChipIntegrator --name=test \
		  --cutoff=0 \
		  --number=4 \
		  --xlsx \
		  --summary \
		  --pad \
		  test-data/features.txt test-data/peaks.txt
mv test_gene_centric.txt test-data/peaks_per_feature6.out
mv test_peak_centric.txt test-data/features_per_peak6.out
mv test_gene_centric_summary.txt test-data/peaks_per_feature6.summary
mv test_peak_centric_summary.txt test-data/features_per_peak6.summary
mv test.xlsx test-data/peaks6.xlsx
##
#
