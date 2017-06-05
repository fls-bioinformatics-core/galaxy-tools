#!/bin/bash
#
# Helper functions for the pal_finder_wrapper.sh script
#
# Utility function for terminating on fatal error
function fatal() {
    echo "FATAL $@" >&2
    exit 1
}
#
# Check that specified program is available
function have_program() {
    local program=$1
    local got_program=$(which $program 2>&1 | grep "no $(basename $program) in")
    if [ -z "$got_program" ] ; then
	echo yes
    else
	echo no
    fi
}
#
# Set the value for a parameter in the pal_finder config file
function set_config_value() {
    local key=$1
    local value=$2
    local config_txt=$3
    if [ -z "$value" ] ; then
       echo "No value for $key, left as default"
    else
       echo Setting "$key" to "$value"
       sed -i 's,^'"$key"' .*,'"$key"'  '"$value"',' $config_txt
    fi
}
#
# Identify 'bad' PRIMER_PRODUCT_SIZE_RANGE from pr3in.txt file
function find_bad_primer_ranges() {
    # Parses a pr3in.txt file from pal_finder and reports
    # sequence ids where the PRIMER_PRODUCT_SIZE_RANGE has
    # upper limit which is smaller than lower limit
    local pr3in=$1
    local pattern="^(SEQUENCE_ID|PRIMER_PRODUCT_SIZE_RANGE)"
    for line in $(grep -E "$pattern" $pr3in | sed 's/ /^/' | sed 'N;s/\n/*/')
    do
	# Loop over pairs of SEQUENCE_ID and PRIMER_PRODUCT_SIZE_RANGE
	# keywords in the primer3 input
	if [ ! -z "$(echo $line | grep ^SEQUENCE_ID)" ] ; then
	    # Extract the values
	    local size_range=$(echo $line | cut -d'*' -f2 | cut -d'=' -f2 | tr '^' ' ')
	    local seq_id=$(echo $line | cut -d'*' -f1 | cut -d'=' -f2)
	else
	    local size_range=$(echo $line | cut -d'*' -f1 | cut -d'=' -f2)
	    local seq_id=$(echo $line | cut -d'*' -f2 | cut -d'=' -f2)
	fi
	seq_id=$(echo $seq_id | cut -d')' -f3)
	# Check the upper and lower limits in each range
	# to see if it's okay
	local bad_range=
	for range in $(echo $size_range) ; do
	    local lower=$(echo $range | cut -d'-' -f1)
	    local upper=$(echo $range | cut -d'-' -f2)
	    if [ $lower -gt $upper ] ; then
		bad_range=yes
		break
	    fi
	done
	# Report if the range is wrong
	if [ ! -z "$bad_range" ] ; then
	    echo "$seq_id ($size_range)"
	fi
    done
}
