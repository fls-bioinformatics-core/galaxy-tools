weeder
======

Utilities for running motif discovery using weeder.

weeder_wrapper
--------------

XML and wrapper script for weeder motif discovery package version 1.4.2.

The tool assumes that the weeder programs `weederlauncher.out`,
`weederTBFS.out` and `adviser.out` are on the Galaxy user's path.

`weeder` can be obtained from <http://159.149.160.51/modtools/downloads/weeder.html>.

The tool includes additional scripts:

 *  `ExtractWeederMatrices.pl`: extract the motif matrices from the weeder
    `.wee` file and puts them into separate files.

 *  `weeder2meme`: convert the motif matrices to MEME format (includes Perl
     modules under the `lib` directory).

`weeder2meme` also has its own dedicated Galaxy tool.

To add to Galaxy add the following to tool_conf.xml:

    <tool file="weeder/weeder_wrapper.xml" />

### Changes ###

0.1.0: add tool_dependencies.xml to install Weeder automatically;
       required modifications to script to link to executables and
       FreqFiles.

0.0.5: add option to convert

0.0.4: run ExtractWeederMatrices.pl to get matrices from .wee output;
       add weeder `A` option; comment out link to FreqFiles (doesn't
       seem to be required after all!)

0.0.3: fix needed to capture output from adviser (otherwise output is
       incomplete); make a link to the FreqFiles directory.

0.0.2: add full list of organisms and update output data items names
       and types (so they can be displayed within the browser)


weeder2meme_wrapper
-------------------

XML and wrapper script for weeder2meme program.

    <tool file="weeder/weeder2meme_wrapper.xml" />

### Changes ###

0.0.1: initial version
