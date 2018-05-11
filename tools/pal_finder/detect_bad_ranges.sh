#!/bin/bash
#
# Parses a pr3in.txt file from pal_finder and reports
# sequence ids where the PRIMER_PRODUCT_SIZE_RANGE has
# upper limit which is smaller than lower limit
#
# Loop over pairs of SEQUENCE_ID and PRIMER_PRODUCT_SIZE_RANGE
# keywords in the primer3 input
for line in $(grep -E "^(SEQUENCE_ID|PRIMER_PRODUCT_SIZE_RANGE)" $1 | sed 's/ /^/' | sed 'N;s/\n/*/') ; do
    # Extract the values
    if [ ! -z "$(echo $line | grep ^SEQUENCE_ID)" ] ; then
	primer_product_size_range=$(echo $line | cut -d'*' -f2 | cut -d'=' -f2 | tr '^' ' ')
	sequence_id=$(echo $line | cut -d'*' -f1 | cut -d'=' -f2)
    else
	primer_product_size_range=$(echo $line | cut -d'*' -f1 | cut -d'=' -f2)
	sequence_id=$(echo $line | cut -d'*' -f2 | cut -d'=' -f2)
    fi
    sequence_id=$(echo $sequence_id | cut -d')' -f3)
    # Check the upper and lower limits in each range
    # to see if it's okay
    bad_range=
    for range in $(echo $primer_product_size_range) ; do
	lower=$(echo $range | cut -d'-' -f1)
	upper=$(echo $range | cut -d'-' -f2)
	if [ $lower -gt $upper ] ; then
	    bad_range=yes
	    break
	fi
    done
    # Report if the range is wrong
    if [ ! -z "$bad_range" ] ; then
	echo "$sequence_id ($primer_product_size_range)"
    fi
done
##
#
