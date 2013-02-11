#!/bin/sh -e
#
# Wrapper script to run CEAS as a Galaxy tool
#
# Usage: ceas_wrapper.sh $BED_IN $GDB_IN $WIG_IN $EXTRA_BED_IN $LOG_OUT $PDF_OUT
#
# Process command line
echo $*
BED_IN=$1
GDB_IN=$2
WIG_IN=$3
EXTRA_BED_IN=$4
LOG_OUT=$5
PDF_OUT=$6
#
# Collect remaining args
OPTIONS=
while [ ! -z "$7" ] ; do
    OPTIONS="$OPTIONS $7"
    shift
done
#
# Convenience variables for local files
base_name="ceas"
log_file=${base_name}.log
r_script=${base_name}.R
pdf_report=${base_name}.pdf
#
# Get CEAS version
ceas --version > $log_file
#
# Construct and run CEAS command line
ceas_cmd="ceas --name $base_name $OPTIONS -g $GDB_IN -b $BED_IN"
if [ "$WIG_IN" != "None" ] ; then
    ceas_cmd="$ceas_cmd -w $WIG_IN"
fi
if [ "$EXTRA_BED_IN" != "None" ] ; then
    ceas_cmd="$ceas_cmd -e $EXTRA_BED_IN"
fi
echo "Running $ceas_cmd"
$ceas_cmd >> $log_file 2>&1
#
# Run the R script to generate the PDF report
if [ -e $r_script ] ; then
    echo "Running $r_script to generate $pdf_report"
    R --vanilla < $r_script
fi
#
# Move outputs to final destination
if [ -e $log_file ] ; then
    echo "Moving $log_file to $LOG_OUT"
    /bin/mv $log_file $LOG_OUT
fi
if [ -e $pdf_report ] ; then
    echo "Moving $pdf_report to $PDF_OUT"
    /bin/mv $pdf_report $PDF_OUT
fi
#
# Done
