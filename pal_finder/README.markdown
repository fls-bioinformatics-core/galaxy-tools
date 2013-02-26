pal_finder
==========
XML and wrapper script for the pal_finder microsatellite and PCR primer design script.

The tool assumes that both the pal_finder script and the primer3_core programs are
available on the local system. The paths for each are currently hardwired into the
pal_finder_wrapper.sh script.

pal_finder can be obtained from [http://sourceforge.net/projects/palfinder/](). Primer3
version 2.0.0-alpha can be obtained from [http://primer3.sourceforge.net/releases.php]()
(note that it must be primer3 version 2).

To add to Galaxy add the following to tool_conf.xml:

    <tool file="pal_finder/pal_finder_wrapper.xml" />

### Changes ###

0.0.1: initial version