#!/usr/bin/perl

package MotifMatrix::Readers;

=head1 NAME

MotifMatrix::Readers

=head1 DESCRIPTION

Functions to read varous matrix file formats. Creates MotifMatrix objects

=head1 AUTHOR

Tim Burgis, tim.burgis@manchester.ac.uk

=cut

use strict;
use warnings;

use constant TRUE => 1;
use constant FALSE => 0;

use List::Util qw(min max sum);

use MotifMatrix;

use vars qw(@BASES);

@BASES = qw(A C G T);


#########################
=item read_jaspar_fasta()

	Read JASPAR pseudo-FASTA format

=cut

sub read_jaspar_fasta {
	my $fh = shift;
	my @matrices = ();
	my %holding = ();
	LINE: while(my $line = <$fh>) {
		chomp($line);
		if($line =~ /^>/) {
			my($id,$name) = split(/\s+/,$line);
			#my %info = { ID => $id, NAME => $name };		
		}	
	}
	
}


##########################
=item read_jaspar_single()

	Read JASPAR single matrix per file format

=cut

sub read_jaspar_single {
	my $fh = shift;
}


#####################
=item read_transfac()
	
	Read transfac EMBL-like data format

=cut

sub read_transfac {
	my $fh = shift;
}


#######################
=item read_chipmodule()

	Read ChIPModule pseudo-FASTA format

=cut

sub read_chipmodule {
	my $fh = shift;
}


#################
=item read_meme()

	Read matrices from meme filegoo

=cut

sub read_meme {
	my $fh = shift;
}


###################
=item read_weeder()

	Read matrices from weeder output

=cut

sub read_weeder {
	my $fh = shift;
	my $name_root = shift;
	my $FOUND_MATRIX = FALSE;
	my @best_matrices = ();
	my @all_matrices = ();
	my $matrix_count = 0;
	my $best_matrix = undef;
	my $all_matrix = undef;
	LINE: while(my $line = <$fh>) {
		if($line =~ /Frequency Matrix/) {
			$FOUND_MATRIX = TRUE;
			my $bestID = $name_root .'_best_' . ++$matrix_count;
			my $allID = $name_root . '_all_' . $matrix_count;
			$best_matrix = MotifMatrix->new({'id' => $bestID, 'name' => $bestID, 'type' => 'COUNT'});
			$all_matrix = MotifMatrix->new({'id' => $allID, 'name' => $allID, 'type' => 'COUNT'});
			push(@best_matrices,$best_matrix);
			push(@all_matrices,$all_matrix);
			next LINE;		
		}	
		if($FOUND_MATRIX && $line =~ /^\d/) {
			chomp($line);
			my @fields = split(/\s+/,$line);
			my @all = @fields[1..4];
			my @best = @fields[5..8];
			$all_matrix->add_base(@all);
			$all_matrix->set_count(sum(@all));
			$best_matrix->add_base(@best);
			$best_matrix->set_count(sum(@best));
			next LINE;		
		}
		if($FOUND_MATRIX && $line =~ /^=/) {
			$FOUND_MATRIX = FALSE;
			next LINE;					
		}
	}
	return(\@best_matrices,\@all_matrices);
}


1;
