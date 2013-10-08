galaxy-tools
============

FLS tools and tool-wrappers for Galaxy.

Tools wrapping 3rd-party software:

 * BLAT
 * CEAS
 * fastq_screen
 * pal_finder
 * SOLiD_preprocess_filter_v2.pl
 * trimmomatic
 * weeder
 * bedgraph_to_wig converter

Tools wrapping in-house scripts and programs:

 * motif_tools
 * qc_boxplotter
 * RnaChipIntegrator
 * SamStats

Tools are organised into subdirectories; to add these to your local
Galaxy:

1. Either:
   Copy the subdirectory into your .../galaxy-dist/tools/ directory
   or:
   Make a soft link in .../galaxy-dist/tools/ to the tool subdirectory
   
2. Add an entry for the tool in .../galaxy-dist/tool_conf.xml

You will also need to restart Galaxy for the changes to take effect.

Note:

 * The XML files also contain test for each tool, but the test data is not
   currently in this repository.

 * The tool ids of the FLS tools are weakly namespaced by an "fls_" prefix
   on the tool ids.
