#! /usr/bin/perl -w

use strict;

#### Read thru a GFF file of motifs return the number of unique ids
#### Ian Donaldson Sept 2008

#### Usage
unless(@ARGV == 2) {
   die("USAGE: $0 | GFF file | Output file\n\n");
}

#### Ready output file
open(GFF, "<$ARGV[0]") or die("Could not open GFF file!!\n\n");
open(OUTPUT, ">$ARGV[1]") or die("Could not open output file!!\n\n");

#### Hash to hold ids
my %id_hash = ();

#### Work thru GFF file
while(defined(my $gff_line = <GFF>)) {
   if($gff_line =~ /(^#|^\s)/) { next }

   my @gff_line_bits = split(/\t/, $gff_line);

   my $id = $gff_line_bits[0];

   $id_hash{$id}=1;
}
   
my @all_keys = sort(keys(%id_hash));

my $elements = scalar(@all_keys);

#print OUTPUT "There are $elements unique sequences in the file\n";
print OUTPUT "$elements non-redundant sequences\n";

#### Close files
close(GFF);
close(OUTPUT);

exit;
