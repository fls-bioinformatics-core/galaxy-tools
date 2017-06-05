#!/bin/sh
#
# pal_finder_wrapper.sh: run pal_finder perl script as a Galaxy tool
#
# Usage: run_palfinder.sh FASTQ_R1 FASTQ_R2 MICROSAT_SUMMARY PAL_SUMMARY FILTERED_MICROSATS [OPTIONS]
#        run_palfinder.sh --454    FASTA    MICROSAT_SUMMARY PAL_SUMMARY [OPTIONS]
#
# Options:
#
# --primer-prefix PREFIX: prefix added to the beginning of all primer names (prPrefixName)
# --2merMinReps N: miniumum number of 2-mer repeat units to detect (0=ignore units of this size)
# --3merMinReps N
# --4merMinReps N
# --5merMinReps N
# --6merMinReps N
# --primer-mispriming-library FASTA: specify a Fasta file with sequences to avoid amplifying
# --primer-opt-size VALUE: optimum primer length
# --primer-min-size VALUE: minimum acceptable primer length
# --primer-max-size VALUE: maximum acceptable primer length
# --primer-min-gc VALUE: minimum allowable percentage of Gs and Cs in any primer
# --primer-max-gc VALUE: maximum allowable percentage of Gs and Cs
# --primer-gc-clamp VALUE: number of consecutive Gs and Cs at 3' end of both left and right primer
# --primer-max-end-gc VALUE: max number of Gs or Cs in last five 3' bases of left or right primer
# --primer-min-tm VALUE: minimum acceptable melting temperature (Celsius) for a primer oligo
# --primer-max-tm VALUE: maximum acceptable melting temperature (Celsius)
# --primer-opt-tm VALUE: optimum melting temperature (Celsius)
# --primer-pair-max-diff-tm VALUE: max difference between melting temps of left & right primers
# --output_config_file FNAME: write a copy of the config.txt file to FNAME
# --filter_microsats FNAME: write output of filter options FNAME
# -assembly FNAME: run the 'assembly' filter option and write to FNAME
# -primers: run the 'primers' filter option
# -occurrences: run the 'occurrences' filter option
# -rankmotifs: run the 'rankmotifs' filter option
# --subset N: use a subset of reads of size N
#
# pal_finder is available from http://sourceforge.net/projects/palfinder/
#
# primer3 is available from http://primer3.sourceforge.net/releases.php
# (nb needs version 2.0.0-alpha)
#
# Explicitly set the locations of the pal_finder script, data files and the primer3
# executable by setting the following variables in the environment:
#
#  * PALFINDER_SCRIPT_DIR: location of the pal_finder Perl script (defaults to
#    /usr/bin)
#  * PALFINDER_DATA_DIR: location of the pal_finder data files (specifically
#    config.txt and simple.ref; defaults to /usr/share/pal_finder_v0.02.04)
#  * PRIMER3_CORE_EXE: name of the primer3_core program, which should include the
#    full path if it's not on the Galaxy user's PATH (defaults to primer3_core)
#
echo "### $(basename $0) ###"
echo $*
#
# Maximum size reporting log file contents
MAX_LINES=500
#
# Get helper functions
. $(dirname $0)/pal_finder_wrapper_utils.sh
#
# Initialise locations of scripts, data and executables
#
# Set these in the environment to overide at execution time
: ${PALFINDER_SCRIPT_DIR:=/usr/bin}
: ${PALFINDER_DATA_DIR:=/usr/share/pal_finder_v0.02.04}
: ${PRIMER3_CORE_EXE:=primer3_core}
#
# Filter script is in the same directory as this script
PALFINDER_FILTER=$(dirname $0)/pal_filter.py
if [ ! -f $PALFINDER_FILTER ] ; then
    fatal No $PALFINDER_FILTER script
fi
#
# Check that we have all the components
if [ "$(have_program $PRIMER3_CORE_EXE)" == "no" ] ; then
    fatal "primer3_core missing: ${PRIMER3_CORE_EXE} not found"
fi
if [ ! -f "${PALFINDER_DATA_DIR}/config.txt" ] ; then
    fatal "pal_finder config.txt not found in ${PALFINDER_DATA_DIR}"
fi
if [ ! -f "${PALFINDER_SCRIPT_DIR}/pal_finder_v0.02.04.pl" ] ; then
    fatal "pal_finder_v0.02.04.pl not found in ${PALFINDER_SCRIPT_DIR}"
