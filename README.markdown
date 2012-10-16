galaxy-tools
============

FLS tools and tool-wrappers for Galaxy.

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

fastq_screen
------------
XML and wrapper script for fastq_screen program.

The tool assumes that the fastq_screen program is on the Galaxy user's path,
and that one or more fastq_screen `.conf` files have been configured
for the appropriate bowtie indexes and added to the `fastq_screen.loc` data
file.

`fastq_screen` can be obtained from [http://www.bioinformatics.bbsrc.ac.uk/projects/fastq_screen/]().

To add to Galaxy add the following to tool_conf.xml:

    <tool file="fastq_screen/fastq_screen.xml" />

You also need to make a copy of the `fastq_screen.loc` file (sample
version is provided here) which points to one or more fastq_screen `.conf`
files along with the type of data that the conf file can operate with (i.e.
`fastqsanger` for letterspace data, `fastqcssanger` for colorspace). The
user can choose which conf file to use at run time.

### Changes ###

0.1.2: add support for fastq_screen's `--subset` option.

0.1.1: fix error in tool and script names in version 0.1.0.

0.1.0: allows both colorspace and letterspace conf files to be specified in
       the fastq_screen.loc file.
       Note that there is a change in loc file format from earlier versions.

qc_boxplotter
-------------
XML and wrapper script for the FLS SOLiD QC boxplotter. Assumes that
`qc_boxplotter.sh` (the driver for the boxplotter) is on the Galaxy
user's path (currently it's in `genomics/NGS-general/`).

To add to Galaxy put this somewhere in tool_conf.xml:

    <tool file="fls_qc_boxplotter/qc_boxplotter.xml" />


RnaChipIntegrator
-----------------
XML files and wrapper script for the FLS RnaChipIntegrator program (see
http://fls-bioinformatics-core.github.com/RnaChipIntegrator/). Assumes
that `RnaChipIntegrator.py` is installed on the Galaxy user's path.

There are three tools available that are built around RnaChipIntegrator:

 1. General RnaChipIntegrator tool that allows any peaks to be analysed
    against any gene list
 2. A "histone modification" variant which allows a gene list to be
    analysed against a selected histone modification cell line/antibody
 3. A "cannonical gene" variant which allows ChIP peaks to be analysed
    against a list of cannonical genes for different genomes

To add these to Galaxy put the following lines in tool_conf.xml for each:
tool that you want:

   <tool file="rnachipintegrator/rnachipintegrator_wrapper.xml" />
   <tool file="rnachipintegrator/rnachipintegrator_histone_mod.xml" />
   <tool file="rnachipintegrator/rnachipintegrator_canonical_genes.xml" />

In addition for the histone modification and cannonical gene variants, it's
necessary to set up .loc files.

 * ''Histone modification data'': use the `get_histone_data_hg18.sh` script
   to download the hg18 data and construct a .loc file automatically. The
   .loc file should then be renamed to `rnachipintegrator_histone_mod.loc`.

 * ''Cannonical genes'': its necessary to manually acquire cannonical gene
   list files from UCSC; then make a copy of the
   `rnachipintegrator_canonical_genes.loc.sample` file and add references
   to the genes there.

In either case the final .loc files need to be put into the `tool-data`
directory of the Galaxy installation.

### Note on Excel output files and Galaxy ###

RnaChipIntegrator produces an Excel spreadsheet as one of its outputs,
however Galaxy is not currently set up by default to handle these.

To enable Excel output file handling in Galaxy, edit the `datatypes_conf.xml`
file and add:

   <datatype extension="xls" type="galaxy.datatypes.data:Data" mimetype="application/vnd.ms-excel" />

(you'll also need to remove the existing datatype with extension "xls".)

Restarting Galaxy should mean that the browser correctly handles Excel
outputs from RnaChipIntegrator.


SamStats
--------
XML and wrapper script for the FLS SamStats utility. Assumes that the
SamStats.jar file is in .../galaxy-dist/tools-data/shared/jars (a
symbolic link is sufficient).

To add to Galaxy put this somewhere in tool_conf.xml:

    <tool file="fls_samstats/samstats.xml" />
