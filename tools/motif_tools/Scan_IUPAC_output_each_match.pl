#! /usr/bin/perl

use strict;
use FileHandle;
use Bio::SeqIO;
#use Statistics::Descriptive;

#####
# Program to count all occurences of a particular REGEX 
# in a file containing mutiple FASTA sequences.
# 11 September 2003. Ian Donaldson.
# Revised to convert IUPAC to regex
# Revised to read a multiple FASTA file
# was CountRegexGFF_IUPAC_1input_nosummary.pl
#####

#### File handles
my $input = new FileHandle;
my $output = new FileHandle;

#### Variables
my $file_number = 0;
my $count_fwd_regex = 0;
my $count_rvs_regex = 0;
my $count_all_regex = 0;
my $seq_tally = 0;
my @seq_totals = ();

#### Command line usage
if(@ARGV != 5) {
   die ("USAGE: 
   $0
   IUPAC
   Multiple FASTA input file
   Output
   Label
   Skip palindromic (0=F+R-default|1=F only)\n\n");
} 

#### Search forward strand only?
my $skip = $ARGV[4];
unless($skip =~ /^[01]$/) {
   die("Only accept 0 or 1 for Skip!\n");
}

#### Process IUPAC string
my $iupac = $ARGV[0];
chomp $iupac;
$iupac = uc($iupac);

if($iupac !~ /^[ACGTRYMKWSBDHVN]+$/) {
   die("A non-IUPAC character was detected in your input string!\n");
}

#### Forward strand IUPAC
my @fwd_iupac_letters = split(//, $iupac); 
my @fwd_regex_list = ();

foreach my $letter (@fwd_iupac_letters) {
   my $converted_iupac = iupac2regex($letter);
   push(@fwd_regex_list, $converted_iupac);
}

my $fwd_regex = join('', @fwd_regex_list);


#### Reverse strand IUPAC
my $revcomp_iupac = RevCompIUPAC($iupac);
my @rev_iupac_letters = split(//, $revcomp_iupac); 
my @rev_regex_list = ();

foreach my $letter (@rev_iupac_letters) {
   my $converted_iupac = iupac2regex($letter);
   push(@rev_regex_list, $converted_iupac);
}

my $rvs_regex = join('', @rev_regex_list);

#### Other variables
my $label = $ARGV[3]; 

if($label !~ /^[\w\d]+$/) {
   die("A non-letter/number character was detected in your label string!\n");
}

my $length = length($iupac);

#### Open output file
$output->open(">$ARGV[2]") or die "Could not open output file $ARGV[2]!\n";
#$output->print("##gff-version 2\n");

#if($skip == 0) {
#   $output->print("##Pattern search: $iupac and $revcomp_iupac\n");
#}

#else {
#   $output->print("##Pattern search: $iupac\n");
#}

#### Work thru FASTA entries in the input file with SeqIO
my $seqio = Bio::SeqIO->new(-file => "$ARGV[1]" , '-format' => 'Fasta');

while( my $seqobj = $seqio->next_seq() ) {
   $seq_tally++;
   my $this_seq_tally = 0;
   my $sequence = $seqobj->seq(); # actual sequence as a string
   my $seq_id = $seqobj->id(); # header
   #print(">$seq_id\n$seq\n\n");

   #$output->print(">$seq_id\n");

   #### Clean up $sequence to leave only nucleotides
   $sequence =~ s/[\s\W\d]//g;

   while ($sequence =~ /($fwd_regex)/ig) {
      $this_seq_tally++;
      $count_fwd_regex++; 
      $count_all_regex++;
      
      my $end_position = pos($sequence);
      my $start_position = $end_position - ($length - 1);
      $output->print("$seq_id\tRegexSearch\tCNS\t$start_position\t$end_position\t.\t+\t.\t$label\n"); 
   }

   #### Count reverse REGEX
   unless($skip == 1) {
      while ($sequence =~ /($rvs_regex)/ig) {
         $this_seq_tally++;
         $count_rvs_regex++;
         $count_all_regex++;

         my $end_position = pos($sequence);
         my $start_position = $end_position - ($length - 1);
         $output->print("$seq_id\tRegexSearch\tCNS\t$start_position\t$end_position\t.\t-\t.\t$label\n"); 
      }

   push(@seq_totals, $this_seq_tally);
   #$output->print("$this_seq_tally matches\n");
   }
}

#### Mean motifs per seq
#my $stat = Statistics::Descriptive::Full->new();
#$stat->add_data(@seq_totals); 
#my $mean = $stat->mean();


#### Print a summary file
if($skip == 0) {
#   $output->print("##Forward: $fwd_regex. Reverse: $rvs_regex.\n",
#                  "##$count_fwd_regex on the forward strand.\n",
#                  "##$count_rvs_regex on the reverse strand.\n",
#                  "##$count_all_regex in total.\n",
#                  "##$seq_tally sequences.  Mean motifs per seq = $mean\n");
#
   print STDOUT "There were $count_all_regex instances of $fwd_regex and $rvs_regex.\n"; 
}

if($skip == 1) {
#   $output->print("##Forward: $fwd_regex.\n",
#                  "##$count_fwd_regex on the forward strand.\n",
#                  "##$seq_tally sequences.  Mean motifs per seq = $mean\n");
#
   print STDOUT "There were $count_fwd_regex instances of $fwd_regex on the forward strand.\n"; 
}

$output->close;

exit;

sub iupac2regex {
# Convert IUPAC codes to REGEX
   my $iupac = shift;
   
   #### Series of regexes to convert 
   if($iupac =~ /A/) { return 'A' }
   if($iupac =~ /C/) { return 'C' }
   if($iupac =~ /G/) { return 'G' }
   if($iupac =~ /T/) { return 'T' }
   if($iupac =~ /M/) { return '[AC]' }
   if($iupac =~ /R/) { return '[AG]' }
   if($iupac =~ /W/) { return '[AT]' }
   if($iupac =~ /S/) { return '[CG]' }
   if($iupac =~ /Y/) { return '[CT]' }
   if($iupac =~ /K/) { return '[GT]' }
   if($iupac =~ /V/) { return '[ACG]' }
   if($iupac =~ /H/) { return '[ACT]' }
   if($iupac =~ /D/) { return '[AGT]' }
   if($iupac =~ /B/) { return '[CGT]' }
   if($iupac =~ /N/) { return '[ACGT]' }

   die("IUPAC not recognised by sub iupac2regex!\n");
}

sub RevCompIUPAC {
   my $iupac_string = shift;
   my @converted_list = ();

   my @iupac_string_list = split(//, $iupac_string); 

   @iupac_string_list = reverse(@iupac_string_list);

   foreach my $letter (@iupac_string_list) {
      $letter =~ tr/ACGTRYMKWSBDHVN/TGCAYRKMWSVHDBN/;
      push(@converted_list, $letter);
   }

   my $joined_list = join('', @converted_list);
   return $joined_list;
}
