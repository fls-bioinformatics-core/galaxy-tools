#!/bin/sh
#
# Wrapper script to run RnaChipIntegrator as a Galaxy tool
#
# usage: sh rnachipintegrator_wrapper.sh [OPTIONS] <rnaseq_in> <chipseq_in> --output_xls <xls_out>
#
echo RnaChipIntegrator: analyse gene expression and ChIP data
#
# Collect command line options
opts=
output_xls=
peaks_to_transcripts_out=
while [ ! -z "$1" ] ; do
    case $1 in
	--output_xls)
	    shift; output_xls=$1
	    ;;
	--summit_outputs)
	    shift; peaks_to_transcripts_out=$1
	    shift; tss_to_summits_out=$1
	    ;;
	--peak_outputs)
	    shift; transcripts_to_edges_out=$1
	    shift; transcripts_to_edges_summary=$1
	    shift; tss_to_edges_out=$1
	    shift; tss_to_edges_summary=$1
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
outdir=`mktemp -d`
base_name=galaxy
cmd="RnaChipIntegrator.py --project=${outdir}/${base_name} $opts"
echo $cmd
$cmd 2>&1
#
# Check exit code
if [ "$?" -ne "0" ] ; then
    echo RnaChipIntegrator exited with non-zero status
    # Clean up and exit
    /bin/rm -rf $outdir
    exit $?
fi
#
# Deal with output files - XLS
if [ -f "${outdir}/${base_name}.xls" ] ; then
    /bin/mv ${outdir}/${base_name}.xls $output_xls
else
    echo No file ${outdir}/${base_name}.xls
    # Clean up and exit
    /bin/rm -rf $outdir
    exit 1
fi
#
# Peaks to transcripts
if [ ! -z "$peaks_to_transcripts_out" ] ; then
    outfile=${outdir}/${base_name}_PeaksToTranscripts.txt
    if [ -f "$outfile" ] ; then
	/bin/mv $outfile $peaks_to_transcripts_out
    else
	echo No file $outfile
    fi
fi
#
# TSS to summits
if [ ! -z "$tss_to_summits_out" ] ; then
    outfile=${outdir}/${base_name}_TSSToSummits.txt
    if [ -f "$outfile" ] ; then
	/bin/mv $outfile $tss_to_summits_out
    else
	echo No file $outfile
    fi
fi
#
# Transcripts to Peak Edges
if [ ! -z "$transcripts_to_edges_out" ] ; then
    outfile=${outdir}/${base_name}_TranscriptsToPeakEdges.txt
    if [ -f "$outfile" ] ; then
	/bin/mv $outfile $transcripts_to_edges_out
    else
	echo No file $outfile
    fi
fi
if [ ! -z "$transcripts_to_edges_summary" ] ; then
    outfile=${outdir}/${base_name}_TranscriptsToPeakEdges_summary.txt
    if [ -f "$outfile" ] ; then
	/bin/mv $outfile $transcripts_to_edges_summary
    else
	echo No file $outfile
    fi
fi
#
# TSS to Peak Edges
if [ ! -z "$tss_to_edges_out" ] ; then
    outfile=${outdir}/${base_name}_TSSToPeakEdges.txt
    if [ -f "$outfile" ] ; then
	/bin/mv $outfile $tss_to_edges_out
    else
	echo No file $outfile
    fi
fi
if [ ! -z "$tss_to_edges_summary" ] ; then
    outfile=${outdir}/${base_name}_TSSToPeakEdges_summary.txt
    if [ -f "$outfile" ] ; then
	/bin/mv $outfile $tss_to_edges_summary
    else
	echo No file $outfile
    fi
fi
#
# Clean up
/bin/rm -rf $outdir
#
# Done
