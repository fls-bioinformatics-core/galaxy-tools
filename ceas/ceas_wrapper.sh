#!/bin/sh -e
#
# Wrapper script to run CEAS as a Galaxy tool
#
# This runs the Cistrome versions of CEAS, which provides two executables:
# - ceas (same as the "official" version)
# - ceasBW (modified version that accepts a bigwig file as input)
#
# Usage: ceas_wrapper.sh $BED_IN $GDB_IN $LOG_OUT $PDF_OUT $XLS_OUT [OPTIONS]
#
# Initialise
CEAS=ceas
#
# Process command line
echo $*
BED_IN=$1
GDB_IN=$2
LOG_OUT=$3
PDF_OUT=$4
XLS_OUT=$5
#
# Initialise other variables
EXTRA_BED_IN=
#
# Collect remaining args
OPTIONS=
while [ ! -z "$6" ] ; do
    if [ "$6" == "--bigwig" ] ; then
	# Bigwig input, need to use 'ceasBW'
	CEAS=ceasBW
	OPTIONS="$OPTIONS --bigwig"
    elif [ "$6" == "--length" ] ; then
	# Need a chrom sizes file
	chrom_sizes=$7
	if [ ! -f "$chrom_sizes" ] ; then
	    # If chrom sizes file doesn't already exist then attempt to
	    # download the data from UCSC
	    echo "WARNING no file $chrom_sizes"
	    dbkey=$(echo $(basename $chrom_sizes) | cut -d'.' -f1)
	    if [ $dbkey == '?' ] ; then
		# DBkey not set, this is fatal
		echo "ERROR genome build not set, cannot get sizes for '?'" >&2
		echo "Assign a genome build to your input dataset and rerun" >&2
		exit 1
	    fi
	    # Fetch the sizes using fetchChromSizes
	    echo "Attempting to download chromosome sizes for $dbkey"
	    chrom_sizes=$(basename $chrom_sizes)
	    fetchChromSizes $dbkey >$chrom_sizes 2>/dev/null
	    if [ $? -ne 0 ] ; then
		echo "ERROR unable to fetch data for ${dbkey}" >&2
		echo "Please check the genome build associated with your input dataset" >&2
		echo "or update your Galaxy instance to include an appropriate .len file" >&2
		exit 1
	    fi
	fi
	OPTIONS="$OPTIONS --length $chrom_sizes"
	shift
    else
	OPTIONS="$OPTIONS $6"
    fi
    shift
done
#
# Convenience variables for local files
base_name="ceas"
log_file=${base_name}.log
pdf_report=${base_name}.pdf
xls_file=${base_name}.xls
#
# Get CEAS version
echo Running $CEAS
$CEAS --version >$log_file 2>/dev/null
#
# Construct and run CEAS command line
ceas_cmd="$CEAS --name $base_name $OPTIONS -g $GDB_IN -b $BED_IN"
echo "Running $ceas_cmd"
$ceas_cmd >>$log_file 2>&1
status=$?
if [ $status -ne 0 ] ; then
    echo "ERROR $CEAS exited with non-zero code: $status" >&2
    exit $status
fi
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
if [ -e $pdf_report ] ; then
    echo "Moving $pdf_report to $PDF_OUT"
    /bin/mv $pdf_report $PDF_OUT
else
    echo ERROR failed to generate PDF report >&2
    exit 1
fi
#
# Done
