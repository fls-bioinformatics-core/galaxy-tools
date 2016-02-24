#!/bin/sh -fe
#
# usage: sh qc_boxplotter.sh <qual_in> <seq_order_boxplot_pdf_out> <seq_order_boxplot_png_out>
#
echo QC Boxplotter: generate QC boxplot
#
# Make a link to the input file in the current directory
ln -s $1
qual=`basename $1`
#
# Run qc_boxplotter
qc_boxplotter.sh $qual
#
# Outputs are <qual_in>_seq-order_boxplot.pdf and
# <qual_in>_seq-order_boxplot.png
#
# check these exist and rename to supplied arguments
boxplot_pdf=${qual}_seq-order_boxplot.pdf
if [ -f "$boxplot_pdf" ] ; then
    echo Move $boxplot_pdf to $2
    /bin/mv $boxplot_pdf $2
else
    echo Can\'t find $boxplot_pdf
fi
boxplot_png=${qual}_seq-order_boxplot.png
if [ -f "$boxplot_png" ] ; then
    echo Move $boxplot_png to $3
    /bin/mv $boxplot_png $3
else
    echo Can\'t find $boxplot_png
fi
#
# There are also corresponding .ps files that we'll delete
if [ -f "${qual}_seq-order_boxplot.ps" ] ; then
    /bin/rm -f ${qual}_seq-order_boxplot.ps
fi
#
# Done
