weeder2: motif discovery in sequences from coregulated genes of a single species
================================================================================

Galaxy tool for the Weeder2 motif discovery package:

- Zambelli, F., Pesole, G. and Pavesi, G. 2014. Using Weeder, Pscan, and PscanChIP
  for the Discovery of Enriched Transcription Factor Binding Site Motifs in
  Nucleotide Sequences. Current Protocols in Bioinformatics. 47:2.11:2.11.1–2.11.31.
  http://onlinelibrary.wiley.com/doi/10.1002/0471250953.bi0211s47/full

See http://159.149.160.51/modtools/

Automated installation
======================

Installation via the Galaxy Tool Shed will take of installing the tool wrapper and
the Weeder2 program and data, and setting the appropriate environment variables.

Manual Installation
===================

There are two files to install:

- ``weeder2_wrapper.xml`` (the Galaxy tool definition)
- ``weeder2_wrapper.sh`` (the shell script wrapper)

The suggested location is in a ``tools/weeder2/`` folder. You will then
need to modify the ``tools_conf.xml`` file to tell Galaxy to offer the tool
by adding the line:

    <tool file="weeder2/weeder2_wrapper.xml" />

You also need to make a copy of the ``weeder2.loc`` file (a sample version is
provided here) which lists the species for which frequency files are available.
This file should be placed in the ``tool-data`` directory of your Galaxy
installation.

Additionally you will need to install ``weeder2`` from:

- http://159.149.160.51/modtools/downloads/weeder2.html

The tool wrapper uses the following environment variables in order to find the
appropriate files:

- ``WEEDER_FREQFILES_DIR`` should point to the ``FreqFiles`` directory

Also the directory holding the Weeder2 executables should be on your ``PATH``.

Functional tests
================

If you want to run the functional tests, copy the sample test files under
sample test files under Galaxy's ``test-data/`` directory. Then:

    ./run_tests.sh -id weeder2

You will need to have set the environment variables above.

Reference Data
==============

Weeder2 requires reference data in the form of frequency files for each
species of interest. A set of reference files is provided as part of the
Weeder2 installation.

Additional frequency files can be generated for novel species using the
``w2frequency_maker`` utility available via:

- http://159.149.160.51/weederaddons/weeder2freq.html

This page also explains what input data should be used.

The location of the additional frequency files can then be specified by
adding them to the ``weeder2.loc`` file (see above).

History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
2.0.1      - Specify frequency files in ``weeder2.loc``.
2.0.0      - Initial version
========== ======================================================================


Developers
==========

This tool is developed on the following GitHub repository:
https://github.com/fls-bioinformatics-core/galaxy-tools/tree/master/weeder2

For making the "Galaxy Tool Shed" http://toolshed.g2.bx.psu.edu/ tarball I use
the ``package_weeder2.sh`` script.


Licence (MIT)
=============

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
