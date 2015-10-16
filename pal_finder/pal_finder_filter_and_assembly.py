#!/usr/bin/python -tt

###########################################################
# Graeme Fox - 26/09/2015 - graeme.fox@manchester.ac.uk
# Tested on (L)ubuntu 15.04 only, with Python 2.7
###########################################################
# PROGRAM DESCRIPTION
# Program to pick optimum loci from the output of pal_finder_v0.02.04
# and to predict the fragment length.
#
# This program can be used to filter pal_finder output to choose the 'optimum' loci.
#
# Additionally this program can assemble the two paired end reads,
# find the primers within HQ assembly, log their positions
# and calculate the difference to give the fragment length.
#
# For best results in your PCR, I suggest doing both.
#
###########################################################
# Requirements:
# Must have Biopython (www.biopython.org).
#
# If you with to perform the assembly QC step, you must have:
# PandaSeq (https://github.com/neufeld/pandaseq)
# PandaSeq must be in your path / able to run from anywhere
###########################################################
# Required options:
# -i forward_paired_ends.fastQ
# -j reverse_paired_ends.fastQ
# -p pal_finder output - the "(microsatellites with read IDs and primer pairs)" file
#
# By default it does nothing.
#
# Non-required options:
# -assembly:  turn on the pandaseq assembly QC step
# -primers:  filter microsatellite loci to just those which have primers designed
# -occurrences:  filter microsatellite loci to those with primers which appear only once in the dataset
# -rankmotifs:  filter microsatellite loci to just those with perfect motifs. Rank the output by size of motif (largest first)
#
###########################################################
# For repeat analysis, the following extra non-required options may be useful:
# PandaSeq Assembly, and fastq -> fasta conversion are slow.
#
# Do them the first time, generate the files and then skip either, or both steps with the following:
# -a:  skip assembly step
# -c:  skip fastq -> fasta conversion step
#
# # Just make sure to keep the files in the correct directory with the correct filename
###########################################################
#
# Example usage:
# pal_finder_filter_and_assembly.py -i R1.fastq -j R2.fastq -p pal_finder_output_(microsatellites with read IDs and primer pairs).tabular -primers -occurrences -rankmotifs -assembly
#
###########################################################
import Bio, subprocess, argparse, csv, os, re, time
from Bio import SeqIO

# Get values for all the required and optional arguments

parser = argparse.ArgumentParser(description='Frag_length_finder')
parser.add_argument('-i','--input1', help='Forward paired-end fastq file', required=True)
parser.add_argument('-j','--input2', help='Reverse paired-end fastq file', required=True)
parser.add_argument('-p','--pal_finder', help='Output from pal_finder ', required=True)
parser.add_argument('-assembly','--assembly_QC', help='Perform the PandaSeq based QC', nargs='?', const=1, type=int, required=False)
parser.add_argument('-a','--skip_assembly', help='If the assembly has already been run, skip it with -a', nargs='?', const=1, type=int, required=False)
parser.add_argument('-c','--skip_conversion', help='If the fastq to fasta conversion has already been run, skip it with -c', nargs='?', const=1, type=int, required=False)
parser.add_argument('-primers','--filter_by_primer_column', help='Filter pal_finder output to just those loci which have primers designed', nargs='?', const=1, type=int, required=False)
parser.add_argument('-occurrences','--filter_by_occurrences_column', help='Filter pal_finder output to just loci with primers which only occur once in the dataset', nargs='?', const=1, type=int, required=False)
parser.add_argument('-rankmotifs','--filter_and_rank_by_motif_size', help='Filter pal_finder output to just loci which are a perfect repeat unit. Also, rank the loci by motif size (largest first)', nargs='?', const=1, type=int, required=False)
args = vars(parser.parse_args())

# parse arguments

R1_input = args['input1'];
R2_input = args['input2'];
pal_finder_output = args['pal_finder'];
perform_assembly = args['assembly_QC']
skip_assembly = args['skip_assembly'];
skip_conversion = args['skip_conversion'];
filter_primers = args['filter_by_primer_column'];
filter_occurrences = args['filter_by_occurrences_column'];
filter_rank_motifs = args['filter_and_rank_by_motif_size'];

