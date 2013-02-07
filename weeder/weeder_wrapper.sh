#!/bin/sh -e
#
# Run weeder in Galaxy
#
# Input and output file names
echo $*
pwd
FASTA_IN=$1
MIX_OUT=$2
WEE_OUT=$3
#
# Other arguments
ARGS=""
while [ ! -z "$4" ] ; do
    ARGS="$ARGS $4"
    shift
done
#
# Link to input file
ln -s $FASTA_IN
#
# Link to the weeder programs
# This hack is ugly but seems to be necessary in order to get
# weeder to run
ln -s /usr/bin/weederlauncher.out
ln -s /usr/bin/weederTFBS.out
ln -s /usr/bin/adviser.out
#
# Construct names of input and output files
fasta=`basename $FASTA_IN`
mix=$fasta.mix
wee=$fasta.wee
#
# Construct and run weeder command
# NB weeder logs output to stderr error so redirect to stdout
# to prevent the Galaxy tool reporting failure
weeder_cmd="./weederlauncher.out $fasta $ARGS"
echo "$weeder_cmd"
$weeder_cmd 2>&1
#
# Move outputs to final destinations
if [ -e $mix ] ; then
    /bin/mv $mix $MIX_OUT
fi
if [ -e $wee ] ; then
    /bin/mv $wee $WEE_OUT
fi
#
# Done
