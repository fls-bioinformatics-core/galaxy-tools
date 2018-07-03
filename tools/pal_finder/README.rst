pal_finder: find microsatellite repeats and design PCR primers
==============================================================

Galaxy tool wrapper for the pal_finder microsatellite and PCR primer design script.

Automated installation
======================

Installation via the Galaxy Tool Shed will take of installing the tool wrapper and
the pal_finder and primer3_core programs (plus additional dependencies), and setting
the appropriate environment variables.

Manual Installation
===================

There are three files to install:

- ``pal_finder_wrapper.xml`` (the Galaxy tool definition)
- ``pal_finder_wrapper.sh`` (the shell script wrapper)
- ``pal_finder_filter_and_assembly.py`` (filtering utility)

The suggested location is in a ``tools/pal_finder_wrapper/`` folder. You will then
need to modify the ``tools_conf.xml`` file to tell Galaxy to offer the tool
by adding the line::

    <tool file="pal_finder/pal_finder_wrapper.xml" />

You will also need to install the pal_finder and primer3 packages:

- ``pal_finder`` can be obtained from http://sourceforge.net/projects/palfinder/
- ``Primer3`` version 2.0.0-alpha (see the pal_finder installation notes) can be
  obtained from http://primer3.sourceforge.net/releases.php

Additionally the filtering script needs ``BioPython`` and the ``PANDASeq`` program:

- ``BioPython`` can be obtained from https://pypi.python.org/packages/source/b/biopython/
- ``PANDASeq`` version 2.8.1 can be obtained from https://github.com/neufeld/pandaseq/

The tool wrapper must be able to locate the ``pal_finder_v0.02.04.pl`` script, the
example pal_finder ``config.txt`` and ``simple.ref`` data files, and the
``primer3_core`` program - the locations of these are taken from the following
enviroment variables which you will need to set manually:

- ``PALFINDER_SCRIPT_DIR``: location of the pal_finder Perl script (defaults to /usr/bin)
- ``PALFINDER_DATA_DIR``: location of the pal_finder data files (specifically config.txt
  and simple.ref; defaults to /usr/share/pal_finder_v0.02.04)
- ``PRIMER3_CORE_EXE``: name of the primer3_core program, which should include the
  full path if it's not on the Galaxy user's PATH (defaults to primer3_core)

If you want to run the functional tests, copy the sample test files under
sample test files under Galaxy's ``test-data/`` directory. Then::

    ./run_tests.sh -id microsat_pal_finder

You will need to have set the environment variables above.

History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------

0.02.04.8  - Update the FASTQ subsetting option to make it more efficient
0.02.04.7  - Trap for errors in ``pal_finder_v0.02.04.pl`` resulting in bad
             ranges being supplied to ``primer3_core`` for some reads via
             ``PRIMER_PRODUCT_RANGE_SIZE`` (and enable 'bad' reads to be output
	     to a dataset); add new option to use a random subset of reads for
	     microsatellite detection.
0.02.04.6  - Update to get dependencies using ``conda`` when installed from the
             toolshed (this removes the explicit dependency on Perl 5.16
             introduced in 0.02.04.2, as a result the outputs from the tool are
             now non-deterministic in some cases).
0.02.04.5  - Update to handle large output files which can sometimes be generated
             by the ``pal_finder_v0.02.04.pl`` or ``pal_filter.py`` scripts (logs
             of hundreds of Gb's have been observed in production): log files
             longer than 500 lines are now truncated to avoid downstream problems. 
0.02.04.4  - Update to the filter script (``pal_filter.py``) which removes some
             columns from the output assembly file.
0.02.04.3  - Update to the Illumina filtering script from Graeme Fox (including
             new option to run ``PANDASeq`` assembly/QC steps), and corresponding
	     update to the tool; add support for input FASTQs to be a dataset
	     collection pair.
0.02.04.2  - Fix bug that causes tool to fail when prefix includes spaces;
             add explicit dependency on Perl 5.16.3.
0.02.04.1  - Add option to run Graeme Fox's ``pal_finder_filter.pl`` script to
             filter and sort the pal_finder output (Illumina input data only).
             Update version number to reflect the pal_finder version.
0.0.6      - Allow input data to be either Illumina paired-end data in fastq
             format or single-end 454 data in fasta format.
0.0.5      - Allow custom mispriming library to be specified; added
             ``tool_dependencies.xml`` file to install pal_finder and primer3
             programs  and configure environment for Galaxy automatically.
0.0.4      - Added more custom options for primer3_core for selecting primers on
             size, GC and melting temperature criteria.
0.0.3      - Check that pal_finder script & config file, and primer3_core
             executable are all available; move PRIMER_MIN_TM parameter to new
             "custom" section for primer3 settings
0.0.2      - Updated pal_finder_wrapper.sh to allow locations of pal_finder Perl
             script, data files and primer_core3 program to be set via environment
             variables
0.0.1      - Initial version
========== ======================================================================


Developers
==========

This tool is developed on the following GitHub repository:
https://github.com/fls-bioinformatics-core/galaxy-tools/tree/master/pal_finder

For making the "Galaxy Tool Shed" http://toolshed.g2.bx.psu.edu/ tarball I use
the ``package_pal_finder.sh`` script.


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
