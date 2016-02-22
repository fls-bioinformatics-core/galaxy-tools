#!/usr/bin/python -tt
#
# pal_filter
# https://github.com/graemefox/pal_filter
#
################################################################################
# Graeme Fox - 15/02/2016 - graeme.fox@manchester.ac.uk
# Tested on 64-bit Ubuntu, with Python 2.7
#
################################################################################
# PROGRAM DESCRIPTION
#
# Program to pick optimum loci from the output of pal_finder_v0.02.04
#
# This program can be used to filter output from pal_finder and choose the
# 'optimum' loci.
#
# For the paper referncing this workflow, see Griffiths et al.
# (unpublished as of 15/02/2016) (sarah.griffiths-5@postgrad.manchester.ac.uk)
#
################################################################################
#
# This program also contains a quality-check method to improve the rate of PCR
# success. For this QC method, paired end reads are assembled using
# PANDAseq so you must have PANDAseq installed.
#
# For the paper referencing this assembly-QC method see Fox et al.
# (unpublished as of 15/02/2016) (graeme.fox@manchester.ac.uk)
#
# For best results in PCR for marker development, I suggest enabling all the
# filter options AND the assembly based QC
#
################################################################################
# REQUIREMENTS
#
# Must have Biopython installed (www.biopython.org).
#
# If you with to perform the assembly QC step, you must have:
# PandaSeq (https://github.com/neufeld/pandaseq)
# PandaSeq must be in your $PATH / able to run from anywhere
################################################################################
# REQUIRED OPTIONS
#
# -i forward_paired_ends.fastQ
# -j reverse_paired_ends.fastQ
# -p pal_finder output - the "(microsatellites with read IDs and
# primer pairs)" file
#
# By default the program does nothing....
#
# NON-REQUIRED OPTIONS
#
# -assembly:  turn on the pandaseq assembly QC step
# -primers:  filter microsatellite loci to just those which
# have primers designed
#
# -occurrences:  filter microsatellite loci to those with primers
# which appear only once in the dataset
#
# -rankmotifs:  filter microsatellite loci to just those with perfect motifs.
# Rank the output by size of motif (largest first)
#
###########################################################
# For repeat analysis, the following extra non-required options may be useful:
#
# Since PandaSeq Assembly, and fastq -> fasta conversion are slow, do them the
# first time, generate the files and then skip either, or both steps with
# the following:
#
# -a:  skip assembly step
# -c:  skip fastq -> fasta conversion step
#
# Just make sure to keep the assembled/converted files in the correct directory
# with the correct filename(s)
###########################################################
#
# EXAMPLE USAGE:
#
# pal_filtery.py -i R1.fastq -j R2.fastq
# -p pal_finder_output.tabular -primers -occurrences -rankmotifs -assembly
#
###########################################################
import Bio, subprocess, argparse, csv, os, re, time
from Bio import SeqIO

# Get values for all the required and optional arguments

parser = argparse.ArgumentParser(description='pal_filter')
parser.add_argument('-i','--input1', help='Forward paired-end fastq file', \
                    required=True)

parser.add_argument('-j','--input2', help='Reverse paired-end fastq file', \
                    required=True)

parser.add_argument('-p','--pal_finder', help='Output from pal_finder ', \
                    required=True)

parser.add_argument('-assembly','--assembly_QC', help='Perform the PandaSeq \
                    based QC', nargs='?', const=1, type=int, required=False)

parser.add_argument('-a','--skip_assembly', help='If the assembly has already \
                    been run, skip it with -a', nargs='?', const=1, \
                    type=int, required=False)

parser.add_argument('-c','--skip_conversion', help='If the fastq to fasta \
                    conversion has already been run, skip it with -c', \
                    nargs='?', const=1, type=int, required=False)

parser.add_argument('-primers','--filter_by_primer_column', help='Filter \
                    pal_finder output to just those loci which have primers \
                    designed', nargs='?', const=1, type=int, required=False)

parser.add_argument('-occurrences','--filter_by_occurrences_column', \
                    help='Filter pal_finder output to just loci with primers \
                    which only occur once in the dataset', nargs='?', \
                    const=1, type=int, required=False)

parser.add_argument('-rankmotifs','--filter_and_rank_by_motif_size', \
                    help='Filter pal_finder output to just loci which are a \
                    perfect repeat unit. Also, rank the loci by motif size \
                    (largest first)', nargs='?', const=1, type=int, \
                    required=False)

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

# Convert a .fastq to a .fasta, filter to just lines we want
# and strip MiSeq barcodes

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
print "\n~~~~~~~~~~"
print "pal_filter"
print "~~~~~~~~~~\n"
time.sleep(1)
print "\"Find the optimum loci in your pal_finder output and increase "\
                    "the rate of successful microsatellite marker development\""
print "\nSee Griffiths et al. (currently unpublished) for more details......"
time.sleep(2)

