convert_formats
===============

XML tool files and supporting scripts for converting formats:

 * bedgraph_to_wig: convert a BEDGraph file to fixedstep Wig format

bedgraph_to_wig
---------------

The `bedgraph_to_wig.pl` script was originally from Dave Tang:

 * <http://www.davetang.org/wiki/tiki-index.php?page=wig>

but has been modified by Peter Briggs to allow the `step` to be
specified at run time.

To add to Galaxy add the following to tool_conf.xml:

    <tool file="convert_formats/bedgraph_to_wig.xml" />

### bedgraph_to_wig: changes ###

0.0.1: Initial version

