CEAS: Cis-regulatory Element Annotation System
==============================================

Galaxy tool wrapper for the CEAS (Cis-regulatory Element Annotation System), which
can be used to annotate intervals and scores with genome features.

This tool uses the Cistrome version of the package, which provides two versions of
the core program: in addition to the ``ceas`` program (the same as that available
from the main CEAS website), it also includes the ``ceasBW`` program (which can handle
bigwig input).

The tool assumes that the ``ceas`` and ``ceasBW`` programs are on the Galaxy user's
path.

The official CEAS website is at:

- http://liulab.dfci.harvard.edu/CEAS/index.html

The Cistrome version can be found via

- https://bitbucket.org/cistrome/cistrome-applications-harvard/overview

Automated installation
======================

Installation via the Galaxy Tool Shed will take care of installing the tool wrapper
and the CEAS programs, and setting the appropriate environment variables.

In addition this will also install a data manager which can be used to install
reference GDB data files necessary for the tool.

Manual Installation
===================

There are two files to install:

- ``ceas_wrapper.xml`` (the Galaxy tool definition)
- ``ceas_wrapper.sh`` (the shell script wrapper)

The suggested location is in a ``tools/ceas/`` folder. You will then
need to modify the ``tools_conf.xml`` file to tell Galaxy to offer the tool
by adding the line:

    <tool file="ceas/ceasbw_wrapper.xml" />

You also need to make a copy of the ``ceas.loc`` file (a sample version is
provided here) which points to the available GDB files for different genomes.

This file should be placed in the ``tool-data`` directory of your Galaxy
installation.

Reference Data
==============

CEAS requires reference data in the form of GDB files (essentially, SQLite database
files) containing the RefSeq genes for the genome in question.

A limited number of GDB files are available for download from the CEAS website; to
make new ones, see the section "Build a sqlite3 file with a gene annotation table
and genome background annotation for CEAS" in the CEAS manual:

- http://liulab.dfci.harvard.edu/CEAS/usermanual.html

History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
1.0.2-3    - Updated to fetch all dependencies from conda
1.0.2-2    - Major updates to fix various bugs, add tests and enable ceasBW to
             be used without an existing chromosome sizes file.
1.0.2-1    - Modified to work with Cistrome-version of CEAS (includes additional
             'ceasBW' program which can take bigWig input)
1.0.2-0    - Initial version.
========== ======================================================================

Developers
==========

This tool is developed on the following GitHub repository:
https://github.com/fls-bioinformatics-core/galaxy-tools/tree/master/ceas

For making the "Galaxy Tool Shed" http://toolshed.g2.bx.psu.edu/ tarball I use
the ``package_ceas.sh`` script.