# set default values for arguments
if perform_assembly is None:
    perform_assembly = 0
if skip_assembly is None:
    skip_assembly = 0
if skip_conversion is None:
    skip_conversion = 0
if filter_primers is None:
    filter_primers = 0
if filter_occurrences is None:
    filter_occurrences = 0
if filter_rank_motifs is None:
    filter_rank_motifs = 0

############################################################
# Function List                                            #
############################################################
# Reverse complement a sequence
def ReverseComplement1(seq):
    seq_dict = {'A':'T','T':'A','G':'C','C':'G'}
    return "".join([seq_dict[base] for base in reversed(seq)])

# Convert a .fastq to a .fasta, filter to just lines we want and strip MiSeq barcodes
def fastq_to_fasta(file):
    file_name = os.path.splitext(os.path.basename(file))[0]
    with open(file_name + "_filtered.fasta", "w") as out:
        for record in SeqIO.parse(file, "fastq"):
            ID = str(record.id)
            SEQ = str(record.seq)
            if ID in wanted:
                out.write(">" + ID + "\n" + SEQ + "\n")

# strip the miseq barcodes from a fasta file
def strip_barcodes(file):
    file_name = os.path.splitext(os.path.basename(file))[0]
    with open(file_name + "_adapters_removed.fasta", "w") as out:
        for record in SeqIO.parse(file, "fasta"):
            match = re.search(r'\S*:', record.id)
            if match:
                correct = match.group().rstrip(":")
            else:
                correct = str(record.id)
            SEQ = str(record.seq)
            if correct in wanted:
                out.write(">" + correct + "\n" + SEQ + "\n")

############################################################
# MAIN PROGRAM                                             #
############################################################

if (perform_assembly == 0 and filter_primers == 0 and filter_occurrences == 0 and filter_rank_motifs == 0):
    print "\nNo optional arguments supplied."
    print "\nBy default this program does nothing."
    print "\nNo files produced and no modifications made."
    print "\nFinished.\n"
    exit()

else:
    print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    print "Checking supplied filtering parameters:"
    print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    if filter_primers == 1:
        print "-primers flag supplied. Filtering pal_finder output on the \"Primers found (1=y,0=n)\" column."
    if filter_occurrences == 1:
        print "-occurrences flag supplied. Filtering pal_finder output on the \"Occurances of Forward Primer in Reads\" and \"Occurances of Reverse Primer in Reads\" columns."
    if filter_rank_motifs == 1:
        print "-rankmotifs flag supplied. Filtering pal_finder output on the \"Motifs(bases)\" column to just those with perfect repeats. Ranking output by size of motif (largest first)."

# get lines from the pal_finder output which meet filter settings

# create a set to hold the filtered output
wanted_lines = set()

# read the pal_finder output file into a csv reader
print pal_finder_output
with open (pal_finder_output) as csvfile_infile:
    csv_f = csv.reader(csvfile_infile, delimiter='\t')
    header = csv_f.next()
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + ".filtered", 'w') as csvfile_outfile:
        filewriter = csv.writer(csvfile_outfile, delimiter='\t', lineterminator='\n')
        filewriter.writerow(header)
        for row in csv_f:
# navigate through all different combinations of filter options
        # if the primer filter is switched on
            if filter_primers == 1:
            # check the occurrences of primers field
                if row[5] == "1":
                # if filter occurrences of primers is switched on
                    if filter_occurrences == 1:
                        # check the occurrences of primers field
                        if (row[15] == "1" and row[16] == "1"):
                            # if rank by motif is switched on
                            if filter_rank_motifs == 1:
                                    # check for perfect motifs
                                if row[1].count('(') == 1:
                                            # all 3 filter switched on - write line out to output
                                    filewriter.writerow(row)
                            else:
                                filewriter.writerow(row)
                    elif filter_rank_motifs == 1:
                        if row[1].count('(') == 1:
                            filewriter.writerow(row)
                    else:
                        filewriter.writerow(row)
            elif filter_occurrences == 1:
                if (row[15] == "1" and row[16] == "1"):
                    if filter_rank_motifs == 1:
                        if row[1].count('(') == 1:
                            filewriter.writerow(row)
                    else:
                        filewriter.writerow(row)
            elif filter_rank_motifs == 1:
                if row[1].count('(') == 1:
                    filewriter.writerow(row)
            else:
                filewriter.writerow(row)

