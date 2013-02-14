#! /usr/bin/perl -w

use strict;

#### Extract All and Best matrices from a Weeder output file
#### into seperate files
#### Ian Donaldson April 2008

#### Usage
unless(@ARGV==1) {
   die("USAGE: $0 | Weeder output (.wee)\n\n");
}

#### Initialise files
open(WEEDER, "<$ARGV[0]") or die("Could not open Weeder output file!\n\n");
open(OUT_ALL, ">$ARGV[0]\_ALL_matrix.txt") or die("Could not open ALL matrix output file!\n\n");
open(OUT_BEST, ">$ARGV[0]\_BEST_matrix.txt") or die("Could not open BEST matrix output file!\n\n");

#### Flag to show in matrix block
my $in_block = 0;

#### Count new matrices
my $count = 0;

#### Work thru each line of Weeder file
WEEDER_LOOP: while(defined(my $weeder_line = <WEEDER>)) {
   #### Start of matrix block of text
   if($weeder_line =~ /Frequency Matrix/) { 
      $in_block = 1;
      $count++;

      print OUT_ALL ">ALL\_$count\n";
      print OUT_BEST ">BEST\_$count\n";

      next WEEDER_LOOP;
   }
   
   #### While in the matrix block
   if( ($in_block == 1) and ($weeder_line =~ /^\d/) ) {
      #### Split line into list
      my @weeder_line_bits = split(/\s+/, $weeder_line);

      #### Outout matrix 'All' and 'Best' elements
      print OUT_ALL "$weeder_line_bits[1]\t$weeder_line_bits[2]\t$weeder_line_bits[3]\t$weeder_line_bits[4]\n";
      print OUT_BEST "$weeder_line_bits[5]\t$weeder_line_bits[6]\t$weeder_line_bits[7]\t$weeder_line_bits[8]\n";

      next WEEDER_LOOP;
   }

   #### End of matrix block
   if( ($in_block == 1) and ($weeder_line =~ /^============/) ) {
      $in_block = 0;

      print OUT_ALL "\n";
      print OUT_BEST "\n";

      next WEEDER_LOOP;
   }
}

close(WEEDER);
close(OUT_ALL);
close(OUT_BEST);

exit;