fi
#
# Initialise parameters used in the config.txt file
PRIMER_PREFIX="test"
MIN_2_MER_REPS=6
MIN_3_MER_REPS=0
MIN_4_MER_REPS=0
MIN_5_MER_REPS=0
MIN_6_MER_REPS=0
PRIMER_MISPRIMING_LIBRARY=$PALFINDER_DATA_DIR/simple.ref
PRIMER_OPT_SIZE=
PRIMER_MAX_SIZE=
PRIMER_MIN_SIZE=
PRIMER_MAX_GC=
PRIMER_MIN_GC=
PRIMER_GC_CLAMP=
PRIMER_MAX_END_GC=
PRIMER_OPT_TM=
PRIMER_MAX_TM=
PRIMER_MIN_TM=
PRIMER_PAIR_MAX_DIFF_TM=
OUTPUT_CONFIG_FILE=
OUTPUT_ASSEMBLY=
FILTERED_MICROSATS=
FILTER_OPTIONS=
SUBSET=
RANDOM_SEED=568765
#
# Collect command line arguments
if [ $# -lt 2 ] ; then
  echo "Usage: $0 FASTQ_R1 FASTQ_R2 MICROSAT_SUMMARY PAL_SUMMARY [OPTIONS]"
  echo "       $0 --454    FASTA    MICROSAT_SUMMARY PAL_SUMMARY [OPTIONS]"
  fatal "Bad command line"
fi
if [ "$1" == "--454" ] ; then
    PLATFORM="454"
    FNA=$2
else
    PLATFORM="Illumina"
    FASTQ_R1=$1
    FASTQ_R2=$2
fi
MICROSAT_SUMMARY=$3
PAL_SUMMARY=$4
shift; shift; shift; shift
#
# Collect command line options
while [ ! -z "$1" ] ; do
    case "$1" in
	--primer-prefix)
	    shift
	    # Convert all non-alphanumeric characters to underscores in prefix
	    PRIMER_PREFIX=$(echo -n $1 | tr -s -c "[:alnum:]" "_")
	    ;;
	--2merMinReps)
	    shift
	    MIN_2_MER_REPS=$1
	    ;;
	--3merMinReps)
	    shift
	    MIN_3_MER_REPS=$1
	    ;;
	--4merMinReps)
	    shift
	    MIN_4_MER_REPS=$1
	    ;;
	--5merMinReps)
	    shift
	    MIN_5_MER_REPS=$1
	    ;;
	--6merMinReps)
	    shift
	    MIN_6_MER_REPS=$1
	    ;;
	--primer-mispriming-library)
	    shift
	    PRIMER_MISPRIMING_LIBRARY=$1
	    ;;
	--primer-opt-size)
	    shift
	    PRIMER_OPT_SIZE=$1
	    ;;
	--primer-max-size)
	    shift
	    PRIMER_MAX_SIZE=$1
	    ;;
	--primer-min-size)
	    shift
	    PRIMER_MIN_SIZE=$1
	    ;;
	--primer-max-gc)
	    shift
	    PRIMER_MAX_GC=$1
	    ;;
	--primer-min-gc)
	    shift
	    PRIMER_MIN_GC=$1
	    ;;
	--primer-gc-clamp)
	    shift
	    PRIMER_GC_CLAMP=$1
	    ;;
	--primer-max-end-gc)
	    shift
	    PRIMER_MAX_END_GC=$1
	    ;;
	--primer-opt-tm)
	    shift
	    PRIMER_OPT_TM=$1
	    ;;
	--primer-max-tm)
	    shift
	    PRIMER_MAX_TM=$1
	    ;;
	--primer-min-tm)
	    shift
	    PRIMER_MIN_TM=$1
	    ;;
	--primer-pair-max-diff-tm)
	    shift
	    PRIMER_PAIR_MAX_DIFF_TM=$1
	    ;;
	--output_config_file)
	    shift
	    OUTPUT_CONFIG_FILE=$1
	    ;;
	--filter_microsats)
	    shift
	    FILTERED_MICROSATS=$1
	    ;;
	-primers|-occurrences|-rankmotifs)
	    FILTER_OPTIONS="$FILTER_OPTIONS $1"
	    ;;
	-assembly)
	    FILTER_OPTIONS="$FILTER_OPTIONS $1"
	    shift
	    OUTPUT_ASSEMBLY=$1
	    ;;
	--subset)
	    shift
	    SUBSET=$1
	    ;;
	*)
	    echo Unknown option: $1 >&2
	    exit 1
	    ;;
    esac
    shift
done
#
# Check that primer3_core is available
got_primer3=`which $PRIMER3_CORE_EXE 2>&1 | grep -v "no primer3_core in"`
if [ -z "$got_primer3" ] ; then
  fatal "primer3_core not found"
