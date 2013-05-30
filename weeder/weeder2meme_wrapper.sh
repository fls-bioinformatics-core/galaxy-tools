#!/bin/sh -e
#
# Wrapper script to run weeder2meme as a Galaxy tool
#
# Usage: weeder2meme_wrapper.sh WEE_IN MEME_ALL MEME_BEST [ ARGS... ]
#
# ARGS: one or more arguments to supply directly to weeder2meme
#
# Process command line
WEE_IN=$1
MEME_ALL=$2
MEME_BEST=$3
#
# Other arguments
ARGS=""
while [ ! -z "$4" ] ; do
    ARGS="$ARGS $4"
    shift
done
#
# Tool directory i.e. location where this script is held
# Need this to locate the supplementary perl script
TOOL_DIR=`dirname $0`
#
# Set up PERL5LIB to locate Perl modules for weeder2meme
if [ ! -z "$PERL5LIB" ] ; then
    export PERL5LIB=$PERL5LIB:$TOOL_DIR/lib
else
    export PERL5LIB=$TOOL_DIR/lib
fi
#
# Construct expected names
base_name=$(basename $WEE_IN)
meme_all=${base_name}_all.meme
meme_best=${base_name}_best.meme
#
# Run the weeder2meme program
weeder2meme_cmd="$TOOL_DIR/weeder2meme -i $WEE_IN -o $base_name"
echo "Running $weeder2meme_cmd"
$weeder2meme_cmd 2>&1
#
# Move outputs to final destinations
if [ -e ${meme_all} ] ; then
    /bin/mv ${meme_all} $MEME_ALL
fi
if [ -e ${meme_best} ] ; then
    /bin/mv ${meme_best} $MEME_BEST
fi
##
#