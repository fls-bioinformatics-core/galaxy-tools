#!/usr/bin/python -tt
"""
pal_filter
https://github.com/graemefox/pal_filter

Graeme Fox - 03/03/2016 - graeme.fox@manchester.ac.uk
Tested on 64-bit Ubuntu, with Python 2.7

~~~~~~~~~~~~~~~~~~~
PROGRAM DESCRIPTION

Program to pick optimum loci from the output of pal_finder_v0.02.04

This program can be used to filter output from pal_finder and choose the
'optimum' loci.

For the paper referncing this workflow, see Griffiths et al.
(unpublished as of 15/02/2016) (sarah.griffiths-5@postgrad.manchester.ac.uk)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This program also contains a quality-check method to improve the rate of PCR
success. For this QC method, paired end reads are assembled using
PANDAseq so you must have PANDAseq installed.

For the paper referencing this assembly-QC method see Fox et al.
(unpublished as of 15/02/2016) (graeme.fox@manchester.ac.uk)

For best results in PCR for marker development, I suggest enabling all the
filter options AND the assembly based QC

~~~~~~~~~~~~
REQUIREMENTS

Must have Biopython installed (www.biopython.org).

If you with to perform the assembly QC step, you must have:
PandaSeq (https://github.com/neufeld/pandaseq)
PandaSeq must be in your $PATH / able to run from anywhere

~~~~~~~~~~~~~~~~
REQUIRED OPTIONS

-i forward_paired_ends.fastQ
-j reverse_paired_ends.fastQ
-p pal_finder output - by default pal_finder names this "x_PAL_summary.txt"

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BY DEFAULT THIS PROGRAM DOES NOTHING. ENABLE SOME OF THE OPTIONS BELOW.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NON-REQUIRED OPTIONS

-assembly:  turn on the pandaseq assembly QC step

-primers:  filter microsatellite loci to just those which have primers designed

-occurrences:  filter microsatellite loci to those with primers
 which appear only once in the dataset

-rankmotifs:  filter microsatellite loci to just those with perfect motifs.
 Rank the output by size of motif (largest first)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
For repeat analysis, the following extra non-required options may be useful:

Since PandaSeq Assembly, and fastq -> fasta conversion are slow, do them the
first time, generate the files and then skip either, or both steps with
the following:

-a:  skip assembly step
-c:  skip fastq -> fasta conversion step

Just make sure to keep the assembled/converted files in the correct directory
with the correct filename(s)

~~~~~~~~~~~~~~~
EXAMPLE USAGE:

pal_filtery.py -i R1.fastq -j R2.fastq
 -p pal_finder_output.tabular -primers -occurrences -rankmotifs -assembly

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"""
import Bio, subprocess, argparse, csv, os, re, time
from Bio import SeqIO
__version__ = "1.0.0"
############################################################
# Function List                                            #
############################################################
def ReverseComplement1(seq):
    """
    take a nucleotide sequence and reverse-complement it
    """
    seq_dict = {'A':'T','T':'A','G':'C','C':'G'}
    return "".join([seq_dict[base] for base in reversed(seq)])

def fastq_to_fasta(input_file, wanted_set):
    """
    take a file in fastq format, convert to fasta format and filter on
    the set of sequences that we want to keep
    """
    file_name = os.path.splitext(os.path.basename(input_file))[0]
    with open(file_name + "_filtered.fasta", "w") as out:
        for record in SeqIO.parse(input_file, "fastq"):
            ID = str(record.id)
            SEQ = str(record.seq)
            if ID in wanted_set:
                out.write(">" + ID + "\n" + SEQ + "\n")

def strip_barcodes(input_file, wanted_set):
    """
    take fastq data containing sequencing barcodes and strip the barcode
    from each sequence. Filter on the set of sequences that we want to keep
    """
    file_name = os.path.splitext(os.path.basename(input_file))[0]
    with open(file_name + "_adapters_removed.fasta", "w") as out:
        for record in SeqIO.parse(input_file, "fasta"):
            match = re.search(r'\S*:', record.id)
            if match:
                correct = match.group().rstrip(":")
            else:
                correct = str(record.id)
            SEQ = str(record.seq)
            if correct in wanted_set:
                out.write(">" + correct + "\n" + SEQ + "\n")

