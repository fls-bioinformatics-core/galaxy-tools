RnaChipIntegrator: integrated analysis of gene expression and ChIP data
=======================================================================

Galaxy tool wrappers for running the RnaChipIntegrator program
(http://fls-bioinformatics-core.github.com/RnaChipIntegrator/) for integrated
analyses of gene expression and ChIP data.

There are two tools available that are built around RnaChipIntegrator:

- General RnaChipIntegrator tool that allows any peaks to be analysed against
  any gene list
- A "cannonical gene" variant which allows ChIP peaks to be analysed against a
  list of cannonical genes for different genomes

Automated installation
======================

Installation via the Galaxy Tool Shed will take of installing the tool wrapper
and the RnaChipIntegrator programs, installing the .loc files, and setting the
appropriate environment variables.

Manual Installation
===================

There are three files to install:

- ``rnachipintegrator_wrapper.xml`` (the Galaxy tool definition for general usage)
- ``rnachipintegrator_canonical_genes.xml`` (tool definition for the "canonical
  gene" variant)
- ``rnachipintegrator_wrapper.sh`` (the shell script wrapper)

The suggested location is in a ``tools/rnachipintegrator/`` folder. You will then
need to modify the ``tools_conf.xml`` file to tell Galaxy to offer the tool
by adding the lines:

    <tool file="rnachipintegrator/rnachipintegrator_wrapper.xml" />
    <tool file="rnachipintegrator/rnachipintegrator_canonical_genes.xml" />

You will also need to install the RnaChipIntegrator program:

- http://fls-bioinformatics-core.github.com/RnaChipIntegrator/

In addition for the cannonical gene and histone modification variants, it's
necessary to copy the .loc.sample files to .loc Galaxy's ``tool-data`` folder:

- **Cannonical genes**: its necessary to manually acquire cannonical gene
  list files from UCSC and then add appropriate references in the
  ``rnachipintegrator_canonical_genes.loc`` file.

If you want to run the functional tests, copy the sample test files under
``test-data`` to Galaxy's ``test-data/`` directory. Then:

    ./run_tests.sh -id fls_rnachipintegrator_wrapper


How to get canonical gene data
==============================

Getting canonical gene info from UCSC is covered in the screencast at
http://blog.openhelix.eu/?p=6097

In summary:

- **UCSC genome browser:** if multiple versions of each gene are visible (e.g.
  if you view 'human Feb 2009 GRCh37/hg19' positions chr17:41,100,000-41,300,000)
  then:

  - Scroll down to the Gene & Gene Prediction section
  - Click on the UCSC genes link
  - Uncheck the tickbox next to splice variants and resubmit to view without
    duplicates.

- **UCSC table browser:** to obtain the canonical set of genes from the table
  browser:

  - Select knownCanonical from the table menu
  - Select selected fields from primary & related tables from the output format menu
  - Click on Get output
  - Select the fields of interest (e.g. 'chrom', 'chromStart', 'chromEnd' from the
    'knownCanonical' table plus 'geneSymbol' from the kgXref table.)
  - Click on Get output to get the data for download

(Hint: to also get strand direction information i.e. +/-, also allow selection
from the refGene table, and select the strand field.)


History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
1.0.3.1    - Fetch dependencies from conda if not otherwise satisfied
1.0.3.0    - Update to ``RnaChipIntegrator`` version 1.0.3
1.0.2.0    - Update to ``RnaChipIntegrator`` version 1.0.2 (fixes bug with
             zero or blank cutoff)
1.0.0.0    - Update to use latest ``RnaChipIntegrator`` version 1.0.0.
0.5.0-0    - Significant update to bring tools in line with
             ``RnaChipIntegrator`` version 0.5.0, including removing the
             distinction between 'regions' and 'summits' for input peaks,
             and otherwise attempting to simplify the tools for users.
0.4.4-0    - Initial version pushed to toolshed
========== ======================================================================


Developers
==========

This tool is developed on the following GitHub repository:
https://github.com/fls-bioinformatics-core/galaxy-tools/tree/master/rnachipintegrator

For making the "Galaxy Tool Shed" http://toolshed.g2.bx.psu.edu/ tarball I use
the ``package_rnachipintegrator_wrapper.sh`` script.


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
