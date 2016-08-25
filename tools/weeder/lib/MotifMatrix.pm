#!/usr/bin/perl

package MotifMatrix;

=head1 NAME

MotifMatrix

=head1 DESCRIPTION

Lightweight class to hold a PFM or PSM from e.g. transfac, meme, weeder etc.

=head1 AUTHOR

Tim Burgis, tim.burgis@manchester.ac.uk

=cut

use strict;
use warnings;

use constant TRUE => 1;
use constant FALSE => 0;

use Storable 'dclone';

use vars qw(@TYPES %READERS %WRITERS $EMPTY_MATRIX @BASES $MEME_HEADER @MEME_FREQS);

$MEME_HEADER = "MEME version 4

ALPHABET= ACGT

strands: + -

Background letter frequencies
A %s C %s G %s T %s 

";

@MEME_FREQS = qw(0.25 0.25 0.25 0.25);

@BASES = qw(A C G T);

@TYPES = qw(jaspar_fasta jaspar_single transfac chipmodule weeder meme);

%READERS = (
	'jaspar_fasta' => '',
	'jaspar_single' => '',
	'transfac' => '',
	'chipmodule' => '',
	'weeder' => '',
	'meme' => '');

%READERS = (
	'jaspar_fasta' => '',
	'jaspar_single' => '',
	'chipmodule' => '',
	'meme' => '');

$EMPTY_MATRIX = {('A' => [()],'C' => [()],'G' => [()],'T' => [()])};


###########
=item new()

	Object constructor

=cut

sub new {
	my $proto = shift;
	my $args = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self,$class);
	$self->{TYPE} = $args->{'type'};
	$self->{ID} = $args->{'id'};
	$self->{NAME} = $args->{'name'};
	$self->{COUNT} = undef;
	$self->{LENGTH} = 0;
	$self->{MATRIX} = dclone($EMPTY_MATRIX);
	return $self;
}

################
=item add_base()

	Add a base position to a matrix

=cut

sub add_base {
		my $self = shift;
		my @values = @_;
		my %baseValues;
		@baseValues{@BASES} = @values;
		foreach my $base(keys %baseValues) {
			push(@{$self->{MATRIX}->{$base}},$baseValues{$base});
		}
		$self->{LENGTH} += 1;
		return $self;
}


#################
=item set_count()

	Set the number of matrices included for count matrices only

=cut

sub set_count {
	my $self = shift;
	my $newCount = shift;
	if(defined($self->{COUNT}) && $newCount ne $self->{COUNT}) {
		print "New count (",$newCount,") does not equal old count (",$self->{COUNT},")\n";
	} else {
		$self->{COUNT} = $newCount;	
	}
}


###########################
=item matrix_to_frequencies

	Convert values into matrix into frequencies such
	that each position sums to 1.0. For example:

	6 8 4 2 -> 0.3 0.4 0.2 0.1

=cut

sub matrix_to_frequency {
	my $self = shift;
	my $newMatrix = MotifMatrix->new({'id' => $self->{ID},'name' => $self->{NAME}, 'type' => 'FREQUENCY'});
	for(my $i = 0; $i < $self->{LENGTH}; $i++) {
		my $totalFreq = 0.0;
		my $highestFreq = 0.0;
		my $mostFrequentBase = undef;
		my %frequencies = ();
		foreach my $base(@BASES) {
			my $baseCount = ${$self->{MATRIX}->{$base}}[$i];
			my $freq = 0;
			if($baseCount != 0) { 
				$freq = sprintf("%.9F",($baseCount / $self->{COUNT}));
			}
			$frequencies{$base} = $freq;
			if($freq > $highestFreq) {
				$highestFreq = $freq;
				$mostFrequentBase = $base;		
			}
			$totalFreq += $freq;
		}
		my $shortfall = 1.0 - $totalFreq;
		$frequencies{$mostFrequentBase} += $shortfall;
		my @valuesToAdd = map { $frequencies{$_} } @BASES;
		$newMatrix->add_base(@valuesToAdd);
	}
	$newMatrix->set_count($self->{COUNT});
	return $newMatrix;
}


######################
=item matrix_to_counts

	Convert values into counts - this is effectively
	just making sure that all values are integers. If
	all values in the matrix are already integers then
	the matrix will not be altered.
	For example:

	0.45 0.57 0.12 0.01 -> 45 57 12 1

=cut

sub matrix_to_counts {
	my $self = shift;
	my $multiplicationFactor = 1;
	for(my $i = 0; $i < $self->{LENGTH};$i++) {
		foreach my $base(@BASES) {
			my $freq = ${$self->{MATRIX}->{$base}}[$i];
			if($freq =~ /\.(.*)/) {
				print "Matrix contains fraction: $freq\n";
				my $requiredFactor = '1'. '0' x length($1);
				print "Required multiplier is $requiredFactor\n";
				if($requiredFactor > $multiplicationFactor) {
					$multiplicationFactor = $requiredFactor;				
				}			
			}			
		}	
	}
	my $newMatrix = MotifMatrix->new();
	for(my $i = 0; $i < $self->{LENGTH}; $i++) {
	}
	return $newMatrix;
}

##############################################################################
#
# WRITERS -> SUBROUTINES TO WRITE MATRIX FILES
#
##############################################################################

sub write_jaspar_fasta {
	my $self = shift;
	my $fh = shift;
	
}

sub write_jaspar_single {
	my $self = shift;
	my $fh = shift;
}

sub write_chipmodule {
	my $self = shift;
	my $fh = shift;
}

sub write_meme_header {
	my $fh = shift;
	my $freqRef = shift;
	my @freqs = @MEME_FREQS;
	if(defined($freqRef)) {
		my @newFreqs = @$freqRef;
		if(scalar(@newFreqs) == 4) {
			@freqs = @newFreqs;		
		}	
	}
	printf($fh $MEME_HEADER, @freqs);
}
sub write_meme {
	my $self = shift;
	my $fh = shift;
	print $fh "MOTIF ",$self->{NAME},"\n";
	printf ($fh "letter-probability matrix: alength= %s w= %s nsites= %s\n", scalar(@BASES),$self->{LENGTH},$self->{COUNT});
	for(my $i = 0; $i < $self->{LENGTH};$i++) {
		my @info = map { ${$self->{MATRIX}->{$_}}[$i] } @BASES; 
		print $fh join("\t",@info),"\n";
	}
	print $fh "\n";
}

sub write_test {
	my $self = shift;
	print "This matrix is ",$self->{LENGTH},"bp long\n";
	for(my $i = 0; $i < $self->{LENGTH};$i++) {
		my @info = map { ${$self->{MATRIX}->{$_}}[$i] } @BASES; 
		print join("\t",@info),"\n";
	}
}

1;
