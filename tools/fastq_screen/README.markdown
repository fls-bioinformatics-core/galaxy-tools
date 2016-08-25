fastq_screen
============
XML and wrapper script for fastq_screen program.

The tool assumes that the fastq_screen program is on the Galaxy user's path,
and that one or more fastq_screen `.conf` files have been configured
for the appropriate bowtie indexes and added to the `fastq_screen.loc` data
file.

`fastq_screen` can be obtained from [http://www.bioinformatics.bbsrc.ac.uk/projects/fastq_screen/]().

To add to Galaxy add the following to tool_conf.xml:

    <tool file="fastq_screen/fastq_screen.xml" />

You also need to make a copy of the `fastq_screen.loc` file (sample
version is provided here) which points to one or more fastq_screen `.conf`
files along with the type of data that the conf file can operate with (i.e.
`fastqsanger` for letterspace data, `fastqcssanger` for colorspace). The
user can choose which conf file to use at run time.

### Changes ###

0.1.3: remove --multilib option for compatibility with fastq_screen v0.3.1.

0.1.2: add support for fastq_screen's `--subset` option.

0.1.1: fix error in tool and script names in version 0.1.0.

0.1.0: allows both colorspace and letterspace conf files to be specified in
       the fastq_screen.loc file.
       Note that there is a change in loc file format from earlier versions.