fi
#
# Set up the working dir
if [ "$PLATFORM" == "Illumina" ] ; then
    # Paired end Illumina data as input
    if [ $FASTQ_R1 == $FASTQ_R2 ] ; then
	fatal ERROR R1 and R2 fastqs are the same file
    fi
    ln -s $FASTQ_R1
    ln -s $FASTQ_R2
    fastq_r1=$(basename $FASTQ_R1)
    fastq_r2=$(basename $FASTQ_R2)
else
    # 454 data as input
    ln -s $FNA
    fna=$(basename $FNA)
fi
ln -s $PRIMER_MISPRIMING_LIBRARY
PRIMER_MISPRIMING_LIBRARY=$(basename $PRIMER_MISPRIMING_LIBRARY)
mkdir Output
#
# Use a subset of reads
if [ ! -z "$SUBSET" ] ; then
    echo "### Extracting subset of reads ###"
    $(dirname $0)/fastq_subset.py -n $SUBSET -s $RANDOM_SEED $fastq_r1 $fastq_r2
    fastq_r1="subset_r1.fq"
    fastq_r2="subset_r2.fq"
fi
#
# Copy in the default config.txt file
echo "### Creating config.txt file for pal_finder run ###"
/bin/cp $PALFINDER_DATA_DIR/config.txt .
#
# Update the config.txt file with new values
# Input files
set_config_value platform $PLATFORM config.txt
if [ "$PLATFORM" == "Illumina" ] ; then
    set_config_value inputFormat fastq config.txt
    set_config_value pairedEnd 1 config.txt
    set_config_value inputReadFile $fastq_r1 config.txt
    set_config_value pairedReadFile $fastq_r2 config.txt
else
    set_config_value inputFormat fasta config.txt
    set_config_value pairedEnd 0 config.txt
    set_config_value input454reads $fna config.txt
fi
# Output files
set_config_value MicrosatSumOut Output/microsat_summary.txt config.txt
set_config_value PALsummaryOut Output/PAL_summary.txt config.txt
# Microsat info
set_config_value 2merMinReps $MIN_2_MER_REPS config.txt
set_config_value 3merMinReps $MIN_3_MER_REPS config.txt
set_config_value 4merMinReps $MIN_4_MER_REPS config.txt
set_config_value 5merMinReps $MIN_5_MER_REPS config.txt
set_config_value 6merMinReps $MIN_6_MER_REPS config.txt
# Primer3 settings
set_config_value primer3input Output/pr3in.txt config.txt
set_config_value primer3output Output/pr3out.txt config.txt
set_config_value keepPrimer3files 1 config.txt
set_config_value primer3executable $PRIMER3_CORE_EXE config.txt
set_config_value prNamePrefix ${PRIMER_PREFIX}_ config.txt
set_config_value PRIMER_MISPRIMING_LIBRARY "$PRIMER_MISPRIMING_LIBRARY" config.txt
set_config_value PRIMER_OPT_SIZE "$PRIMER_OPT_SIZE" config.txt
set_config_value PRIMER_MIN_SIZE "$PRIMER_MIN_SIZE" config.txt
set_config_value PRIMER_MAX_SIZE "$PRIMER_MAX_SIZE" config.txt
set_config_value PRIMER_MIN_GC "$PRIMER_MIN_GC" config.txt
set_config_value PRIMER_MAX_GC "$PRIMER_MAX_GC" config.txt
set_config_value PRIMER_GC_CLAMP "$PRIMER_GC_CLAMP" config.txt
set_config_value PRIMER_MAX_END_GC "$PRIMER_MAX_END_GC" config.txt
set_config_value PRIMER_MIN_TM "$PRIMER_MIN_TM" config.txt
set_config_value PRIMER_MAX_TM "$PRIMER_MAX_TM" config.txt
set_config_value PRIMER_OPT_TM "$PRIMER_OPT_TM" config.txt
set_config_value PRIMER_PAIR_MAX_DIFF_TM "$PRIMER_PAIR_MAX_DIFF_TM" config.txt
#
# Run pal_finder
echo "### Running pal_finder ###"
perl $PALFINDER_SCRIPT_DIR/pal_finder_v0.02.04.pl config.txt 1>pal_finder.log 2>&1
echo "### pal_finder finished ###"
#
# Handlers the pal_finder log file
echo "### Output from pal_finder ###"
if [ $(wc -l pal_finder.log | cut -d" " -f1) -gt $MAX_LINES ] ; then
    echo WARNING output too long, truncated to last $MAX_LINES lines:
    echo ...
