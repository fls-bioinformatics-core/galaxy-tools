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

Also the tool needs to know where to find the fasta files with the adapter sequences
used by the `ILLUMINACLIP` option, by updating the `trimmomatic_adapters.loc` file.
Note that the adapter sequences are supplied as part of the trimmomatic package.

To add to Galaxy add the following to tool_conf.xml:

    <tool file="trimmomatic/trimmomatic.xml" />

and copy `trimmomatic_adapters.loc.sample` to `trimmomatic_adapters.loc` in the
`tool-data` directory, and edit to point to the local copies of the adapter
sequences.

### Changes ###

0.0.4: Specify '-threads 6' in <command> section.

0.0.3: Added MINLEN, LEADING, TRAILING, CROP and HEADCROP options of trimmomatic.

0.0.2: Updated ILLUMINACLIP option to use standard adapter sequences (requires the
       trimmomatic_adapters.loc file; sample version is supplied) plus cosmetic
       updates to wording and help text for some options.

0.0.1: Initial version
