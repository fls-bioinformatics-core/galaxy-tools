#!/bin/sh
#
# Fetch ENCODE Broad histone modification data for hg18 and prepare for input
# to RnaChipIntegrator histone modification Galaxy tool
#
ucsc_url=http://hgdownload.cse.ucsc.edu/goldenPath/hg18/encodeDCC/wgEncodeBroadChipSeq
loc_file=histone_mods.loc
cwd=`pwd`
genome="hg18"
# Move to genome-specific directory
if [ ! -d $genome ] ; then
    mkdir $genome
fi
cd $genome
cwd=`pwd`
# Download index of files
if [ ! -f index.txt ] ; then
    echo "Fetching index of files from $ucsc_url"
    wget -q $ucsc_url/files.txt -O index.txt
fi
# Go through index and locate ChIP peak data
while read line ; do
    f=`echo $line | cut -f1 -d" " | grep ^wgEncodeBroadChipSeqPeaks`
    if [ ! -z "$f" ] ; then
	# Extract file name and cell and antibody data
	cellLine=`echo $line | cut -f5 -d" " | cut -f2 -d"=" | cut -f1 -d";"`
	antibody=`echo $line | cut -f6 -d" " | cut -f2 -d"=" | cut -f1 -d";"`
	echo $f $cellLine $antibody
	# Work out target file names
	funzipped=${f%.*}
	fbed=${funzipped%.*}.bed
	# Download and process
	if [ ! -f $fbed ] ; then
	    echo "Downloading $f"
	    wget -q $ucsc_url/$f
	    echo "Creating $fbed"
	    gunzip $f
	    ##python /home/pjb/projects/RnaChipIntegrator/rearrange_columns.py 0,1,2 $funzipped > $fbed
	    # Extract out the first 3 columns of data
	    echo "#chrom"$'\t'"chromStart"$'\t'"chromEnd" > $fbed
	    cut -f 1-3 $funzipped >> $fbed
	    rm -f $funzipped
	fi
	# Add to the loc file for Galaxy
	echo ${genome}$'\t'${cellLine}/${antibody}$'\t'${cwd}/${fbed} >> $loc_file
    fi
done < index.txt
# Remove downloaded index file
if [ -f index.txt ] ; then
    rm -f index.txt
fi
exit
##
#