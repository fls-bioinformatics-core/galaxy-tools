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
# usage: sh fastq_screen.sh OPTIONS <fastq_in> <conf_file> <screen_txt_out> <screen_png_out>
#
# Options:
#    --color: input is in colorspace format
#    --subset <n>: use a subset of <n> reads
#
# Note that this wrapper assumes:
#
# 1. The version of fastq_screen supports --color and --multilib
#    options; and
# 2. The conf file specifies colorspace bowtie indexes.
#
echo FastQ Screen: check for contaminants
#
# Check command line options
OPTS=
check_args=yes
while [ ! -z "$check_args" ] ; do
    if [ "$1" == "--color" ] ; then
	OPTS="$OPTS $1"
	shift
    elif [ "$1" == "--subset" ] ; then
	OPTS="$OPTS $1 $2"
	shift; shift
    else
	# End of options
	check_args=
    fi
done
#
# Check conf file exists
if [ ! -f "$2" ] ; then
    echo No conf file $2
    exit 1
fi
#
# Run fastq screen
# NB append stderr to stdout otherwise Galaxy job will fail
# (Could be mitigated by using --quiet option?)
# Direct output to a temporary file
outdir=`mktemp -d`
fastq_screen_cmd="fastq_screen --outdir $outdir --conf $2 $OPTS --multilib $1"
echo $fastq_screen_cmd
$fastq_screen_cmd 2>&1
#
# Check exit code
if [ "$?" -ne "0" ] ; then
    echo FastQ Screen exited with non-zero status
    # Clean up and exit
    /bin/rm -rf $outdir
    exit $?
fi
#
# Outputs are <fastq_in>_screen.txt and <fastq_in>_screen.png
# check these exist and rename to supplied arguments
base_name=`basename $1`
base_name=${base_name%.fastq}
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
/bin/rm -rf $outdir
#
# Done
