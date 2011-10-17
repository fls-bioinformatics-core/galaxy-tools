#!/bin/sh -fe
#
# usage: sh qc_boxplotter.sh <qual_in> <seq_order_boxplot_pdf_out>
#
echo QC Boxplotter: generate QC boxplot
#
# Run qc_boxplotter
qc_boxplotter.sh $1
#
# Outputs are <qual_in>_seq-order_boxplot.pdf and
# <qual_in>_primer-order_boxplot.pdf
#
# check these exist and rename to supplied arguments
if [ -f "${1}_seq-order_boxplot.pdf" ] ; then
    echo Move ${1}_seq-order_boxplot.pdf to $2
    /bin/mv ${1}_seq-order_boxplot.pdf $2
else
    echo Can\'t find ${1}_seq-order_boxplot.pdf
fi
#
# There are also corresponding .ps files that we'll delete
if [ -f "${1}_seq-order_boxplot.ps" ] ; then
    /bin/rm -f ${1}_seq-order_boxplot.ps
fi
#
# Done
