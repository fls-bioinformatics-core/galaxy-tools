#!/bin/sh -e
#
# Wrapper script to run CEAS as a Galaxy tool
#
# Usage: ceas_wrapper.sh $BED_IN $GDB_IN $WIG_IN $LOG_OUT $PDF_OUT $PNG_OUT
#
# Process command line
echo $*
BED_IN=$1
GDB_IN=$2
WIG_IN=$3
LOG_OUT=$4
PDF_OUT=$5
PNG_OUT=$6
#
# Construct and run CEAS command line
base_name="ceas"
ceas_cmd="ceas --name $base_name -g $GDB_IN -b $BED_IN"
if [ "$WIG_IN" != "None" ] ; then
    ceas_cmd="$ceas_cmd -w $WIG_IN"
fi
echo "Running $ceas_cmd"
$ceas_cmd > ${base_name}.log 2>&1
#
# Run the R script to generate the PDF report
if [ -e ${base_name}.R ] ; then
    echo "Running $base_name.R to generate $base_name.pdf"
    R --vanilla < ${base_name}.R
    # Make PNG version using ImageMagick's convert program
    convert ${base_name}.pdf ${base_name}_%04d.png
    convert ${base_name}_*.png -append ${base_name}.png
fi
#
# Move outputs to final destination
if [ -e ${base_name}.log ] ; then
    echo "Moving $base_name.log to $LOG_OUT"
    /bin/mv ${base_name}.log $LOG_OUT
fi
if [ -e ${base_name}.pdf ] ; then
    echo "Moving $base_name.pdf to $PDF_OUT"
    /bin/mv ${base_name}.pdf $PDF_OUT
fi
if [ -e ${base_name}.png ] ; then
    echo "Moving $base_name.pdf to $PNG_OUT"
    /bin/mv ${base_name}.png $PNG_OUT
fi
#
# Done