############################################################
# MAIN PROGRAM                                             #
############################################################
print "\n~~~~~~~~~~"
print "pal_filter"
print "~~~~~~~~~~"
print "Version: " + __version__
time.sleep(1)
print "\nFind the optimum loci in your pal_finder output and increase "\
                    "the rate of successful microsatellite marker development"
print "\nSee Griffiths et al. (currently unpublished) for more details......"
time.sleep(2)

# Get values for all the required and optional arguments

parser = argparse.ArgumentParser(description='pal_filter')
parser.add_argument('-i','--input1', help='Forward paired-end fastq file', \
                    required=True)

parser.add_argument('-j','--input2', help='Reverse paired-end fastq file', \
                    required=True)

parser.add_argument('-p','--pal_finder', help='Output from pal_finder ', \
                    required=True)

parser.add_argument('-assembly', help='Perform the PandaSeq based QC', \
                    action='store_true')

parser.add_argument('-a','--skip_assembly', help='If the assembly has already \
                    been run, skip it with -a', action='store_true')

parser.add_argument('-c','--skip_conversion', help='If the fastq to fasta \
                    conversion has already been run, skip it with -c', \
                    action='store_true')

parser.add_argument('-primers', help='Filter \
                    pal_finder output to just those loci which have primers \
                    designed', action='store_true')

parser.add_argument('-occurrences', \
                    help='Filter pal_finder output to just loci with primers \
                    which only occur once in the dataset', action='store_true')

parser.add_argument('-rankmotifs', \
                    help='Filter pal_finder output to just loci which are a \
                    perfect repeat unit. Also, rank the loci by motif size \
                    (largest first)', action='store_true')

parser.add_argument('-v', '--get_version', help='Print the version number of \
                    this pal_filter script', action='store_true')

args = parser.parse_args()

if not args.assembly and not args.primers and not args.occurrences \
        and not args.rankmotifs:
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
    if args.get_version:
        print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        print "pal_filter version is " + __version__ + " (03/03/2016)"
        print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    if args.primers:
        print "-primers flag supplied."
        print "Filtering pal_finder output on the \"Primers found (1=y,0=n)\"" \
                    " column."
        print "Only rows where primers have successfully been designed will"\
                    " pass the filter.\n"
        time.sleep(2)
    if args.occurrences:
        print "-occurrences flag supplied."
        print "Filtering pal_finder output on the \"Occurrences of Forward" \
                    " Primer in Reads\" and \"Occurrences of Reverse Primer" \
                    " in Reads\" columns."
        print "Only rows where both primers occur only a single time in the"\
                    " reads pass the filter.\n"
        time.sleep(2)
    if args.rankmotifs:
        print "-rankmotifs flag supplied."
        print "Filtering pal_finder output on the \"Motifs(bases)\" column to" \
                    " just those with perfect repeats."
        print "Only rows containing 'perfect' repeats will pass the filter."
        print "Also, ranking output by size of motif (largest first).\n"
        time.sleep(2)

# index the raw fastq files so that the sequences can be pulled out and
# added to the filtered output file
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
print "Indexing FastQ files....."
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
R1fastq_sequences_index = SeqIO.index(args.input1,'fastq')
R2fastq_sequences_index = SeqIO.index(args.input2,'fastq')
print "Indexing complete."

# create a set to hold the filtered output
wanted_lines = set()

