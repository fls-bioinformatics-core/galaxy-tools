#!/usr/bin/env python

import argparse
import random
from Bio.SeqIO.QualityIO import FastqGeneralIterator

def count_reads(fastq):
    """
    Count number of reads in a Fastq file
    """
    n = 0
    with open(fastq,'r') as fq:
        while True:
            buf = fq.read()
            n += buf.count('\n')
            if buf == "": break
    return n/4

def fastq_subset(fastq_in,fastq_out,indices):
    """
    Output a subset of reads from a Fastq file

    The reads to output are specifed by a list
    of integer indices; only reads at those
    positions in the input file will be written
    to the output.
    """
    with open(fastq_in,'r') as fq_in:
        fq_out = open(fastq_out,'w')
        i = 0
        for title,seq,qual in FastqGeneralIterator(fq_in):
            if i in indices:
                fq_out.write("@%s\n%s\n+\n%s\n" % (title,
                                                   seq,
                                                   qual))
            i += 1
        fq_out.close()

if __name__ == "__main__":

    p = argparse.ArgumentParser()
    p.add_argument("fastq_r1")
    p.add_argument("fastq_r2")
    p.add_argument("-n",
                   dest="subset_size",
                   default=None,
                   help="subset size")
    p.add_argument("-s",
                   dest="seed",
                   type=int,
                   default=None,
                   help="seed for random number generator")
    args = p.parse_args()

    print "Processing fastq pair:"
    print "\t%s" % args.fastq_r1
    print "\t%s" % args.fastq_r2

    nreads = count_reads(args.fastq_r1)
    print "Counted %d reads in %s" % (nreads,args.fastq_r1)

    if args.subset_size is not None:
        subset_size = float(args.subset_size)
        if subset_size < 1.0:
            subset_size = int(nreads*subset_size)
        else:
            subset_size = int(subset_size)
        print "Extracting subset of reads: %s" % subset_size
        if args.seed is not None:
            print "Random number generator seed: %d" % args.seed
            random.seed(args.seed)
        subset = random.sample(xrange(nreads),subset_size)
        fastq_subset(args.fastq_r1,"subset_r1.fq",subset)
        fastq_subset(args.fastq_r2,"subset_r2.fq",subset)
