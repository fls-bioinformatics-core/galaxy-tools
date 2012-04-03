#!/bin/sh
#
# Wrapper script to run FastQScreen program as a Galaxy tool
#
# The wrapper is needed for two reasons:
#
# 1. To trap for fastq_screen writing to stderr (which otherwise makes
#    Galaxy think that the tool run has failed); and
# 2. To rename the auto-generated output file names to file names
#    chosen by Galaxy.
#
# usage: sh fastq_screen.sh <fastq_in> <conf_file> <screen_txt_out> <screen_png_out>
#
# Note that this wrapper assumes:
#
# 1. The version of fastq_screen supports --color and --multilib
#    options; and
# 2. The conf file specifies colorspace bowtie indexes.
#
echo FastQ Screen: check for contaminants
#
# Run fastq screen
# NB append stderr to stdout otherwise Galaxy job will fail
# (Could be mitigated by using --quiet option?)
# Direct output to a temporary file
log=`mktemp`
outdir=`mktemp -d`
fastq_screen --outdir $outdir --conf $2 --color --multilib $1 > $log 2>&1
#
# Check exit code
if [ "$?" -ne "0" ] ; then
    echo FastQ Screen exited with non-zero status
    echo Output:
    cat $log
    # Clean up and exit
    /bin/rm -f $log
    /bin/rm -rf $outdir
    exit $?
fi
#
# Outputs are <fastq_in>_screen.txt and <fastq_in>_screen.png
# check these exist and rename to supplied arguments
base_name=`basename $1`
if [ -f "${outdir}/${base_name}_screen.txt" ] ; then
    /bin/mv ${outdir}/${base_name}_screen.txt $3
else
    echo No file ${outdir}/${base_name}_screen.txt
    exit 1
fi
if [ -f "${outdir}/${base_name}_screen.png" ] && [ "$3" != "" ] ; then
    /bin/mv ${outdir}/${base_name}_screen.png $4
else
    echo No file ${outdir}/${base_name}_screen.png
    exit 1
fi
#
# Clean up
/bin/rm -f $log
/bin/rm -rf $outdir
#
# Done