# get lines from the pal_finder output which meet filter settings
# read the pal_finder output file into a csv reader
with open (args.pal_finder) as csvfile_infile:
    csv_f = csv.reader(csvfile_infile, delimiter='\t')
    header = csv_f.next()
    header.extend(("R1_Sequence_ID", \
                   "R1_Sequence", \
                   "R2_Sequence_ID", \
                   "R2_Sequence" + "\n"))
    with open( \
            os.path.splitext(os.path.basename(args.pal_finder))[0] + \
            ".filtered", 'w') as csvfile_outfile:
        # write the header line for the output file
        csvfile_outfile.write('\t'.join(header))
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
            if args.primers:
                # check the occurrences of primers field
                if row[5] == "1":
                    # if filter occurrences of primers is switched on
                    if args.occurrences:
                        # check the occurrences of primers field
                        if (row[15] == "1" and row[16] == "1"):
                            # if rank by motif is switched on
                            if args.rankmotifs:
                                # check for perfect motifs
                                if row[1].count('(') == 1:
                                    # all 3 filter switched on
                                    # write line out to output
                                    csvfile_outfile.write('\t'.join(row) + \
                                                        seq_info)
                            else:
                                csvfile_outfile.write('\t'.join(row) + seq_info)
                    elif args.rankmotifs:
                        if row[1].count('(') == 1:
                            csvfile_outfile.write('\t'.join(row) + seq_info)
                    else:
                        csvfile_outfile.write('\t'.join(row) + seq_info)
            elif args.occurrences:
                if (row[15] == "1" and row[16] == "1"):
                    if args.rankmotifs:
                        if row[1].count('(') == 1:
                            csvfile_outfile.write('\t'.join(row) + seq_info)
                    else:
                        csvfile_outfile.write('\t'.join(row) + seq_info)
            elif args.rankmotifs:
                if row[1].count('(') == 1:
                    csvfile_outfile.write('\t'.join(row) + seq_info)
            else:
                csvfile_outfile.write('\t'.join(row) + seq_info)

# if filter_rank_motifs is active, order the file by the size of the motif
if args.rankmotifs:
    rank_motif = []
    ranked_list = []
