#!/bin/sh -e
#
# Wrapper script to run CEAS as a Galaxy tool
#
# This runs the Cistrome versions of CEAS, which provides two executables:
# - ceas (same as the "official" version)
# - ceasBW (modified version that accepts a bigwig file as input)
#
# Usage: ceas_wrapper.sh $BED_IN $GDB_IN $EXTRA_BED_IN $LOG_OUT $PDF_OUT $XLS_OUT $DBKEY
#
# Process command line
echo $*
BED_IN=$1
GDB_IN=$2
EXTRA_BED_IN=$3
LOG_OUT=$4
PDF_OUT=$5
XLS_OUT=$6
#
# Collect remaining args
CEAS=ceas
OPTIONS=
while [ ! -z "$7" ] ; do
    if [ "$7" == "--bigwig" ] ; then
	CEAS=ceasBW
    fi
    if [ "$7" == "--length" ] ; then
	chrom_sizes=$8
	if [ ! -f "$chrom_sizes" ] ; then
	    echo "ERROR no file $chrom_sizes" >&2
	    echo "Please update your Galaxy instance to include this file"
	    exit 1
	fi
    fi
    OPTIONS="$OPTIONS $7"
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
echo Running $CEAS
$CEAS --version >$log_file 2>/dev/null
#
# Construct and run CEAS command line
ceas_cmd="$CEAS --name $base_name $OPTIONS -g $GDB_IN -b $BED_IN"
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
