#!/bin/sh -e
#
# Wrapper script to run weeder as a Galaxy tool
#
# Usage: weeder_wrapper.sh FASTA_IN MIX_OUT WEE_OUT MATRICES_ALL MATRICES_BEST [ ARGS... ]
#
# ARGS: one or more arguments to supply directly to weeder
#
# Process command line
FASTA_IN=$1
MIX_OUT=$2
WEE_OUT=$3
MATRICES_ALL=$4
MATRICES_BEST=$5
MEME_ALL=
MEME_BEST=
#
# Other arguments
ARGS=""
weeder2meme=
while [ ! -z "$6" ] ; do
    if [ "$6" == "--weeder2meme" ] ; then
	weeder2meme=yes
	shift; MEME_ALL=$6
	shift; MEME_BEST=$6
    else
	ARGS="$ARGS $6"
    fi
    shift
done
#
# Tool directory i.e. location where this script is held
# Need this to locate the supplementary perl script
TOOL_DIR=`dirname $0`
#
# Link to input file
ln -s $FASTA_IN
#
# Locate the weeder programs and make links to them in the
# working directory - this hack is ugly but seems to be
# necessary in order to get the weeder pipeline to run
for prog in weederlauncher.out weederTFBS.out adviser.out ; do
    if [ -x $WEEDER_DIR/bin/$prog ] ; then
	echo "Linking to $prog"
	ln -s $WEEDER_DIR/bin/$prog
    else
	echo "ERROR $0 cannot locate executable for $prog" >&2
	exit 1
    fi
done
#
# Link to the FreqFiles directory as weeder executables
# expect it to be the same directory
freqfiles_dir=$WEEDER_FREQFILES_DIR
if [ -d $freqfiles_dir ] ; then
    echo "Linking to FreqFiles directory"
    ln -s $freqfiles_dir FreqFiles
else
    echo "ERROR FreqFiles directory not found" >&2
    exit 1
fi
#
# Construct names of input and output files
fasta=`basename $FASTA_IN`
mix=$fasta.mix
wee=$fasta.wee
#
# Construct and run weeder command
# NB weeder logs output to stderr eso redirect to stdout
# to prevent the Galaxy tool reporting failure
weeder_cmd="./weederlauncher.out $fasta $ARGS"
echo "Running $weeder_cmd"
$weeder_cmd 2>&1 | tee weeder.log
#
# NB advisor.out is started as a background process (why???)
# so keep checking the log file - when we encounter
# "Job completed" then the process has finished
running=
while [ -z "$running" ] ; do
    running=`tail weeder.log | grep "Job completed"`
    sleep 5s
done
#
# Extract matrices
if [ -e $wee ] ; then
    perl ${TOOL_DIR}/ExtractWeederMatrices.pl $wee
fi
#
# Also convert outputs to MEME format
if [ "$weeder2meme" == "yes" ] ; then
    # Construct expected names
    meme_all=${fasta}_all.meme
    meme_best=${fasta}_best.meme
    # Set up PERL5LIB to locate Perl modules for weeder2meme
    if [ ! -z "$PERL5LIB" ] ; then
	export PERL5LIB=$PERL5LIB:$TOOL_DIR/lib
    else
	export PERL5LIB=$TOOL_DIR/lib
    fi
    # Run the weeder2meme program
    weeder2meme_cmd="$TOOL_DIR/weeder2meme -i $wee -o $fasta"
    echo "Running $weeder2meme_cmd"
    $weeder2meme_cmd 2>&1
fi
#
# Move outputs to final destinations
if [ -e $mix ] ; then
    /bin/mv $mix $MIX_OUT
fi
if [ -e $wee ] ; then
    /bin/mv $wee $WEE_OUT
fi
if [ -e ${wee}_ALL_matrix.txt ] ; then
    /bin/mv ${wee}_ALL_matrix.txt $MATRICES_ALL
fi
if [ -e ${wee}_BEST_matrix.txt ] ; then
    /bin/mv ${wee}_BEST_matrix.txt $MATRICES_BEST
fi
if [ "$weeder2meme" == "yes" ] ; then
    if [ -e ${meme_all} ] ; then
	/bin/mv ${meme_all} $MEME_ALL
    fi
    if [ -e ${meme_best} ] ; then
	/bin/mv ${meme_best} $MEME_BEST
    fi
fi
#
# Done
