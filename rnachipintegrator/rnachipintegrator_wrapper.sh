#!/bin/sh
#
# Wrapper script to run RnaChipIntegrator as a Galaxy tool
#
# usage: sh rnachipintegrator_wrapper.sh <rnaseq_in> <chipseq_in> <xls_out>
#
echo RnaChipIntegrator: analyse gene expression and ChIP data
#
# Run RnaChipIntegrator
# NB append stderr to stdout otherwise Galaxy job will fail
# Direct output to a temporary directory
log=`mktemp`
outdir=`mktemp -d`
base_name=galaxy
RnaChipIntegrator.py --project=${outdir}/${base_name} $1 $2 > $log 2>&1
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
    /bin/mv ${outdir}/${base_name}.xls $3
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
