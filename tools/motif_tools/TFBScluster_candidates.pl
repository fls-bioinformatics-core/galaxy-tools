#!/usr/bin/perl

# TFBScluster version 2.0 - cluster together TFBSs from distinct 
#                           TFBSsearch generated libraries.
#
# (c) Ian Donaldson 2003 and Mike Chapman (TFBS overlap subs)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

use strict;
use FileHandle;
#use integer; # Force floating point into integers

$|=1;

###########
# Program to determine whether a TF site is in close proximity to
# one or more other TF sites.
# September 2003.  Ian Donaldson.
# Revised 8 Sept. 2003 to not include the query TF site in the threshold.
# This is to allow one to determine whether a TF is near to another of the 
# same type.
# Revised 9 Sept to alter the threshold size to only include the core of a 
# pattern i.e. gata of nngatann.
# Revised 19 Sept to replace query and subject libraries with the statement
# of all interested libraries.
# Revised 22 Sept to scan output for overlapping patterns.
# NOTE: Any overlap in comparative record start with start pattern
# Revised 30 Sept to ignore duplication of TFBS in a group record caused by 
# palindrome.  By skipping if name and positions the same.
# Revised 6 Oct code for tree searching method to deal with overlapping TFBSs
###########

#### Command line usage
if(@ARGV != 7)
{
   die ("USAGE: 
   $0
   TF libraries \(comma delimited NO SPACES\)           
   Number of flanking 'N's for subject files \(comma delimited NO SPACES\)        
   Minimum number of occurences \(comma delimited NO SPACES\)
   TF IDs \(comma delimited NO SPACES\)
   Single range value in bp \(+/-\) query start and end values
   Include overlapping TFBSs \(include/exclude\)
   Output file\n\n");                                           
}

#### File handles
my $subject = new FileHandle;
my $combined = new FileHandle;
my $sorted = new FileHandle;
my $groups = new FileHandle;
my $filtered_groups = new FileHandle;
my $output = new FileHandle;
my $output2 = new FileHandle;

#### Variables
my @subject_files = (); # Array containing the names of selected subject files
my @flanking_n = (); # Array containing the number of flanking 'n' for each pattern
my @min_occur = (); # Array containing the minimum occurences for the TF library
my @ids = (); # Array containing user defined IDs for the TF libraries
my @file_sizes = ();
my @sorted_file_sizes = ();
my $range = $ARGV[4];
my $allow = $ARGV[5];
my @regex_ids = ();

#####################################################
#### Deal with user arguments processed into an array
#####################################################

#### Convert TF file names string to an array
@subject_files = split(/,/, $ARGV[0]);

#### Convert flanking 'N' numbers string into an array
@flanking_n = split(/,/, $ARGV[1]);

#### Convert minimum occurences string into an array
@min_occur = split(/,/, $ARGV[2]);

#### Convert minimum occurences string into an array
@ids = split(/,/, $ARGV[3]);

foreach my $id_string (@ids) {
  if($id_string !~ /^[\w\d_,]+$/) {
     die("A non-letter/number character was detected in your label string!\n");
  }
}

#### Record how large they are
for(my $i=0; $i < $#subject_files + 1; $i++) {
   my $size = (-s $subject_files[$i]); # -s performed on an unopened file!

   push(@file_sizes, ["$subject_files[$i]", "$size", "$flanking_n[$i]", "$min_occur[$i]", "$ids[$i]"]);
}

#### Sort file sizes array by file sizes
# ARRAY NOT SORTED BUT COPIED TO ALLOW SORTING AT A LATER DATE
# @sorted_file_sizes = sort{$a->[1] <=> $b->[1]} @file_sizes;
push(@sorted_file_sizes, @file_sizes);

#### Summary file information
print STDOUT "TFBScluster analysis:\n",
             "--------------------\n";

print STDOUT "TFBS library information:\n";

#### Show file summary
for(my $i=0; $i < $#sorted_file_sizes + 1; $i++) {
   print STDOUT "TFBS lib. ID = $sorted_file_sizes[$i][4].\n",
                "Extended conservation = $sorted_file_sizes[$i][2].\n",
		"Minimum occurrence = $sorted_file_sizes[$i][3].\n\n";
}

#print STDOUT "\n";


#####################################################
#### Information required by tree searching algorithm
#####################################################   

#### Array containing the minimum number of each TF, also corresp names 
my @tf_min = ();
my @tf_names = ();
   
for(my $i=0; $i < $#sorted_file_sizes + 1; $i++) {   
   push(@tf_min, $sorted_file_sizes[$i][3]);
}      

for(my $i=0; $i < $#sorted_file_sizes + 1; $i++) {   
   push(@tf_names, $sorted_file_sizes[$i][4]);
}      

#### TEST
#print "ARRAY1 = @tf_min\n\n";

#####################################################################
#### Open a file to store all the TF data from each selected library.
#####################################################################
$combined->open(">TFcombined\.$$") or die("Could not open TFcombined file!\n");

#### Copy each TF file to another file and sort it.
for(my $i=0; $i < $#sorted_file_sizes + 1; $i++) {
   #### Save necessary parts of the current subject file to chr. specific arrays
   $subject->open("<$sorted_file_sizes[$i][0]") or die("Could not open subject file!\n");

   #### Message to user
   #print "Adding data for TF file $i\.\t";

   SUBLINE: while(defined(my $sub_line = <$subject>)) {
      my ($sub_seqname, $sub_source, $sub_feature, $sub_start, $sub_end, $sub_score, 
          $sub_strand, $sub_frame, $sub_attribute) = '';

      #### Skip line if GFF comment or blank line
      if($sub_line =~ /(^\s|^#)/)
      {
         next SUBLINE;
      }

      #### Split each line by TAB
      ($sub_seqname, $sub_source, $sub_feature, $sub_start, $sub_end, $sub_score, 
       $sub_strand, $sub_frame, $sub_attribute) = split(/\t/, $sub_line, 9);

      #### Clean up attribute
      #($sub_attribute) = $sub_attribute =~ /[ACTG\-]+/g;
      chomp($sub_attribute);

      #### Adjust thresold of subject positions to reflect the core sequence
      #### Possibly make an argument?!
      $sub_start = $sub_start + $sorted_file_sizes[$i][2];
      $sub_end = $sub_end - $sorted_file_sizes[$i][2];

      #### Determine chromosome
      (my $sub_chr) = $sub_seqname;

      #### Add modified line to analysis library file
      $combined->print("$sub_seqname\t$sub_source\t$sub_feature\t$sub_start\t$sub_end\t",
                       "$sub_score\t$sub_strand\t$sub_frame\t$sorted_file_sizes[$i][4]\n");
#                       "$sub_score\t$sub_strand\t$sub_frame\t$sub_attribute",
#		       "\_\_$sorted_file_sizes[$i][4]\n");
   }

   #### Message
   #print STDOUT "\[DONE\]\n";

   $subject->close;
}

#### Spacer on screen
#print STDOUT "\n";

$combined->close;


#############################
#### Sort the TFcombined file
#############################
#print STDOUT "Sorting TFcombined file.\t";

#system("sort +0.3 -0.5 +3n -4n TFcombined\.$$ > TFcombined_sorted_temp\.$$");
system("sort +0 -1 +3n -4n TFcombined\.$$ > TFcombined_sorted\.$$");

#print "HELLO\n";

###################################
#### Convert all chr01 back to chr1
###################################
#system("/home/donaldson/bin/TFBScluster/nozero_before_1-9.pl TFcombined_sorted_temp\.$$ TFcombined_sorted\.$$");

#print STDOUT "\[DONE\]\n\n";


#####################################
#### Sort the sorted file into groups
#####################################
#### Work thru each line of the combined TF file.  Store record of all TFs downstream
#### WITHIN the predefined distance 
#print STDOUT "Organising the sorted file into groups.\t";

my $last = 0;

$sorted->open("<TFcombined_sorted\.$$") or die("Could not open sorted TFcombined file!\n");

#### Rewind combined TF file to start
seek($sorted, 0, 0);

COMBLINE: while(defined(my $comb_line = <$sorted>)) {
   #### Get info about the line
   my @comb_line_array = split(/\t/, $comb_line);
   my $comb_seqname = $comb_line_array[0];
   (my $comb_chr) = $comb_seqname;
   
   my $comb_start = $comb_line_array[3];

   #### Store the start of the next line
   my $next_line_pos = tell($sorted); 
   
   #### Variable to hold lines
   my $group_holder = '';
   
   $group_holder = $comb_line;
   
   #### Read thru the next lines until the end position is not within the specified
   #### range of the start line start
   my $count_hit = 0;     

   GROUPLINE: while(defined(my $group_line = <$sorted>)) {
      my @group_line_array = split(/\t/, $group_line);
      my $group_seqname = $group_line_array[0];
      (my $group_chr) = $group_seqname;

      my $group_end = $group_line_array[4];

      #### CHR
      #if( (($group_end - $comb_start + 1) < $range ) and ($comb_chr eq $group_chr) ) {
      if( (($group_end - $comb_start + 1) <= $range ) and ($comb_chr eq $group_chr) ) {
         $group_holder .= $group_line;
         $count_hit++;
      }     

      else {
	 last GROUPLINE;   
      }
   }

   if($count_hit > 0) {
      #Make the record
      $groups->open(">>TFgroups\.$$") or die("Could not open TF groups file!\n");

      $groups->print("$group_holder\/\/\n");

      $groups->close;
      
      #### Move to the end of the last line
      seek($sorted, $next_line_pos , 0);

      next COMBLINE;
   }
   
   else {
      #### Move to the end of the last line
      seek($sorted, $next_line_pos , 0);

      next COMBLINE;
   }
}

$sorted->close;

#print STDOUT "\[DONE\]\n\n";


###################################################################################
#### Look through the groups file to find records matching the user defined params
###################################################################################
my $record = '';
my $target = 0;
my $count_pass = 0;

#### Another user message
print STDOUT "You have chosen to search for groups containing at least:\n";

for(my $i=0; $i < $#sorted_file_sizes + 1; $i++) {
   print STDOUT "$sorted_file_sizes[$i][3] $sorted_file_sizes[$i][4] site(s).\n";

   #### Increment the desired number of matches for a group to be selected
   $target++;
}

#### Another user message
#print STDOUT "\nOutput will be written to \[$ARGV[6]\].\n";
print STDOUT "\nCombining overlapping clusters:\n";

#### Open an output file
$output->open(">$ARGV[6]\_v1") or die("Could not open output file!\n");

#### Open the TFgroups files
$groups->open("<TFgroups\.$$") or die("Could not open TFgroups file!\n");

#### Open the filtered record test file
$filtered_groups->open(">filtered_groups\.$$") or die("Could not open filtered groups file!\n");

#### Take each record of the groups file
RECORD: while($record = GetNewRecord($groups)) {
   #### What about if the positions overlap?
   my @record_array = ();
   my $last_record_start = 0;
   my $last_record_end = 0;
   my $last_record_attribute = 0;

   my $save_filtered_group = '';
   
   #### Take each line of the record beginning with chr...
   RECORDLINE: while($record =~ /(\w.+\n)/mg) {
      my $record_line = $1;

      my @record_line_array = ();
      @record_line_array = split(/\t/, $record_line);

      my $record_seqname = $record_line_array[0];
      my $record_start = $record_line_array[3];
      my $record_end = $record_line_array[4];
      my $record_strand = $record_line_array[6];
      my $record_attribute = $record_line_array[8];
      chomp($record_attribute);

      #print "$record_seqname\t$record_start\t$record_end\t$record_strand\t$record_attribute\n";
      #exit;

      #### If the last motif exactly overlaps and is same ID - skip adding to array
      if( ($record_start == $last_record_start) and 
          ($record_end == $last_record_end) and
	  ($record_attribute eq $last_record_attribute) ) {

         $last_record_start = $record_start;
	 $last_record_end = $record_end;
	 $last_record_attribute = $record_attribute;
	  
         next RECORDLINE;  
      }

      $last_record_start = $record_start;
      $last_record_end = $record_end;
      $last_record_attribute = $record_attribute;

      #### File 2D array
      push(@record_array, ["$record_seqname", "$record_start", "$record_end", "$record_strand", "$record_attribute"]);

      #### Test file
      $save_filtered_group .= "$record_seqname\t$record_start\t$record_end\t$record_strand\t$record_attribute\n";
   }

   #### Test file record marker
   $save_filtered_group .= "//\n";

   ######################################################################
   #### Make sure the record contains the minimum number of specified TFs
   ######################################################################
   
   #### Counter to see whether all params matched
   my $pass = 0;
   @regex_ids = ();  # Array to hold regexs as they are used
   my @regex_totals = ();  # Array to hold info on regex totals in the record
   
   #### Work thru each of the input parameter lists
   for(my $i=0; $i < $#sorted_file_sizes + 1; $i++) {
      #### Site name for regex
      my $regex = $sorted_file_sizes[$i][4];

      push(@regex_ids, $regex);
      
      #### Min number of hits for regex
      my $min_regex = $sorted_file_sizes[$i][3];
      
      #### Search for current regex and tally
      my $regex_hits = 0;

      #### Work thru each of the non-repeating record lines array
      for(my $k=0; $k < $#record_array + 1; $k++) {
         my $line_regex = $record_array[$k][4];
	 
	 if($regex eq $line_regex) {
	    $regex_hits++;
	 }
      }

      #### Were the min number of regex hits found?
      if($regex_hits >= $min_regex) {
         $pass++;   
      }      
   }

   #####################################################################
   #### If there are the minimum number of TFBS then check they are not 
   #### sufficiently overlapping to reduce the numbers below the minimum
   #####################################################################
   my $good_cluster = '';

   if($pass == $target) {
      #### Test file
      $filtered_groups->print("$save_filtered_group");

      # Declarations
      my ($end);
      my (@starts, @ends, @choices);

      # Assign start and end positions

      grep { $starts[$_] = $record_array[$_][1]; $ends[$_] = $record_array[$_][2] }
      (0 .. $#record_array);

      $end = -1; # First choice does not refer to a transcription factor

      # Loop through all transcription factors

      I_LOOP:
      for my $i (0 .. @starts) {
         my $next_factor = 0;

         # Now loop through all possible following transcription factors
         # Note that $starts[0] and @ends[0] refer to the first transcription factor
         # whereas $choices[1] will refer to the first transcription factor.

         for my $j ( $i .. $#starts) {
            if ($starts[$j] > $end) {
               $next_factor = ($j + 1);
               last;
            }
         }

         push @{ $choices[$i] }, $next_factor;

         # If no factor follows, we have a terminating factor and progress to the next.
         # Must first modify $end to be the end of the next transcription factor.

         unless ($next_factor) {
            $end = $ends[$i];
            next I_LOOP;
         }

         # Now need to check the factors overlapping with $next_factor and add them
         # as possibilities. Note that in some circumstances, this may result in a
         # redundant path. This will not give spurious results, however.

         for my $k ( $next_factor .. $#starts ) {
            if ($starts[$k] <= $ends[$next_factor - 1]) {
               push @{ $choices[$i] }, ($k + 1);
            }
         }

         # Finally, modify $end to be the end of the next transcription factor

         $end = $ends[$i];

         # And go to next loop
      }


      #### Print out @choices array to file
      foreach (@choices) {
         $filtered_groups->print("@{ $_ } \n");
      }

      $filtered_groups->print("//\n");      


      #####################################################
      #### Information required by tree searching algorithm
      #### Only for records that contain min number of TFBS
      #####################################################   

      #### Array relating each TF to their minimum values
      my @tf_relate = ();

      #$tf_relate[0] = 0;
  
      #### Get TF ID for current record
      for(my $i=0; $i < $#record_array+1; $i++) {
         #my $next_i = $i + 1;

         my $current_attrib = $record_array[$i][4];
      
         #### Scan @sorted_files_sizes array for matching TF ID and save 
         #### row number.  This will relate directly to @tf_min
         for(my $f=0; $f < $#sorted_file_sizes + 1; $f++) {

            if($current_attrib =~ /$sorted_file_sizes[$f][4]/) {
               #$tf_relate[$next_i] = "$f";
               $tf_relate[$i] = "$f";
            }
         }
      }

      #### TEST
#      print "ARRAY2 = @tf_relate\n\n";
#      for(0..$#tf_relate) {
#         print "[$_] $tf_relate[$_]\n";
#      }

      #### DUMMY ARRAYS
      #@choices = ();
      #@choices = (
#	[ 1,2,3 ],
#	[ 4,5,6 ],
#	[ 4,5,6 ],
#	[ 4,5,6 ],
#	[ 7 ],
#	[ 7 ],
#	[ 7 ],
#	[ 8,9,10 ],
#	[ 0 ],
#	[ 0 ],
#	[ 0 ]
#        );

      #@tf_min = ();
      #@tf_min = ( 3, 1, 1);

      #@tf_relate = ();
      #@tf_relate = (0,0,0,1,1,1,2,2,2,2);



      #### References for test_cluster sub
      my $choices_to_pass = \@choices;      #### Tree decisions
      my $required_to_pass = \@tf_min;        #### Min TFBS numbers
      my $order = \@tf_relate;  #### Relate TFBSs to min numbers


      ########################################
      #### Run tree searching algorithm (Mike)
      ########################################
      if($allow eq 'exclude') {
         #$good_cluster = tf_cluster_tree($choices_to_pass, $required_to_pass, $order); 
         $good_cluster = tf_cluster_tree(\@choices, \@tf_min, \@tf_relate); 

         #print "GOODCLUSTER = $good_cluster\n";
      }

      else {
         $good_cluster = 1;
      }
   }   
   

   #### If all parameters are matched create a summary of the record   
   #### Work thru each line of the record string start end and TF ID to an array

   #### Carry on if overlapping not a problem ####
   if( ($pass == $target) and ($good_cluster == 1) ){
      my $regex_chr = $record_array[0][0];
      my $regex_start = $record_array[0][1];
      my $regex_end = $record_array[$#record_array][2];
      my $joined_ids = join("-", @regex_ids);
      
      $output->print("$regex_chr\t",
                     "TFBScluster\t",
		     "CNS\t",
		     "$regex_start\t",
		     "$regex_end\t",
		     ".\t",
		     "+\t",
		     ".\t",
		     "$joined_ids\n");
   }
}

$groups->close;
$filtered_groups->close;
$output->close;

#### Space on screen
#print STDOUT "\n";

#### Read each line of output file and combine lines that overlap
my $version = 1;

#### Remain in loop until last command given
while(1) {
   my $last_seqname = '';
   my $last_chr = '';
   my $last_start = '';
   my $last_end = '';
   my $changes = 0;
   my $outline_count = 0;

   my ($out_seqname, $out_source, $out_feature, $out_start, $out_end, $out_score, 
       $out_strand, $out_frame, $out_attribute, $out_chr) = '';

   $output->open("<$ARGV[6]\_v$version") or die("Could not open output file!\n");

   #### If the output file is empty then exit loop and finish
   if(-z $output) {
      $output->close;

      system("rm $ARGV[6]\_v$version");

      exit;
      #die("\nNo clusters were found!\n");
   }

   $version++;

   $output2->open(">$ARGV[6]\_v$version") or die("Could not open output2 file!\n");

   OUTLINE: while(defined(my $out_line = <$output>)) {
      #### Skip line if GFF comment or blank line
      if($out_line =~ /^\s/)
      {
         next OUTLINE;
      }

      #### Tally lines read
      $outline_count++;
   
      ($out_seqname, $out_source, $out_feature, $out_start, $out_end, $out_score, 
       $out_strand, $out_frame, $out_attribute) = split(/\t/, $out_line, 9);

      $out_chr = $out_seqname;

      #### Handle the first line
      if($outline_count == 1) {
         $last_seqname = $out_seqname;
         $last_chr = $out_chr;
         $last_start = $out_start;
         $last_end = $out_end;         

         next OUTLINE;
      }   

      #### Remaining lines
   
      #### If the patterns are on different chromosomes
      #### CHR
      if($last_chr ne $out_chr) {
         #### Print the last line to the file and save the current
         $output2->print("$last_seqname\t$out_source\t$out_feature\t$last_start\t$last_end\t",
                         "$out_score\t$out_strand\t$out_frame\t$out_attribute");

         $last_seqname = $out_seqname;
         $last_chr = $out_chr;
         $last_start = $out_start;
         $last_end = $out_end;         

         next OUTLINE;            
      }

      #### If they overlap change current line start to the previous
      if( ($last_end > $out_start) and ($last_end <= $out_end) ) {
         $last_end = $out_end;                  

         #### Record the number of changes
         $changes++;
      }

      #### If not just print to output
      else {
            $output2->print("$last_seqname\t$out_source\t$out_feature\t$last_start\t$last_end\t",
                      "$out_score\t$out_strand\t$out_frame\t$out_attribute");
   
         $last_seqname = $out_seqname;
         $last_chr = $out_chr;
         $last_start = $out_start;
         $last_end = $out_end;                     
      }
   }

   #### Print last line to outfile
   $output2->print("$last_seqname\t$out_source\t$out_feature\t$last_start\t$last_end\t",
                   "$out_score\t$out_strand\t$out_frame\t$out_attribute");

   #### Message
   my $previous = $version - 1;
   
   print STDOUT "Records in output file version $previous \($outline_count patterns\).\n";


   $output->close;
   $output2->close;

   if($changes == 0) { 
      my $joined_ids = join("-", @regex_ids);
      #### Copy last version to file name without v number
      #system("cp $ARGV[6]\_v$version $ARGV[6]");

      #### Open final output file and convert the attribute
      open(FINAL_VER, "<$ARGV[6]\_v$version") or die("Could not open final ver GFF!\n");
      open(FINAL, ">$ARGV[6]") or die("Could not open final GFF!\n");

      while(defined(my $final_line = <FINAL_VER>)) {

         my ($final_seqname, $final_source, $final_feature, $final_start, $final_end,
          $final_score, $final_strand, $final_frame, $final_attribute) =
          split(/\t/, $final_line, 9);

         my $pattern_length = ($final_end - $final_start) + 1;

         print FINAL "$final_seqname\t$final_source\t$final_feature\t$final_start\t",
                     "$final_end\t$final_score\t$final_strand\t$final_frame\t",
                     "$joined_ids\_len$pattern_length\n";

      }

      close(FINAL_VER);
      close(FINAL);

      last; 
   }
}

#### Spacer for summary file
print STDOUT "\n";

#### Remove intermediate files
system("rm ./TFcombined\.$$ ./TFcombined_sorted\.$$ ./TFgroups\.$$ ./filtered_groups\.$$ $ARGV[6]\_v*");

exit;


############
#Subroutines
############
sub GetNewRecord
# Load record from a library file, delimited by //
{
   my $fh = shift (@_);
   my $record = '';
   my $saveinputsep = $/;
   $/ = "//\n";

   $record = <$fh>;

   $/ = $saveinputsep;
   return $record;
}

sub tf_cluster_tree {

my @path;
my $node_count;
my $node = 0;
my $success = 0;
my $choice = -1;
my @node_contains;
my @node_to_choice;
my @count;
my @branches;
$branches[0] = -1;
my $path_ref;
my $branch_ref;
my $node_contains;
my $node_to_choice;
my ($choice_ref,
	$required_ref,
	$tf_ref) = @_;
my @choices = @$choice_ref;
my @required = @$required_ref;
my @tfs = @$tf_ref;
($node,
 $choice,
 $node_count,
 $choice_ref,
 $path_ref,
 $branch_ref,
 $node_to_choice,
 $node_contains) = next_node ($node,
			      $choice,
			      $node_count,
			      $choice_ref,
			      \@path,
			      \@branches,
			      $tf_ref);
@choices = @$choice_ref;
@path = @$path_ref;
@branches = @$branch_ref;
$node_contains[$node] = $node_contains;
$node_to_choice[$node] = $node_to_choice;

BLOCK_A:

while (1) {
no strict "vars";

	if ( node_terminating($choice, $choice_ref) ) {
		push @path, $node;
		@count = undef;
		grep { $count[ $node_contains[$_] ]++ } @path;
		#print "Count is @count.\n";
		my $score = grep { $count[$_] >= $required[$_] }
			(0 .. $#count);
		#print "Path is @path\n";
		if ($score == scalar @required) {
			$success = 1;
			last BLOCK_A;
		}
		pop @path;
		($node,
		 $choice,
	 	 $path_ref)
		= last_unexplored_node(\@path, $choice, $choice_ref,
		\@node_to_choice, \@branches);
		last BLOCK_A if ($node == -1);
		@path = @$path_ref;
	}
	if ( node_fully_explored($choice, $node, $choice_ref, \@branches) ) {
		($node,
		 $choice,
		 $path_ref)
		= last_unexplored_node(\@path, $choice, $choice_ref,
		\@node_to_choice, \@branches);
		@path = @$path_ref;
		last BLOCK_A if ($node == -1);
	}
	($node,
	 $choice,
	 $node_count,
	 $choice_ref,
	 $path_ref,
	 $branch_ref,
	 $node_to_choice,
	 $node_contains,) = next_node ($node,
	 			       $choice,
				       $node_count,
				       $choice_ref,
				       \@path,
				       \@branches,
				       $tf_ref);
	@choices = @$choice_ref;
	@path = @$path_ref;
	@branches = @$branch_ref;
	$node_contains[$node] = $node_contains;
	$node_to_choice[$node] = $node_to_choice;
	} 
return $success;
}


sub next_node {

	my ($node,
	my $choice,
	my $node_count,
	my $choice_ref,
	my $path_ref,
	my $branch_ref,
	my $tf_ref) = @_;
	my @choices = @$choice_ref;
	my @path = @$path_ref;
	my @branches = @$branch_ref;
	my @tfs = @$tf_ref;
	my $new_choice = $choices[$choice][0];
	push @{ $choices[$choice] }, shift @{ $choices[$choice] };
	$choice = $new_choice;
	my $node_to_choice = $choice;
	push @path, $node if $node;
	$branches[$node]++;
	$node = $node_count++;
	my $node_contains = $tfs[$choice - 1] if $choice;
	return (
		$node,
		$choice,
		$node_count,
		\@choices,
		\@path,
		\@branches,
		$node_to_choice,
		$node_contains);
}

sub node_fully_explored {
no strict "vars";

	my $choice = shift;
	my $node = shift;
	my $choices_ref = shift;
	my $branch_ref = shift;
	my @choices = @$choices_ref;
	my @branches = @$branch_ref;
	if ($branches[$node] == (scalar @{ $choices[$choice] })) {
		return 1 }
	else { return 0 }
}

sub last_unexplored_node {
no strict "vars";

	my $path_ref = shift;
	my $choice = shift;
	my $choice_ref = shift;
	my $node_to_choice_ref = shift;
	my $branch_ref = shift;
	my @path = @$path_ref;
	my @node_to_choice = @$node_to_choice_ref;
	my @branches = @$branch_ref;
	my $node;

	do {
		$node = pop @path;
		$choice = $node_to_choice[$node];
		if ( $node == 0 and node_fully_explored($choice, $node,
			$choice_ref, \@branches) ) {
			$node = -1;
			last;
		}
	} while ( node_fully_explored($choice, $node, $choice_ref,
		\@branches) );
	return ($node, $choice, \@path);
}

sub node_terminating {

	my $choice = shift;
	my $choices_ref = shift;
	my @choices = @$choices_ref;
	if ($choices[$choice][0]) { return 0 }
	else { return 1 }
	
}














