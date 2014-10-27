############################################################
# Graeme Fox  -  25/09/2014 - graeme.fox@manchester.ac.uk
#
# Program to filter output from pal_finder/primer3 workflow
#
# Filters output based on "Primers found (1=y,0=n)" and 
# "occurrences of forward/reverse amplifiable primer in reads".
# Filters out any non-perfect microsatellites.
# Ranks microsatellites by motif size (largest first)
#
# Usage:
# Give it the file that ends with:
# "(microsatellites_with_read_IDs_and_primer_pairs)].txt"
#
# with the following syntax: 
# perl pal_finder_filter.pl /path/to/input/file
#
# File will be created called "pal_finder_filter_output.txt"
# in the current directory
############################################################

#!/usr/bin/perl -w
use strict;

my @lines;                                   
my @output;                                  
my $outfile = 'pal_finder_filter_output.txt';     

# Open the file for reading
my $filename = $ARGV[0];   
open (my $file, '<', $filename);  

# Grab the headers and store them 
my $header;
while (my $line = <$file>)
{
  if ($line =~ m/^readPair/) {
#	push (@output, $line)             
	$header = $line;	
	} else {

# Send everything else to array for sorting
	push (@lines, $line);                  
	}
}
close $file;
chomp (@lines);

############################################################
# Filter the file on the "Primers found (1=y,0=n)" column
# ie. Drop all the lines which do not have primer sequences
############################################################
my @temporary1;
my @temporary2;
foreach (@lines) { 
@temporary1 = split(/\t/, $_);
	if ($temporary1[5] == 1) {
	push (@temporary2, $_);
		}
}

############################################################
# Filter any lines which do not have "1" in the "Occurances 
# of Reverse/Forward Primer in Reads" field
############################################################
my @temporary3;
my @temporary4;
foreach (@temporary2) { 
@temporary3 = split(/\t/, $_);
	if ($temporary3[16] == 1 && $temporary3[15] == 1) {
	push (@temporary4, $_);
		}
}

############################################################
# Filter any non-perfect repeats
############################################################
my @temporary5;
my @temporary6;
my $count;
foreach (@temporary4) { 
	@temporary5 = split(/\t/, $_);
	$count = ($temporary5[1] =~ tr/\(//);
		if ($count == 1) {
		push (@temporary6, $_);
		}
}
############################################################
# Get size of repeat motif. Order by size (largest first)
############################################################
my @temporary7;
my @temporary8;
my $motif;
my $count2 = 2;
while ($count2 < 10) {
	foreach (@temporary6) {
		@temporary7 = split(/\t/, $_);  
		#get size of motif:
		$motif = () = ($temporary7[1] =~ /[A-Z]/gi );  
		if ($motif == $count2) {
			unshift (@output, join( "\t", @temporary7),"\n");	
		}
	}
$count2++;
}
############################################################
# Open and populate the output file
############################################################
unshift (@output, $header);
open (FILE, "> $outfile") || die "Problem opening $outfile\n";
print FILE @output;
close(FILE);
