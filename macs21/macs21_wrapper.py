#!/bin/env python
#
# Galaxy wrapper to run MACS 2.1
#
# Completely rewritten from the original macs2 wrapped by Ziru Zhou
# taken from http://toolshed.g2.bx.psu.edu/view/modencode-dcc/macs2

import sys
import os
import subprocess
import tempfile
import shutil

def move_file(working_dir,name,destination):
    """Move a file 'name' from 'working_dir' to 'destination'

    """
    if destination is None:
        # Nothing to do
        return
    source = os.path.join(working_dir,name)
    if os.path.exists(source):
        shutil.move(source,destination)

def convert_xls_to_interval(xls_file,interval_file,header=None):
    """Convert MACS XLS file to interval

    From the MACS readme: "Coordinates in XLS is 1-based which is different with
    BED format."

    However this function no longer performs any coordinate conversions, it
    simply ensures that any blank or non-data lines are commented out

    """
    fp = open(interval_file,'wb')
    if header:
        fp.write('#%s\n' % header)
    for line in open(xls_file):
        # Keep all existing comment lines
        if line.startswith('#'):
            fp.write(line)
        else:
            # Split line into fields and test to see if
            # the 'start' field is actually an integer
            fields = line.split('\t')
            if len(fields) > 1:
                try:
                    int(fields[1])
                except ValueError:
                    # Integer conversion failed so comment out
                    # "bad" line instead
                    fields[0] = "#%s" % fields[0]
            fp.write( '\t'.join( fields ) )
    fp.close()

def make_bigwig_from_bedgraph(bedgraph_file,bigwig_file,
                              chrom_size_file,working_dir=None):
    """Make bigWig file from a bedGraph

    The protocol is:

    $ fetchChromSizes.sh mm9 > mm9.chrom.sizes
    $ bedClip treat.bedgraph mm9.chrom.sizes treat.clipped
    $ bedGraphToBigWig treat.clipped mm9.chrom.sizes treat.bw

    Get the binaries from
    http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/

    We skip the fetchChromSizes step and assume that the
    chromosome sizes for the genome build in question are
    supplied via the 'chrom_size_file' argument.

    """
    print "Generating bigWig from bedGraph..."
    # Run bedClip
    treat_clipped = "%s.clipped" % os.path.basename(bedgraph_file)
    cmd = "bedClip %s %s %s" % (bedgraph_file,chrom_size_file,treat_clipped)
    print "Running %s" % cmd
    proc = subprocess.Popen(args=cmd,shell=True,cwd=working_dir)
    proc.wait()
    # Check that clipped file exists
    treat_clipped = os.path.join(working_dir,treat_clipped)
    if not os.path.exists(treat_clipped):
        sys.stderr.write("Failed to create clipped bed file")
        sys.exit(1)
    # Run bedGraphToBigWig
    cmd = "bedGraphToBigWig %s %s %s" % (treat_clipped,chrom_size_file,
                                         bigwig_file)
    print "Running %s" % cmd
    proc = subprocess.Popen(args=cmd,shell=True,cwd=working_dir)
    proc.wait()