# read in the non-ordered file and add every entry to rank_motif list
    with open( \
            os.path.splitext(os.path.basename(args.pal_finder))[0] + \
            ".filtered") as csvfile_ranksize:
        csv_rank = csv.reader(csvfile_ranksize, delimiter='\t')
        header = csv_rank.next()
        for line in csv_rank:
            rank_motif.append(line)

    # open the file ready to write the ordered list
    with open( \
            os.path.splitext(os.path.basename(args.pal_finder))[0] + \
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
if not args.assembly:
    print "Assembly flag not supplied. Not performing assembly QC.\n"
if args.assembly:
    print "-assembly flag supplied: Perform PandaSeq assembly quality checks."
    print "See Fox et al. (currently unpublished) for full details on the"\
                        " quality-check process.\n"
    time.sleep(5)

# Get readID, F primers, R primers and motifs from filtered pal_finder output
    seqIDs = []
    motif = []
    F_primers = []
    R_primers = []
    with open( \
            os.path.splitext(os.path.basename(args.pal_finder))[0] + \
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
    """
    Assemble the paired end reads into overlapping contigs using PandaSeq
    (can be skipped with the -a flag if assembly has already been run
    and the appropriate files are in the same directory as the script,
    and named "Assembly.fasta" and "Assembly_adapters_removed.fasta")

    The first time you riun the script you MUST not enable the -a flag.t
    but you are able to skip the assembly in subsequent analysis using the
    -a flag.
    """
    if not args.skip_assembly:
        pandaseq_command = 'pandaseq -A pear -f ' + args.input1 + ' -r ' + \
                        args.input2 + ' -o 25 -t 0.95 -w Assembly.fasta'
        subprocess.call(pandaseq_command, shell=True)
        strip_barcodes("Assembly.fasta", wanted)
        print "\nPaired end reads been assembled into overlapping reads."
        print "\nFor future analysis, you can skip this assembly step using" \
                        " the -a flag, provided that the assembly.fasta file" \
                        " is intact and in the same location."
    else:
        print "\n(Skipping the assembly step as you provided the -a flag)"
    """
    Fastq files need to be converted to fasta. The first time you run the script
    you MUST not enable the -c flag, but you are able to skip the conversion
    later using the -c flag. Make sure the fasta files are in the same location
    and do not change the filenames
    """
    if not args.skip_conversion:
        fastq_to_fasta(args.input1, wanted)
        fastq_to_fasta(args.input2, wanted)
        print "\nThe input fastq files have been converted to the fasta format."
        print "\nFor any future analysis, you can skip this conversion step" \
                        " using the -c flag, provided that the fasta files" \
                        " are intact and in the same location."
    else:
        print "\n(Skipping the fastq -> fasta conversion as you provided the" \
                        " -c flag).\n"

    # get the files and everything else needed
    # Assembled fasta file
    assembly_file = "Assembly_adapters_removed.fasta"
    # filtered R1 reads
    R1_fasta = os.path.splitext( \
        os.path.basename(args.input1))[0] + "_filtered.fasta"
    # filtered R2 reads
    R2_fasta = os.path.splitext( \
        os.path.basename(args.input2))[0] + "_filtered.fasta"
    outputfilename = os.path.splitext(os.path.basename(args.input1))[0]
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
    with open ( \
            outputfilename + "_pal_filter_assembly_output.txt", 'w') \
            as outputfile:
        # write the headers for the output file
        output_header = ("readPairID", \
                    "Forward Primer",\
                    "F Primer Position in Assembled Read", \
                    "Reverse Primer", \
                    "R Primer Position in Assembled Read", \
                    "Motifs(bases)", \
                    "Assembled Read ID", \
                    "Assembled Read Sequence", \
                    "Raw Forward Read ID", \
                    "Raw Forward Read Sequence", \
                    "Raw Reverse Read ID", \
                    "Raw Reverse Read Sequence\n")
        outputfile.write("\t".join(output_header))

        # cycle through parameters from the pal_finder output
        for x, y, z, a in zip(seqIDs, F_primers, R_primers, motif):
            if str(x) in assembly_IDs:
            # get the raw sequences ready to go into the output file
                assembly_seq = (assembly_sequences_index.get_raw(x).decode())
                # fasta entries need to be converted to single line so sit
                # nicely in the output
                assembly_output = assembly_seq.replace("\n","\t").strip('\t')
                R1_fasta_seq = (R1fasta_sequences_index.get_raw(x).decode())
                R1_output = R1_fasta_seq.replace("\n","\t",1).replace("\n","")
                R2_fasta_seq = (R2fasta_sequences_index.get_raw(x).decode())
                R2_output = R2_fasta_seq.replace("\n","\t",1).replace("\n","")
                assembly_no_id = '\n'.join(assembly_seq.split('\n')[1:])

                # check that both primer sequences can be seen in the
                # assembled contig
                if y or ReverseComplement1(y) in assembly_no_id and z or \
                                    ReverseComplement1(z) in assembly_no_id:
                    if y in assembly_no_id:
                        # get the positions of the primers in the assembly
                        # (can be used to predict fragment length)
                        F_position = assembly_no_id.index(y)+len(y)+1
                    if ReverseComplement1(y) in assembly_no_id:
                        F_position = assembly_no_id.index( \
                            ReverseComplement1(y))+len(ReverseComplement1(y))+1
                    if z in assembly_no_id:
                        R_position = assembly_no_id.index(z)+1
                    if ReverseComplement1(z) in assembly_no_id:
                        R_position = assembly_no_id.index( \
                        ReverseComplement1(z))+1
                    output = (str(x),
                                str(y),
                                str(F_position),
                                str(z),
                                str(R_position),
                                str(a),
                                str(assembly_output),
                                str(R1_output),
                                str(R2_output + "\n"))
                    outputfile.write("\t".join(output))
        print "\nPANDAseq quality check complete."
        print "Results from PANDAseq quality check (and filtering, if any" \
                                " any filters enabled) written to output file" \
                                " ending \"_pal_filter_assembly_output.txt\".\n"
    print "Filtering of pal_finder results complete."
    print "Filtered results written to output file ending \".filtered\"."
    print "\nFinished\n"
else:
    if args.skip_assembly or args.skip_conversion:
        print "\nERROR: You cannot supply the -a flag or the -c flag without \
                    also supplying the -assembly flag.\n"
        print "\nProgram Finished\n"
