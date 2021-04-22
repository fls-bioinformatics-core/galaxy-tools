#!/usr/bin/env python

import argparse
import random
import gzip
from builtins import range

CHUNKSIZE = 102400

def getlines(filen):
    """
    Efficiently fetch lines from a file one by one

    Generator function implementing an efficient
    method of reading lines sequentially from a file,
    attempting to minimise the number of read operations
    and performing the line splitting in memory:

    >>> for line in getlines(filen):
    >>> ...do something...

    Input file can be gzipped; this function should
    handle this invisibly provided the file names ends
    with '.gz'.

    Arguments:
      filen (str): path of the file to read lines from

    Yields:
      String: next line of text from the file, with any
        newline character removed.
    """
    if filen.split('.')[-1] == 'gz':
        fp = gzip.open(filen,'rt')
    else:
        fp = open(filen,'rt')
    # Read in data in chunks
    buf = ''
    lines = []
    while True:
        # Grab a chunk of data
        data = fp.read(CHUNKSIZE)
        # Check for EOF
        if not data:
            break
        # Add to buffer and split into lines
        buf = buf + data
        if buf[0] == '\n':
            buf = buf[1:]
        if buf[-1] != '\n':
            i = buf.rfind('\n')
            if i == -1:
                continue
            else:
                lines = buf[:i].split('\n')
                buf = buf[i+1:]
        else:
            lines = buf[:-1].split('\n')
            buf = ''
        # Return the lines one at a time
        for line in lines:
            yield line

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
    return n//4

def fastq_subset(fastq_in,fastq_out,indices):
    """
    Output a subset of reads from a Fastq file

    The reads to output are specifed by a list
    of integer indices; only reads at those
    positions in the input file will be written
    to the output.
    """
    with open(fastq_out,'w') as fq_out:
        # Current index
        i = 0
        # Read count
        n = 0
        # Read contents
        rd = []
        # Iterate through the file
        for ii,line in enumerate(getlines(fastq_in),start=1):
            rd.append(line)
            if ii%4 == 0:
                # Got a complete read
                try:
                    # If read index matches the current index
                    # then output the read
                    if n == indices[i]:
                        fq_out.write("%s\n" % '\n'.join(rd))
                        i += 1
                    # Update for next read
                    n += 1
                    rd = []
                except IndexError:
                    # Subset complete
                    return
    # End of file: check nothing was left over
    if rd:
        raise Exception("Incomplete read at file end: %s"
                        % rd)

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

    print("Processing fastq pair:")
    print("\t%s" % args.fastq_r1)
    print("\t%s" % args.fastq_r2)

    nreads = count_reads(args.fastq_r1)
    print("Counted %d reads in %s" % (nreads,args.fastq_r1))

    if args.subset_size is not None:
        subset_size = float(args.subset_size)
        if subset_size < 1.0:
            subset_size = int(nreads*subset_size)
        else:
            subset_size = int(subset_size)
        print("Extracting subset of reads: %s" % subset_size)
        if args.seed is not None:
            print("Random number generator seed: %d" % args.seed)
            random.seed(args.seed)
        subset = sorted(random.sample(range(nreads),subset_size))
        fastq_subset(args.fastq_r1,"subset_r1.fq",subset)
        fastq_subset(args.fastq_r2,"subset_r2.fq",subset)
