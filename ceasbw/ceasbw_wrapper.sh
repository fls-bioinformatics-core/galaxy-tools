#!/bin/sh -e
#
# Wrapper script to run CEASbw as a Galaxy tool
#
# Usage: ceasbw_wrapper.sh $BED_IN $GDB_IN $BIGWIG_IN $EXTRA_BED_IN $LOG_OUT $PDF_OUT $XLS_OUT $DBKEY
#
# Process command line
echo $*
BED_IN=$1
GDB_IN=$2
BIGWIG_IN=$3
EXTRA_BED_IN=$4
LOG_OUT=$5
PDF_OUT=$6
XLS_OUT=$7
#
# Collect remaining args
OPTIONS=
while [ ! -z "$8" ] ; do
    OPTIONS="$OPTIONS $8"
    shift
done
#
# Convenience variables for local files
base_name="ceas"
log_file=${base_name}.log
r_script=${base_name}.R
pdf_report=${base_name}.pdf
xls_file=${base_name}.xls
#
# Get CEAS version
ceasBW --version >$log_file 2>/dev/null
#
# Construct and run CEAS command line
ceas_cmd="ceasBW --name $base_name $OPTIONS -g $GDB_IN -b $BED_IN"
if [ "$BIGWIG_IN" != "None" ] ; then
    ceas_cmd="$ceas_cmd --bigwig $BIGWIG_IN"
fi
if [ "$EXTRA_BED_IN" != "None" ] ; then
    ceas_cmd="$ceas_cmd -e $EXTRA_BED_IN"
fi
echo "Running $ceas_cmd"
$ceas_cmd >>$log_file 2>&1
#
# Move outputs to final destination
if [ -e $log_file ] ; then
    echo "Moving $log_file to $LOG_OUT"
    /bin/mv $log_file $LOG_OUT
else
    echo ERROR failed to make log file >&2
    exit 1
fi
if [ -e $xls_file ] ; then
    echo "Moving $xls_file to $XLS_OUT"
    /bin/mv $xls_file $XLS_OUT
else
    echo ERROR failed to generate XLS file >&2
    exit 1
fi
#
# Run the R script to generate the PDF report
if [ -e $r_script ] ; then
    echo "Running $r_script to generate $pdf_report"
    R --vanilla < $r_script
    if [ -e $pdf_report ] ; then
	echo "Moving $xls_file to $XLS_OUT"
	/bin/mv $pdf_report $PDF_OUT
    else
	echo ERROR failed to generate PDF report >&2
	exit 1
    fi
else
    echo ERROR no R script to generate PDF report >&2
    exit 1
fi
#
# Done
