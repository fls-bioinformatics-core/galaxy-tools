CEAS
====

XML and wrapper script for CEAS, to annotate intervals and scores with genome
features.

The tool assumes that the `ceas` program is on the Galaxy user's path. CEAS can be
obtained from [http://liulab.dfci.harvard.edu/CEAS/index.html]().

To add to Galaxy add the following to tool_conf.xml:

    <tool file="ceas/ceas_wrapper.xml" />

You also need to make a copy of the `ceas.loc` file (sample version is provided
here) which points to the available GDB files for different genomes. The GDB files
are essentially SQLite database files containing the RefSeq genes for the genome
in question.

A limited number of GDB files are available for download from the CEAS website; to
make new ones, see the section "Build a sqlite3 file with a gene annotation table
and genome background annotation for CEAS" in the CEAS manual
[http://liulab.dfci.harvard.edu/CEAS/usermanual.html]().

The `ceas.loc` file should be placed in the `tool-data` directory of your Galaxy
installation.

### Changes ###

1.0.2.0: first version with basic data manager for annotation files.
