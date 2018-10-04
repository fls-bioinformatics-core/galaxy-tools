motif_tools
===========

Galaxy tools for various motif-finding utilities developed by Ian Donaldson.

There are five tools available:

 * **IUPAC scan and output each match** Returns all matches to a given IUPAC in
   GFF format

 * **IUPAC scan and output matches per seq** Counts the matches to a given IUPAC

 * **Count unique seq in GFF** Gives the non-redundant count of sequences

 * **TFBScluster two TFBS** Identifies clusters of two TFBS

 * **TFBScluster three TFBS** Identifies clusters of three TFBS

Automated installation
======================

Installation via the Galaxy Tool Shed will take of installing the tools
and the underlying dependencies.

Manual Installation
===================

To add these to Galaxy put the following lines in tool_conf.xml for each:
tool that you want::

    <tool file="motif_tools/Scan_IUPAC_output_each_match.xml" />
    <tool file="motif_tools/Scan_IUPAC_output_matches_per_seq.xml" />
    <tool file="motif_tools/CountUniqueIDs.xml" />
    <tool file="motif_tools/TFBScluster_candidates_2TFBS.xml" />
    <tool file="motif_tools/TFBScluster_candidates_3TFBS.xml" />

The tools also require Perl and ``Bioperl`` to be installed.

History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
- 1.0.2    Update bioperl dependency to 1.7.2
- 1.0.1    Updates to use conda dependency resolution and tidy up XML
- 1.0.0    Initial version
========== ======================================================================

Developers
==========

This tool is developed on the following GitHub repository:
https://github.com/fls-bioinformatics-core/galaxy-tools/tree/master/tools/macs21


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
