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

Trimmomatic 0.32 can be obtained from:

 * <http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.32.zip>

The tool assumes that two environment variables have been set, in order to find the
appropriate files:

 * `TRIMMOMATIC_DIR` should point to the directory holding the
   `trimmomatic-0.32.jar` file, and

 * `TRIMMOMATIC_ADAPTERS_DIR` should point to the directory holding the adapter
    sequence files (used by the `ILLUMINACLIP` option).

Both variables will be set automatically if installing the tool dependencies e.g. via
a toolshed; otherwise they will need to be set manually in the Galaxy environment.

To add to Galaxy add the following to tool_conf.xml:

    <tool file="trimmomatic/trimmomatic.xml" />

(The tool no longer uses a `.loc` file to point to the location of the adapter
sequence files)

### Changes ###

0.32.1: Remove `trimmomatic_adapters.loc.sample` and hard-code adapter files into
        the XML wrapper.

0.32.0: Add tool_dependencies.xml to install Trimmomatic 0.32 automatically and
        (set the environment). Update tool versioning to use Trimmomatic version
	number (i.e. `0.32`) with tool iteration appended (i.e. `.1`).

0.0.4: Specify '-threads 6' in <command> section.

0.0.3 : Added MINLEN, LEADING, TRAILING, CROP and HEADCROP options of trimmomatic.

0.0.2: Updated ILLUMINACLIP option to use standard adapter sequences (requires the
       trimmomatic_adapters.loc file; sample version is supplied) plus cosmetic
       updates to wording and help text for some options.

0.0.1: Initial version
