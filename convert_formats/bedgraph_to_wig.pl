#!/usr/bin/perl
#
# Original version by Dave Tang, see
# http://www.davetang.org/wiki/tiki-index.php?page=wig
#
# Modified to use a step of 10 rather than 1 (otherwise output wig can
# be huge e.g. tens of Gbs)

use strict;
use warnings;

my $usage = "Usage: $0 <infile.bedgraph> <outfile.wig>\n";
my $infile = shift or die $usage;
my $outfile = shift or die $usage;

if ($infile =~ /\.gz$/){
   open(IN,'-|',"gunzip -c $infile") || die "Could not open $infile: $!\n";
} else {
   open(IN,'<',$infile) || die "Could not open $infile: $!\n";
}

open(OUT,'>',$outfile) || die "Could not open $outfile: $!\n";
print OUT "track type=wiggle_0 name=\"$infile\" description=\"$infile\" visibility=full\n";

while(<IN>){
   chomp;
   next if (/^track/);
   #chr1    3000403 3000404 2
   my ($chr,$start,$end,$data) = split(/\t/);
   #fixedStep chrom=chr1 start=3016975 step=1 span=1
   #1
   #1
   #1
   my $length = $end - $start;
   print OUT "fixedStep chrom=$chr start=$start step=10 span=1\n";
   for (my $i = 0; $i <= $length; $i += 10) {
      print OUT "$data\n";
   }
}
close(IN);
close(OUT);

exit(0);
