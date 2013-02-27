#!/bin/sh
#
# pal_finder_wrapper.sh: run pal_finder perl script as a Galaxy tool
#
# Usage: run_palfinder.sh FASTQ_R1 FASTQ_R2 MICROSAT_SUMMARY PAL_SUMMARY [OPTIONS]
#
# Options:
#
# --primer-prefix PREFIX: prefix added to the beginning of all primer names (prPrefixName)
# --2merMinReps N: miniumum number of 2-mer repeat units to detect (0=ignore units of this size)
# --3merMinReps N
# --4merMinReps N
# --5merMinReps N
# --6merMinReps N
# --primer-min-tm VALUE: minimum acceptable melting temperature (Celsius) for a primer oligo
# --output_config_file FNAME: write a copy of the config.txt file to FNAME
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
echo $*
#
# Initialise locations of scripts, data and executables
#
# Set these in the environment to overide at execution time
: ${PALFINDER_SCRIPT_DIR:=/usr/bin}
: ${PALFINDER_DATA_DIR:=/usr/share/pal_finder_v0.02.04}
: ${PRIMER3_CORE_EXE:=primer3_core}
#
# Initialise parameters used in the config.txt file
PRIMER_PREFIX="test"
MIN_2_MER_REPS=6
MIN_3_MER_REPS=0
MIN_4_MER_REPS=0
MIN_5_MER_REPS=0
MIN_6_MER_REPS=0
PRIMER_MISPRIMING_LIBRARY=$PALFINDER_DATA_DIR/simple.ref
PRIMER_MIN_TM=
OUTPUT_CONFIG_FILE=
#
# Collect command line arguments
if [ $# -lt 2 ] ; then
  echo "Usage: $0 FASTQ_R1 FASTQ_R2 MICROSAT_SUMMARY PAL_SUMMARY [OPTIONS]"
  exit
fi
FASTQ_R1=$1
FASTQ_R2=$2
MICROSAT_SUMMARY=$3
PAL_SUMMARY=$4
#
# Collect command line options
while [ ! -z "$5" ] ; do
    case "$5" in
	--primer-prefix)
	    shift
	    PRIMER_PREFIX=$5
	    ;;
	--2merMinReps)
	    shift
	    MIN_2_MER_REPS=$5
	    ;;
	--3merMinReps)
	    shift
	    MIN_3_MER_REPS=$5
	    ;;
	--4merMinReps)
	    shift
	    MIN_4_MER_REPS=$5
	    ;;
	--5merMinReps)
	    shift
	    MIN_5_MER_REPS=$5
	    ;;
	--6merMinReps)
	    shift
	    MIN_6_MER_REPS=$5
	    ;;
	--primer-mispriming-library)
	    shift
	    PRIMER_MISPRIMING_LIBRARY=$5
	    ;;
	--primer-min-tm)
	    shift
	    PRIMER_MIN_TM=$5
	    ;;
	--output_config_file)
	    shift
	    OUTPUT_CONFIG_FILE=$5
	    ;;
	*)
	    echo Unknown option: $5 >&2
	    exit 1
	    ;;
    esac
    shift
done
#
# Check that primer3_core is available
got_primer3=`which $PRIMER3_CORE_EXE 2>&1 | grep -v "no primer3_core in"`
if [ -z "$got_primer3" ] ; then
  echo ERROR primer3_core not found
  exit 1
fi
#
# Set up the working dir
ln -s $FASTQ_R1
ln -s $FASTQ_R2
mkdir Output
fastq_r1=`basename $FASTQ_R1`
fastq_r2=`basename $FASTQ_R2`
#
# Copy in the default config.txt file
/bin/cp $PALFINDER_DATA_DIR/config.txt .
#
# Update the config.txt file with new values
function set_config_value() {
    local key=$1
    local value=$2
    local config_txt=$3
    echo Setting "$key" to "$value"
    sed -i 's,^'"$key"' .*,'"$key"'  '"$value"',' $config_txt
}
# Input files
set_config_value inputReadFile $fastq_r1 config.txt
set_config_value pairedReadFile $fastq_r2 config.txt
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
set_config_value primer3executable $PRIMER3_CORE_EXE config.txt
set_config_value prNamePrefix ${PRIMER_PREFIX}_ config.txt
set_config_value PRIMER_MISPRIMING_LIBRARY $PRIMER_MISPRIMING_LIBRARY config.txt
if [ ! -z "$PRIMER_MIN_TM" ] ; then
    set_config_value PRIMER_MIN_TM $PRIMER_MIN_TM config.txt
fi
#
# Run pal_finder
perl $PALFINDER_SCRIPT_DIR/pal_finder_v0.02.04.pl config.txt 2>&1
#
# Clean up
if [ -f Output/microsat_summary.txt ] ; then
    /bin/mv Output/microsat_summary.txt $MICROSAT_SUMMARY
fi
if [ -f Output/PAL_summary.txt ] ; then
    /bin/mv Output/PAL_summary.txt $PAL_SUMMARY
fi
if [ ! -z "$OUTPUT_CONFIG_FILE" ] && [ -f config.txt ] ; then
    /bin/mv config.txt $OUTPUT_CONFIG_FILE
fi
##
#
