Trimmomatic
===========

XML tool file and shell script wrapper for the Trimmomatic program, which provides
various functions for manipluating Illumina FASTQ files.

Trimmomatic has been developed within Bjorn Usadel's group at RWTH Aachen university:

 * <http://www.usadellab.org/cms/index.php?page=trimmomatic>

The reference for Trimmomatic is:

 * Lohse M, Bolger AM, Nagel A, Fernie AR, Lunn JE, Stitt M, Usadel B. RobiNA: a
   user-friendly, integrated software solution for RNA-Seq-based transcriptomics.
   Nucleic Acids Res. 2012 Jul;40(Web Server issue):W622-7)

The tool assumes that the `trimmomatic` jar file has been placed in the
`tool-data/shared/jars/` directory and that it is called `trimmomatic.jar` (this
can be a link to the actual jar file e.g. `trimmomatic-0.30.jar`).

To add to Galaxy add the following to tool_conf.xml:

    <tool file="trimmomatic/trimmomatic.xml" />

### Changes ###

0.0.1: Initial version