if (perform_assembly == 0 and filter_primers == 0 and filter_occurrences == 0 \
                    and filter_rank_motifs == 0):
    print "\nNo optional arguments supplied."
    print "\nBy default this program does nothing."
    print "\nNo files produced and no modifications made."
    print "\nFinished.\n"
    exit()

else:
    print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    print "Checking supplied filtering parameters:"
    print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    time.sleep(2)
    if filter_primers == 1:
        print "-primers flag supplied."
        print "Filtering pal_finder output on the \"Primers found (1=y,0=n)\"" \
                    " column."
        print "Only rows where primers have successfully been designed will"\
                    " pass the filter.\n"
        time.sleep(2)
    if filter_occurrences == 1:
        print "-occurrences flag supplied."
        print "Filtering pal_finder output on the \"Occurences of Forward" \
                    " Primer in Reads\" and \"Occurences of Reverse Primer" \
                    " in Reads\" columns."
        print "Only rows where both primers occur only a single time in the"\
                    " reads pass the filter.\n"
        time.sleep(2)
    if filter_rank_motifs == 1:
        print "-rankmotifs flag supplied."
        print "Filtering pal_finder output on the \"Motifs(bases)\" column to" \
                    " just those with perfect repeats."
        print "Only rows containing 'perfect' repeats will pass the filter."
        print "Also, ranking output by size of motif (largest first).\n"
        time.sleep(2)
# index the raw fastq files so that the sequences can be pulled out and
# added to the filtered output file

# Indexing input sequence files
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
print "Indexing FastQ files....."
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
R1fastq_sequences_index = SeqIO.index(R1_input,'fastq')
R2fastq_sequences_index = SeqIO.index(R2_input,'fastq')
print "Indexing complete."

# create a set to hold the filtered output
wanted_lines = set()

# get lines from the pal_finder output which meet filter settings

# read the pal_finder output file into a csv reader
with open (pal_finder_output) as csvfile_infile:
    csv_f = csv.reader(csvfile_infile, delimiter='\t')
    header =  csv_f.next()
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + \
                    ".filtered", 'w') as csvfile_outfile:
# write the header line for the output file
        csvfile_outfile.write('\t'.join(header) + "\tR1_Sequence_ID\t\
                    R1_Sequence\tR2_Sequence_ID\tR2_Sequence\n")
        for row in csv_f:
# get the sequence ID
            seq_ID = row[0]
# get the raw sequence reads and convert to a format that can
# go into a tsv file
            R1_sequence = R1fastq_sequences_index[seq_ID].format("fasta").\
                    replace("\n","\t",1).replace("\n","")
            R2_sequence = R2fastq_sequences_index[seq_ID].format("fasta").\
                    replace("\n","\t",1).replace("\n","")
            seq_info = "\t" + R1_sequence + "\t" + R2_sequence + "\n"
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
# all 3 filter switched on
# write line out to output
                                    csvfile_outfile.write('\t'.join(row) + \
                                                        seq_info)

                            else:
                                csvfile_outfile.write('\t'.join(row) + seq_info)
                    elif filter_rank_motifs == 1:
                        if row[1].count('(') == 1:
                            csvfile_outfile.write('\t'.join(row) + seq_info)
                    else:
                        csvfile_outfile.write('\t'.join(row) + seq_info)
            elif filter_occurrences == 1:
                if (row[15] == "1" and row[16] == "1"):
                    if filter_rank_motifs == 1:
                        if row[1].count('(') == 1:
                            csvfile_outfile.write('\t'.join(row) + seq_info)
                    else:
                        csvfile_outfile.write('\t'.join(row) + seq_info)
            elif filter_rank_motifs == 1:
                if row[1].count('(') == 1:
                    csvfile_outfile.write('\t'.join(row) + seq_info)
            else:
                csvfile_outfile.write('\t'.join(row) + seq_info)

# if filter_rank_motifs is active, order the file by the size of the motif
if filter_rank_motifs == 1:
    rank_motif = []
    ranked_list = []
# read in the non-ordered file and add every entry to rank_motif list
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + \
                        ".filtered") as csvfile_ranksize:
        csv_rank = csv.reader(csvfile_ranksize, delimiter='\t')
        header = csv_rank.next()
        for line in csv_rank:
            rank_motif.append(line)

# open the file ready to write the ordered list
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + \
                        ".filtered", 'w') as rank_outfile:
        rankwriter = csv.writer(rank_outfile, delimiter='\t', \
                        lineterminator='\n')
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
    print "See Fox et al. (currently unpublished) for full details on the"\
                        " quality-check process.\n"
    time.sleep(5)

