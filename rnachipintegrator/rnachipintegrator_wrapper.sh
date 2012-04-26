#!/bin/sh
#
# Wrapper script to run RnaChipIntegrator as a Galaxy tool
#
# usage: sh rnachipintegrator_wrapper.sh [OPTIONS] <rnaseq_in> <chipseq_in> --output <xls_out>
#
echo RnaChipIntegrator: analyse gene expression and ChIP data
#
# Collect command line options
opts=
output_xls=
while [ ! -z "$1" ] ; do
    if [ "$1" == "--output" ] ; then
	shift; output_xls=$1
    else
	opts="$opts $1"
    fi
    shift
done 
#
# Run RnaChipIntegrator
# NB append stderr to stdout otherwise Galaxy job will fail
# Direct output to a temporary directory
log=`mktemp`
outdir=`mktemp -d`
base_name=galaxy
cmd="RnaChipIntegrator.py --project=${outdir}/${base_name} $opts"
echo $cmd
$cmd > $log 2>&1
#
# Check exit code
if [ "$?" -ne "0" ] ; then
    echo RnaChipIntegrator exited with non-zero status
    echo Output:
    cat $log
    # Clean up and exit
    /bin/rm -f $log
    /bin/rm -rf $outdir
    exit $?
fi
#
# Only output the XLS file for now
if [ -f "${outdir}/${base_name}.xls" ] ; then
    /bin/mv ${outdir}/${base_name}.xls $output_xls
else
    echo No file ${outdir}/${base_name}.xls
    cat $log
    # Clean up and exit
    /bin/rm -f $log
    /bin/rm -rf $outdir
    exit 1
fi
#
# Clean up
/bin/rm -f $log
/bin/rm -rf $outdir
#
# Done
