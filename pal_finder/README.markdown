pal_finder
==========
XML and wrapper script for the pal_finder microsatellite and PCR primer design script.

pal_finder can be obtained from [http://sourceforge.net/projects/palfinder/](). It also
requires Primer3 version 2 (see the pal_finder installation notes) - version 2.0.0-alpha
can be obtained from [http://primer3.sourceforge.net/releases.php]().

The tool wrapper must be able to locate the pal_finder Perl script, the example
pal_finder config.txt and simple.ref data files, and the primer3_core program - the
locations of these are taken from the following enviroment variables:

 * PALFINDER_SCRIPT_DIR: location of the pal_finder Perl script (defaults to /usr/bin)
 * PALFINDER_DATA_DIR: location of the pal_finder data files (specifically config.txt
   and simple.ref; defaults to /usr/share/pal_finder_v0.02.04)
 * PRIMER3_CORE_EXE: name of the primer3_core program, which should include the
   full path if it's not on the Galaxy user's PATH (defaults to primer3_core)

The defaults can be over-ridden by setting these variables explicitly in the Galaxy
user's environment.

To add to Galaxy add the following to tool_conf.xml:

    <tool file="pal_finder/pal_finder_wrapper.xml" />

### Changes ###

0.0.5: allow custom mispriming library to be specified; added tool_dependencies.xml file
       to install pal_finder and primer3 programs  and configure environment for Galaxy
       automatically.

0.0.4: added more custom options for primer3_core for selecting primers on size, GC and
       melting temperature criteria.

0.0.3: check that pal_finder script & config file, and primer3_core executable are all
       available; move PRIMER_MIN_TM parameter to new "custom" section for primer3
       settings

0.0.2: updated pal_finder_wrapper.sh to allow locations of pal_finder Perl script, data
       files and primer_core3 program to be set via environment variables

0.0.1: initial version