# if filter_rank_motifs is active, order the file by the size of the motif
if filter_rank_motifs == 1:
    rank_motif = []
    ranked_list = []
    # read in the non-ordered file and add every entry to rank_motif list
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + ".filtered") as csvfile_ranksize:
        csv_rank = csv.reader(csvfile_ranksize, delimiter='\t')
        header = csv_rank.next()
        for line in csv_rank:
            rank_motif.append(line)

    # open the file ready to write the ordered list
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + ".filtered", 'w') as rank_outfile:
        rankwriter = csv.writer(rank_outfile, delimiter='\t', lineterminator='\n')
        rankwriter.writerow(header)
        count = 2
        while count < 10:
            for row in rank_motif:
                # count size of motif
                motif = re.search(r'[ATCG]*',row[1])
                if motif:
                    the_motif = motif.group()
                    # rank it and write into ranked_list
                    if len(the_motif) == count:
                        ranked_list.insert(0, row)
            count = count +  1
        # write out the ordered list, into the .filtered file
        for row in ranked_list:
            rankwriter.writerow(row)

print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
print "Checking assembly flags supplied:"
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
if perform_assembly == 0:
    print "Assembly flag not supplied. Not performing assembly QC.\n"
if perform_assembly == 1:
    print "-assembly flag supplied: Performing PandaSeq assembly quality checks."
    time.sleep(5)

# Get readID, F primers, R primers and motifs from the filtered pal_finder output
    seqIDs = []
    motif = []
    F_primers = []
    R_primers = []
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + ".filtered") as input_csv:
        pal_finder_csv = csv.reader(input_csv, delimiter='\t')
        header = pal_finder_csv.next()
        for row in pal_finder_csv:
            seqIDs.append(row[0])
            motif.append(row[1])
            F_primers.append(row[7])
            R_primers.append(row[9])

# Get a list of just the unique IDs we want
    wanted = set()
    for line in seqIDs:
        wanted.add(line)

# Assemble the paired end reads into overlapping contigs using PandaSeq
# (can be skipped with the -a flag if assembly has already been run
# and the appropriate files are in the same directory as the script,
# and named "Assembly.fasta" and "Assembly_adapters_removed.fasta")
#
# I suggest you run this script WITHOUT -a first, and then use the -a flag in
# any subsequent reanalysis

    if skip_assembly == 0:
        pandaseq_command = 'pandaseq -A pear -f ' + R1_input + ' -r ' + R2_input + ' -o 25 -t 0.95 -w Assembly.fasta'
        subprocess.call(pandaseq_command, shell=True)
        strip_barcodes("Assembly.fasta")
        print "\nPaired end reads been assembled into overlapping reads."
        print "\nFor future analysis, you can skip this assembly step using the -a flag, provided that the assembly.fasta file is intact and in the same location."
    else:
        print "\n(Skipping the assembly step as you provided the -a flag)"

# FastQ files need to be converted to fasta. Again, I suggest running this section
# the first time WITHOUT the -c flag and then skipping it later using the -c flag
# Make sure the fasta files are in the same location and do not change the filenames

    if skip_conversion ==0:
        fastq_to_fasta(R1_input)
        fastq_to_fasta(R2_input)
        print "\nThe input fastq files have been converted to the fasta format."
        print "\nFor any future analysis, you can skip this conversion step using the -c flag, provided that the fasta files are intact and in the same location."
    else:
        print "\n(Skipping the fastq -> fasta conversion as you provided the -c flag)"

