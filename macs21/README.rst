MACS21: Model-based Analysis of ChIP-Seq (MACS 2.1.0)
=====================================================

Galaxy tool wrapper for the MACS 2.1.0 ChIP-seq peak calling program. MACS has been
developed by Tao Lui
https://github.com/taoliu/MACS/

The reference for MACS is:

- Zhang Y, Liu T, Meyer CA, Eeckhoute J, Johnson DS, Bernstein BE, Nusbaum C, Myers
  RM, Brown M, Li W, Liu XS. Model-based analysis of ChIP-Seq (MACS). Genome Biol.
  2008;9(9):R137

Automated installation
======================

Installation via the Galaxy Tool Shed will take of installing the tool wrapper and
the MACS 2.1.0 program.

Manual Installation
===================

There are two files to install:

- ``macs21_wrapper.xml`` (the Galaxy tool definition)
- ``macs21_wrapper.py.sh`` (the Python script wrapper)

The suggested location is in a ``tools/macs21/`` folder. You will then
need to modify the ``tools_conf.xml`` file to tell Galaxy to offer the tool
by adding the line:

    <tool file="macs21/macs21_wrapper.xml" />

You will also need to install MACS 2.1.0:

- https://pypi.python.org/pypi/MACS2

and ensure that it's on your Galaxy user's ``PATH`` when running the tool.

If you want to run the functional tests, copy the sample test files under
sample test files under Galaxy's ``test-data/`` directory. Then:

    ./run_tests.sh -id macs2_wrapper

(However there are no tests defined at present.)

History
=======

This tool is based on the ``modencode-dcc`` MACS2 tool developed by Ziru Zhou
(ziruzhou@gmail.com), specifically the ``16:14f378e35191`` revision of the
tool at

- http://toolshed.g2.bx.psu.edu/view/modencode-dcc/macs2 

It has been substantially modified both to adapt it to MACS 2.1.0, and to
re-implement the internal workings of the tool to conform with current practices
in invoking commands from Galaxy.

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
2.1.0-2    - Add option to create bigWig file from bedGraphs; fix bug with -B
             option.
2.1.0-1    - Initial version
========== ======================================================================


Developers
==========

This tool is developed on the following GitHub repository:
https://github.com/fls-bioinformatics-core/galaxy-tools/tree/master/macs21

For making the "Galaxy Tool Shed" http://toolshed.g2.bx.psu.edu/ tarball I use
the ``package_macs21_wrapper.sh`` script.


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
