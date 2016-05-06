galaxy-tools
============

.. image:: https://travis-ci.org/fls-bioinformatics-core/galaxy-tools.png?branch=master
   :target: https://travis-ci.org/fls-bioinformatics-core/galaxy-tools

Tools, tool-wrappers and tool dependency packages for Galaxy developed
within the Bioinformatics Core Facility at the University of Manchester.

tools
-----

The ``tools`` subdirectory contains the following tools which wrap
3rd-party software:

 * BLAT
 * `CEAS <https://toolshed.g2.bx.psu.edu/view/pjbriggs/ceas/>`_
 * fastq_screen
 * `MACS2 <https://toolshed.g2.bx.psu.edu/view/pjbriggs/macs21/>`_
 * `pal_finder <https://toolshed.g2.bx.psu.edu/view/pjbriggs/pal_finder/>`_
 * SOLiD_preprocess_filter_v2.pl
 * `trimmomatic <https://toolshed.g2.bx.psu.edu/view/pjbriggs/trimmomatic/>`_
 * weeder
 * `weeder2 <https://toolshed.g2.bx.psu.edu/view/pjbriggs/weeder2/>`_
 * bedgraph_to_wig converter

There are also tools wrapping in-house scripts and programs:

 * motif_tools
 * make_macs_xls
 * qc_boxplotter
 * `RnaChipIntegrator <https://toolshed.g2.bx.psu.edu/view/pjbriggs/rnachipintegrator>`_
 * SamStats

See the individual ``README`` files for information on how to install
into a local Galaxy; alternatively where indicated a subset of tools are
available from the main toolshed: https://toolshed.g2.bx.psu.edu/

packages
--------

The ``packages`` subdirectory contains tool dependency packages:

 * package_numpy_1_8
 * package_pandaseq_2_8_1
 * package_python2_7

legacy
------

The ``legacy`` subdirectory contains tools and packages which are
no longer supported, or which are backwardly-incompatible, or where
development is now happening elsewhere.