fi
tail -$MAX_LINES pal_finder.log
#
# Check for success/failure
if [ ! -z "$(tail -n 1 pal_finder.log | grep 'No microsatellites found in any reads. Ending script.')" ] ; then
    # No microsatellites found
    fatal ERROR pal_finder failed to locate any microsatellites
    exit 1
elif [ -z "$(tail -n 1 pal_finder.log | grep Done!!)" ] ; then
    # Log doesn't end with "Done!!" (indicates failure)
    fatal ERROR pal_finder failed to complete successfully
fi
echo "### pal_finder finished ###"
#
# Check for errors in pal_finder output
echo "### Checking for errors ###"
if [ ! -z "$(grep 'primer3_core: Illegal element in PRIMER_PRODUCT_SIZE_RANGE' pal_finder.log)" ] ; then
    echo ERROR primer3 terminated prematurely due to bad product size ranges
    cat >&2 <<EOF
ERROR primer3 terminated prematurely due to bad product size ranges

Pal_finder generated bad ranges for the following read IDs:
EOF
    $(find_bad_primer_ranges Output/pr3in.txt) >&2
    cat >&2 <<EOF

This error can occur when input data contains short R1 reads and has
has not been properly trimmed and filtered.

EOF
    fatal pal_finder failed to complete successfully
EOF
fi
#
# Sort microsat_summary output
echo "### Sorting microsat summary output ###"
head -n 7 Output/microsat_summary.txt | sort >microsat_summary.sorted
grep "^$" Output/microsat_summary.txt>>microsat_summary.sorted
grep "^Microsat Type" Output/microsat_summary.txt >>microsat_summary.sorted
tail -n +11 Output/microsat_summary.txt >>microsat_summary.sorted
mv microsat_summary.sorted Output/microsat_summary.txt
#
# Sort PAL_summary output
echo "### Sorting PAL summary output ###"
head -1 Output/PAL_summary.txt > Output/PAL_summary.sorted.txt
if [ "$PLATFORM" == "Illumina" ] ; then
    grep -v "^readPairID" Output/PAL_summary.txt | sort -k 1 >> Output/PAL_summary.sorted.txt
else
    grep -v "^SequenceID" Output/PAL_summary.txt | sort -k 1 >> Output/PAL_summary.sorted.txt
fi
mv Output/PAL_summary.sorted.txt Output/PAL_summary.txt
#
# Run the filtering & assembly script
if [ ! -z "$FILTERED_MICROSATS" ] || [ ! -z "$OUTPUT_ASSEMBLY" ] ; then
    echo "### Running filtering & assembly script ###"
    python $PALFINDER_FILTER -i $fastq_r1 -j $fastq_r2 -p Output/PAL_summary.txt $FILTER_OPTIONS 1>pal_filter.log 2>&1
    echo "### Output from pal_filter ###"
    if [ $(wc -l pal_filter.log | cut -d" " -f1) -gt $MAX_LINES ] ; then
	echo WARNING output too long, truncated to last $MAX_LINES lines:
	echo ...
    fi
    tail -$MAX_LINES pal_filter.log
    if [ $? -ne 0 ] ; then
	fatal $PALFINDER_FILTER exited with non-zero status
    elif [ ! -f PAL_summary.filtered ] ; then
	fatal no output from $PALFINDER_FILTER
    fi
fi
#
# Clean up
echo "### Handling output files ###"
if [ -f Output/microsat_summary.txt ] ; then
    /bin/mv Output/microsat_summary.txt $MICROSAT_SUMMARY
fi
if [ -f Output/PAL_summary.txt ] ; then
    /bin/mv Output/PAL_summary.txt $PAL_SUMMARY
fi
if [ ! -z "$FILTERED_MICROSATS" ] && [ -f PAL_summary.filtered ] ; then
    /bin/mv PAL_summary.filtered $FILTERED_MICROSATS
fi
if [ ! -z "$OUTPUT_ASSEMBLY" ] ; then
    assembly=${fastq_r1%.*}_pal_filter_assembly_output.txt
    if [ -f "$assembly" ] ; then
	/bin/mv $assembly "$OUTPUT_ASSEMBLY"
    else
	fatal no assembly output found
    fi
fi
if [ ! -z "$OUTPUT_CONFIG_FILE" ] && [ -f config.txt ] ; then
    /bin/mv config.txt $OUTPUT_CONFIG_FILE
fi
#
echo "### Pal_finder tool completed ###"
##
#
