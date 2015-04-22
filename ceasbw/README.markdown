CEAS
====

XML and wrapper script for the CEAS package, which can be used to annotate intervals
and scores with genome features.

This tool uses the Cistrome version of the package, which provides two versions of
the `ceas` program: in addition to the `ceas` program (the same as that available
from the main CEAS website), it also includes the `ceasBW` program (which can handle
bigwig input).

The tool assumes that the `ceas` and `ceasBW` programs are on the Galaxy user's
path.

The official CEAS website is at:

<http://liulab.dfci.harvard.edu/CEAS/index.html>

The Cistrome version can be found via

<https://bitbucket.org/cistrome/cistrome-applications-harvard/overview>

To add to Galaxy add the following to tool_conf.xml:

    <tool file="ceas/ceasbw_wrapper.xml" />

You also need to make a copy of the `ceas.loc` file (sample version is provided
here) which points to the available GDB files for different genomes. The GDB files
are essentially SQLite database files containing the RefSeq genes for the genome
in question.

A limited number of GDB files are available for download from the CEAS website; to
make new ones, see the section "Build a sqlite3 file with a gene annotation table
and genome background annotation for CEAS" in the CEAS manual:

<http://liulab.dfci.harvard.edu/CEAS/usermanual.html>

The `ceas.loc` file should be placed in the `tool-data` directory of your Galaxy
installation.

### Changes ###

1.0.2-0: first version based on our original `ceas` tool.
