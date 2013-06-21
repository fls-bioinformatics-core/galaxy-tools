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

0.0.1: Initial version
