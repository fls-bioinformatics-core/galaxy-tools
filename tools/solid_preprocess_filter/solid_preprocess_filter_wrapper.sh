#!/bin/sh -e
#
# Wrapper script to run SOLiD_preprocess_filter as a Galaxy tool
#
# Usage: solid_preprocess_filter_wrapper.sh CSFASTA_IN QUAL_IN CSFASTA_OUT QUAL_OUT [ ARGS... ]
#
# ARGS: one or more arguments to supply directly to weeder
#
# Process command line
CSFASTA_IN=$1
QUAL_IN=$2
CSFASTA_OUT=$3
QUAL_OUT=$4
#
# Other arguments
ARGS=""
while [ ! -z "$5" ] ; do
    ARGS="$ARGS $5"
    shift
done
#
# Output file base name
output_basename=filter.out
#
# Construct and run SOLiD_preprocess_filter command
solid_preprocess_filter_cmd="SOLiD_preprocess_filter_v2.pl -f $CSFASTA_IN -g $QUAL_IN -o $output_basename $ARGS"
echo "Running $solid_preprocess_filter_cmd"
$solid_preprocess_filter_cmd
#
# Move outputs to final destinations
filter_csfasta=${output_basename}_T_F3.csfasta
if [ -f $filter_csfasta ] ; then
    /bin/mv $filter_csfasta $CSFASTA_OUT
else
    echo "No output CSFASTA file produced" >&2
    exit 1
fi
if [ -f ${output_basename}_QV_T_F3.qual ] ; then
    # Original form of output qual name
    filter_qual=${output_basename}_QV_T_F3.qual
elif [ -f ${output_basename}_T_F3_QV.qual ] ; then
    # Later version
    filter_qual=${output_basename}_T_F3_QV.qual
fi
if [ -f $filter_qual ] ; then
    /bin/mv $filter_qual $QUAL_OUT
else
    # Check for alternative format
    echo "No output QUAL file produced" >&2
    exit 1
fi
#
# Done 