# get the files and everything else we will need
    assembly_file = "Assembly_adapters_removed.fasta" # Assembled fasta file
    R1_fasta = os.path.splitext(os.path.basename(R1_input))[0] + "_filtered.fasta"    # filtered R1 reads
    R2_fasta = os.path.splitext(os.path.basename(R2_input))[0] + "_filtered.fasta"   # filtered R2 reads
    outputfilename = os.path.splitext(os.path.basename(R1_input))[0]

# parse the files with SeqIO
    assembly_sequences = SeqIO.parse(assembly_file,'fasta')
    R1fasta_sequences = SeqIO.parse(R1_fasta,'fasta')

# create some empty lists to hold the ID tags we are interested in
    assembly_IDs = []
    fasta_IDs = []

# populate the above lists with sequence IDs
    for sequence in assembly_sequences:
        assembly_IDs.append(sequence.id)
    for sequence in R1fasta_sequences:
        fasta_IDs.append(sequence.id)

# Index the 3 fasta files
    assembly_sequences_index = SeqIO.index(assembly_file,'fasta')
    R1fasta_sequences_index = SeqIO.index(R1_fasta,'fasta')
    R2fasta_sequences_index = SeqIO.index(R2_fasta,'fasta')

# prepare the output file
    with open (outputfilename + "_pal_finder_assembly_output.txt", 'w') as outputfile:
        outputfile.write("readPairID\t Forward Primer\t F Primer Position in Assembled Read\t Reverse Primer\t R Primer Position in Assembled Read\t Predicted Amplicon Size (bp)\t Motifs(bases)\t Assembled Read ID\t Assembled Read Sequence\t Raw Forward Read ID\t Raw Forward Read Sequence\t Raw Reverse Read ID\t Raw Reverse Read Sequence\n")

# cycle through parameters from the pal_finder output
        for x, y, z, a in zip(seqIDs, F_primers, R_primers, motif):
            if str(x) in assembly_IDs:
            # get the raw sequences ready to go into the output file
                assembly_seq = (assembly_sequences_index.get_raw(x).decode())
            # fasta entries need to be converted to single line so they sit nicely in the output
                assembly_output = assembly_seq.replace("\n","\t")
                R1_fasta_seq = (R1fasta_sequences_index.get_raw(x).decode())
                R1_output = R1_fasta_seq.replace("\n","\t",1)
                R1_output = R1_output.replace("\n","")
                R2_fasta_seq = (R2fasta_sequences_index.get_raw(x).decode())
                R2_output = R2_fasta_seq.replace("\n","\t",1)
                R2_output = R2_output.replace("\n","")
                assembly_no_id = '\n'.join(assembly_seq.split('\n')[1:])

# check that both primer sequences can be seen in the assembled contig
                if y or ReverseComplement1(y) in assembly_no_id and z or ReverseComplement1(z) in assembly_no_id:
                    if y in assembly_no_id:
                    # get the positions of the primers in the assembly to predict fragment length
                        F_position = assembly_no_id.index(y)+len(y)+1
                    if ReverseComplement1(y) in assembly_no_id:
                        F_position = assembly_no_id.index(ReverseComplement1(y))+len(ReverseComplement1(y))+1
                    if z in assembly_no_id:
                        R_position = assembly_no_id.index(z)+1
                    if ReverseComplement1(z) in assembly_no_id:
                        R_position = assembly_no_id.index(ReverseComplement1(z))+1
                # calculate fragment length
                    fragment_length = R_position-F_position

# write everything out into the output file
                    output = (str(x) + "\t" + y + "\t" + str(F_position) + "\t" + (z) + "\t" + str(R_position) + "\t" + str(fragment_length) + "\t" + a + "\t" + assembly_output + R1_output + "\t" + R2_output + "\n")
                    outputfile.write(output)
    print "\nFinished\n"
else:
    if (skip_assembly == 1 or skip_conversion == 1):
        print "\nERROR: You cannot supply the -a flag or the -c flag without also supplying the -assembly flag.\n"
        print "\nFinished\n"