if __name__ == "__main__":

    # Echo the command line
    print ' '.join(sys.argv)

    # Initialise output files - values are set by reading from
    # the command line supplied by the Galaxy wrapper
    output_extra_html = None
    output_extra_path = None
    output_broadpeaks = None
    output_gappedpeaks = None
    output_narrowpeaks = None
    output_treat_pileup = None
    output_lambda_bedgraph = None
    output_bigwig = None
    output_xls_to_interval_peaks_file = None
    output_peaks = None
    output_bdgcmp = None

    # Build the MACS 2.1 command line
    # Initial arguments are always the same: command & input ChIP-seq file name
    cmdline = ["macs2 %s -t %s" % (sys.argv[1],sys.argv[2])]

    # Process remaining args
    for arg in sys.argv[3:]:
        if arg.startswith('--format='):
            # Convert format to uppercase
            format_ = arg.split('=')[1].upper()
            cmdline.append("--format=%s" % format_)
        elif arg.startswith('--name='):
            # Replace whitespace in name with underscores
            experiment_name = '_'.join(arg.split('=')[1].split())
            cmdline.append("--name=%s" % experiment_name)
        elif arg.startswith('--length='):
            # Extract chromosome size file
            chrom_sizes = arg.split('=')[1]
        elif arg.startswith('--output-'):
            # Handle destinations for output files
            arg0,filen = arg.split('=')
            if arg0 == '--output-summits':
                output_summits = filen
            elif arg0 == '--output-extra-files':
                output_extra_html = filen
            elif  arg0 == '--output-extra-files-path':
                output_extra_path = filen
            elif  arg0 == '--output-broadpeaks':
                output_broadpeaks = filen
            elif  arg0 == '--output-gappedpeaks':
                output_gappedpeaks = filen
            elif  arg0 == '--output-narrowpeaks':
                output_narrowpeaks = filen
            elif  arg0 == '--output-pileup':
                output_treat_pileup = filen
            elif  arg0 == '--output-lambda-bedgraph':
                output_lambda_bedgraph = filen
            elif  arg0 == '--output-bigwig':
                output_bigwig = filen
            elif  arg0 == '--output-xls-to-interval':
                output_xls_to_interval_peaks_file = filen
            elif  arg0 == '--output-peaks':
                output_peaks = filen
        else:
            # Pass remaining args directly to MACS
            # command line
            cmdline.append(arg)
    
    cmdline = ' '.join(cmdline)
    print "Generated command line:\n%s" % cmdline

    # Execute MACS2
    #
    # Make a working directory
    working_dir = tempfile.mkdtemp()
    #
    # Collect stderr in a file for reporting later
    stderr_filen = tempfile.NamedTemporaryFile().name
    #
    # Run MACS2
    proc = subprocess.Popen(args=cmdline,shell=True,cwd=working_dir,
                            stderr=open(stderr_filen,'wb'))
    proc.wait()
    
    # Run R script to create PDF from model script
    if os.path.exists(os.path.join(working_dir,"%s_model.r" % experiment_name)):
        cmdline = 'R --vanilla --slave < "%s_model.r" > "%s_model.r.log"' % \
                  (experiment_name, experiment_name)
        proc = subprocess.Popen(args=cmdline,shell=True,cwd=working_dir)
        proc.wait()

    # Convert XLS to interval, if requested
    if output_xls_to_interval_peaks_file is not None:
        peaks_xls_file = os.path.join(working_dir,'%s_peaks.xls' % experiment_name )
        if os.path.exists(peaks_xls_file):
            convert_xls_to_interval(peaks_xls_file,output_xls_to_interval_peaks_file,
                                    header='peaks file')

    # Create bigWig from bedGraph, if requested
    if output_bigwig is not None:
        treat_bedgraph_file = os.path.join(working_dir,'%s_treat_pileup.bdg' % experiment_name)
        if os.path.exists(treat_bedgraph_file):
            make_bigwig_from_bedgraph(treat_bedgraph_file,output_bigwig,
                                      chrom_sizes,working_dir)
        
    # Move MACS2 output files from working dir to their final destinations
    move_file(working_dir,"%s_summits.bed" % experiment_name,output_summits)
    move_file(working_dir,"%s_peaks.xls" % experiment_name,output_peaks)
    move_file(working_dir,"%s_peaks.narrowPeak" % experiment_name,output_narrowpeaks)
    move_file(working_dir,"%s_peaks.broadPeak" % experiment_name,output_broadpeaks)
    move_file(working_dir,"%s_peaks.gappedPeak" % experiment_name,output_gappedpeaks)
    move_file(working_dir,"%s_treat_pileup.bdg" % experiment_name,output_treat_pileup)
    move_file(working_dir,"%s_control_lambda.bdg" % experiment_name,output_lambda_bedgraph)
    move_file(working_dir,"bdgcmp_out.bdg",output_bdgcmp)

    # Move remaining file to the 'extra files' path and link from the HTML
    # file to allow user to access them from within Galaxy
    html_file = open(output_extra_html,'wb')
    html_file.write('<html><head><title>Additional output created by MACS (%s)</title></head><body><h3>Additional Files:</h3><p><ul>\n' % experiment_name)
    # Make the 'extra files' directory
    os.mkdir(output_extra_path)
    # Move the files
    for filen in sorted(os.listdir(working_dir)):
        shutil.move(os.path.join(working_dir,filen),
                    os.path.join(output_extra_path,filen))
        html_file.write( '<li><a href="%s">%s</a></li>\n' % (filen,filen))
    # All files moved, close out HTML
    html_file.write( '</ul></p>\n' )
    # Append any stderr output
    html_file.write('<h3>Messages from MACS:</h3>\n<p><pre>%s</pre></p>\n' %
                    open(stderr_filen,'rb').read())
    html_file.write('</body></html>\n')
    html_file.close()

    # Clean up the working directory and files
    os.unlink(stderr_filen)
    os.rmdir(working_dir)
