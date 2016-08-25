#!/bin/sh
#
# Wrapper script to run RnaChipIntegrator as a Galaxy tool
#
# usage: sh rnachipintegrator_wrapper.sh [OPTIONS] <rnaseq_in> <chipseq_in> --output_xls <xls_out>
#
echo RnaChipIntegrator: analyse gene and peak data
#
# Collect command line options
opts=
xlsx_file=
zip_file=
gene_centric=
peak_centric=
gene_centric_summary=
peak_centric_summary=
while [ ! -z "$1" ] ; do
    case $1 in
	--xlsx_file)
	    shift; xlsx_file=$1
	    opts="$opts --xlsx"
	    ;;
	--output_files)
	    shift; gene_centric=$1
	    shift; peak_centric=$1
	    ;;
	--summary_files)
	    shift; gene_centric_summary=$1
	    shift; peak_centric_summary=$1
	    opts="$opts --summary"
	    ;;
	--zip_file)
	    shift; zip_file=$1
	    ;;
	*)
	    opts="$opts $1"
	    ;;
    esac
    shift
done 
#
# Run RnaChipIntegrator
# NB append stderr to stdout otherwise Galaxy job will fail
# Direct output to a temporary directory
outdir=$(mktemp -d)
base_name=galaxy
cmd="RnaChipIntegrator --name=${outdir}/${base_name} $opts"
echo $cmd
$cmd 2>&1
#
# Check exit code
exit_status=$?
if [ "$exit_status" -ne "0" ] ; then
    echo RnaChipIntegrator exited with non-zero status >&2
    # Clean up and exit
    /bin/rm -rf $outdir
    exit $exit_status
fi
#
# Deal with output XLSX file
if [ -f "${outdir}/${base_name}.xlsx" ] ; then
    /bin/mv ${outdir}/${base_name}.xlsx $xlsx_file
else
    echo No file ${outdir}/${base_name}.xlsx >&2
    # Clean up and exit
    /bin/rm -rf $outdir
    exit 1
fi
#
# Generate zip file
if [ ! -z "$zip_file" ] ; then
    for ext in \
	gene_centric \
	gene_centric_summary \
	peak_centric \
	peak_centric_summary ; do
	txt_file=${outdir}/${base_name}_${ext}.txt
	if [ -f "$txt_file" ] ; then
	    zip -j -g ${outdir}/archive.zip $txt_file
	fi
    done
    /bin/mv ${outdir}/archive.zip $zip_file
fi
#
# Collect tab delimited files
for ext in \
    gene_centric \
    gene_centric_summary \
    peak_centric \
    peak_centric_summary ; do
    eval dest=\$$ext
    if [ ! -z "$dest" ] ; then
	outfile=${outdir}/${base_name}_${ext}.txt
	if [ -f "$outfile" ] ; then
	    /bin/mv $outfile $dest
	else
	    echo ERROR missing output file $outfile >&2
	fi
    fi
done
#
# Clean up
/bin/rm -rf $outdir
#
# Done