# Get readID, F primers, R primers and motifs from filtered pal_finder output
    seqIDs = []
    motif = []
    F_primers = []
    R_primers = []
    with open(os.path.splitext(os.path.basename(pal_finder_output))[0] + \
                    ".filtered") as input_csv:
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
# The first time you riun the script you MUST not enable the -a flag.t
# but you are able to skip the assembly in subsequent analysis using the
# -a flag.

    if skip_assembly == 0:
        pandaseq_command = 'pandaseq -A pear -f ' + R1_input + ' -r ' + \
                        R2_input + ' -o 25 -t 0.95 -w Assembly.fasta'
        subprocess.call(pandaseq_command, shell=True)
        strip_barcodes("Assembly.fasta")
        print "\nPaired end reads been assembled into overlapping reads."
        print "\nFor future analysis, you can skip this assembly step using \
                        the -a flag, provided that the assembly.fasta file is \
                        intact and in the same location."
    else:
        print "\n(Skipping the assembly step as you provided the -a flag)"

# Fastq files need to be converted to fasta. The first time you run the script
# you MUST not enable the -c flag, but you are able to skip the conversion
# later using the -c flag. Make sure the fasta files are in the same location
#and do not change the filenames

    if skip_conversion ==0:
        fastq_to_fasta(R1_input)
        fastq_to_fasta(R2_input)
        print "\nThe input fastq files have been converted to the fasta format."
        print "\nFor any future analysis, you can skip this conversion step \
                        using the -c flag, provided that the fasta files \
                        are intact and in the same location."
    else:
        print "\n(Skipping the fastq -> fasta conversion as you provided the" \
                        " -c flag).\n"

# get the files and everything else we will need

# Assembled fasta file
    assembly_file = "Assembly_adapters_removed.fasta"
# filtered R1 reads
    R1_fasta = os.path.splitext(os.path.basename(R1_input))[0] + \
                        "_filtered.fasta"
# filtered R2 reads
    R2_fasta = os.path.splitext(os.path.basename(R2_input))[0] + \
                        "_filtered.fasta"

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

# Index the assembly fasta file
    assembly_sequences_index = SeqIO.index(assembly_file,'fasta')
    R1fasta_sequences_index = SeqIO.index(R1_fasta,'fasta')
    R2fasta_sequences_index = SeqIO.index(R2_fasta,'fasta')

# prepare the output file
    with open (outputfilename + "_pal_filter_assembly_output.txt", 'w') \
                    as outputfile:
# write the headers for the output file
        outputfile.write("readPairID\t Forward Primer\t F Primer Position in \
                    Assembled Read\t Reverse Primer\t R Primer Position in \
                    Assembled Read\t Motifs(bases)\t Assembled Read ID\t \
                    Assembled Read Sequence\t Raw Forward Read ID\t Raw \
                    Forward Read Sequence\t Raw Reverse Read ID\t Raw Reverse \
                    Read Sequence\n")

# cycle through parameters from the pal_finder output
        for x, y, z, a in zip(seqIDs, F_primers, R_primers, motif):
            if str(x) in assembly_IDs:
            # get the raw sequences ready to go into the output file
                assembly_seq = (assembly_sequences_index.get_raw(x).decode())
# fasta entries need to be converted to single line so sit nicely in the output
                assembly_output = assembly_seq.replace("\n","\t")
                R1_fasta_seq = (R1fasta_sequences_index.get_raw(x).decode())
                R1_output = R1_fasta_seq.replace("\n","\t",1).replace("\n","")
                R2_fasta_seq = (R2fasta_sequences_index.get_raw(x).decode())
                R2_output = R2_fasta_seq.replace("\n","\t",1).replace("\n","")
                assembly_no_id = '\n'.join(assembly_seq.split('\n')[1:])

# check that both primer sequences can be seen in the assembled contig
                if y or ReverseComplement1(y) in assembly_no_id and z or \
                                    ReverseComplement1(z) in assembly_no_id:
                    if y in assembly_no_id:
# get the positions of the primers in the assembly to predict fragment length
                        F_position = assembly_no_id.index(y)+len(y)+1
                    if ReverseComplement1(y) in assembly_no_id:
                        F_position = assembly_no_id.index(ReverseComplement1(y)\
                                            )+len(ReverseComplement1(y))+1
                    if z in assembly_no_id:
                        R_position = assembly_no_id.index(z)+1
                    if ReverseComplement1(z) in assembly_no_id:
                        R_position = assembly_no_id.index(ReverseComplement1(z)\
                                            )+1

# write everything out into the output file
                    output = (str(x) + "\t" + y + "\t" + str(F_position) \
                                        + "\t" + (z) + "\t" + str(R_position) \
                                        + "\t" + a + "\t" + assembly_output \
                                        + R1_output + "\t" + R2_output + "\n")
                    outputfile.write(output)
        print "\nPANDAseq quality check complete."
        print "Results from PANDAseq quality check (and filtering, if any" \
                                " any filters enabled) written to output file" \
                                " ending \"_pal_filter_assembly_output.txt\".\n\n"

    print "Filtering of pal_finder results complete."
    print "Filtered results written to output file ending \".filtered\"."
    print "\nFinished\n"
else:
    if (skip_assembly == 1 or skip_conversion == 1):
        print "\nERROR: You cannot supply the -a flag or the -c flag without \
                    also supplying the -assembly flag.\n"

        print "\nProgram Finished\n"
