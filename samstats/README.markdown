SamStats
========

XML and wrapper script for the FLS SamStats utility. Assumes that the
SamStats.jar file is in .../galaxy-dist/tools-data/shared/jars (a
symbolic link is sufficient).

To add to Galaxy put this somewhere in tool_conf.xml:

    <tool file="fls_samstats/samstats.xml" />