#!/bin/sh -e
#
# Wrapper script to run weeder2 as a Galaxy tool
#
# Usage: weeder_wrapper.sh FASTA_IN SPECIES_CODE FREQFILES_DIR MOTIFS_OUT MATRIX_OUT [ ARGS... ]
#
# ARGS: one or more arguments to supply directly to weeder2
#
# Process command line
FASTA_IN=$1
SPECIES_CODE=$2
FREQFILES_DIR=$3
MOTIFS_OUT=$4
MATRIX_OUT=$5
#
# Other arguments
ARGS=""
while [ ! -z "$6" ] ; do
    ARGS="$ARGS $6"
    shift
done
#
# Link to input file
ln -s $FASTA_IN
#
# Locate the FreqFiles directory
if [ $FREQFILES_DIR == "." ] ; then
    # Don't explicitly set the location - Weeder2 from
    # bioconda handles this automatically
    freqfiles_dir=
else
    # Alternative location
    freqfiles_dir=$FREQFILES_DIR
fi
#
# Link to the FreqFiles directory as weeder2 executable
# expects it to be the same directory
if [ ! -z "$freqfiles_dir" ] ; then
    if [ -d $freqfiles_dir ] ; then
	echo "Linking to FreqFiles directory: $freqfiles_dir"
	ln -s $freqfiles_dir FreqFiles
    else
	echo "ERROR FreqFiles directory not found" >&2
	exit 1
    fi
else
    echo "WARNING FreqFiles directory not set" >&2
fi
#
# Construct names of input and output files
fasta=$(basename $FASTA_IN)
motifs_out=${fasta}.w2
matrix_out=${fasta}.matrix.w2
#
# Construct and run weeder command
# NB weeder logs output to stderr so redirect to stdout
# to prevent the Galaxy tool reporting failure
weeder_cmd="weeder2 -f $fasta -O $SPECIES_CODE $ARGS"
echo "Running $weeder_cmd"
$weeder_cmd 2>&1
status=$?
if [ $status -ne 0 ] ; then
    echo weeder2 command finished with nonzero exit code $status >&2
    echo Command was: $weeder_cmd
    exit $status
fi
#
# Move outputs to final destinations
if [ -e $motifs_out ] ; then
    /bin/mv $motifs_out $MOTIFS_OUT
else
    echo ERROR missing output file: $motifs_out >&2
    status=1
fi
if [ -e $matrix_out ] ; then
    /bin/mv $matrix_out $MATRIX_OUT
else
    echo ERROR missing output file: $matrix_out >&2
    status=1
fi
#
# Done
exit $status
