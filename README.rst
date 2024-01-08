galaxy-tools
============

.. image:: https://github.com/fls-bioinformatics-core/galaxy-tools/actions/workflows/planemo-ci-tests.yml/badge.svg
   :target: https://github.com/fls-bioinformatics-core/galaxy-tools/actions/workflows/planemo-ci-tests.yml

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
 * weeder
 * `weeder2 <https://toolshed.g2.bx.psu.edu/view/pjbriggs/weeder2/>`_
 * bedgraph_to_wig converter

There are also tools wrapping in-house scripts and programs:

 * `motif_tools <https://toolshed.g2.bx.psu.edu/view/pjbriggs/motif_tools>`_
 * make_macs_xls
 * qc_boxplotter
 * `RnaChipIntegrator <https://toolshed.g2.bx.psu.edu/view/pjbriggs/rnachipintegrator>`_
 * SamStats

See the individual ``README`` files for information on how to install
into a local Galaxy; alternatively where indicated a subset of tools are
available from the main toolshed: https://toolshed.g2.bx.psu.edu/

conda-recipes
-------------

The ``conda-recipes`` subdirectory contains recipes for building
conda dependencies.

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

local_dependency_installers
---------------------------

The ``local_dependency_installers`` subdirectory contains shell
scripts with installer functions for many of the tool dependencies.

For example::

    local_dependency_installers/trimmomatic.sh

contains a function ``install_trimmomatic_0_36``, which will install
Trimmomatic v0.36 in a Galaxy-style directory structure (i.e.
``.../trimmomatic/0.36/`` which includes an ``env.sh`` which can be
sourced to make the installed dependency available.

These functions are used primarily for setting up the test environments
for the Planemo tests, but could be recycled e.g. for local tool
installations into Galaxy using an appropriately configured
``galaxy_packages`` dependency resolver (see e.g.
https://docs.galaxyproject.org/en/master/admin/dependency_resolvers.html#)

Use e.g. ``grep ^function local_dependency_installers/*.sh`` to list
the available installer functions.
