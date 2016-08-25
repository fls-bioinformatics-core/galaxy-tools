BLAT
====

XML tool file for the BLAT sequence alignment tool, which searches for sequences in
a reference database file.

The tool assumes that the `blat` program is on the Galaxy user's path.

`blat` is developed by Jim Kent (Kent, W.J. 2002. BLAT -- The BLAST-Like Alignment
Tool. Genome Research 4: 656-664). Information about obtaining BLAT can be found at
<http://genome.ucsc.edu/FAQ/FAQblat.html#blat3>.

To add to Galaxy add the following to tool_conf.xml:

    <tool file="blat/blat_wrapper.xml" />

### Changes ###

0.0.4: expose the options for pslReps via the tool interface, so the user can
       change minCover, minAli and nearTop values.

0.0.3: Added "pslReps" to titles of output data item if pslReps is run as part of
       the tool operation.

0.0.2: Add optional `pslReps` step after BLAT to get the best alignments plus a
       list of repeats.

0.0.1: Initial version
