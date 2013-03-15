solid_preprocess_filter
=======================

XML and wrapper script for the SOLiD_preprocess_filter_v2.pl script, which
performs quality filtering and optional truncation of reads in a SOLiD
csfasta/qual file pair.

The tool assumes that the `SOLiD_preprocess_filter_v2.pl` script is on the Galaxy
user's path.

`SOLiD_preprocess_filter_v2.pl` was developed by the HTS group at Rutgers
University but the download site appears to be no longer available.

To add to Galaxy add the following to tool_conf.xml:

    <tool file="solid_preprocess_filter/solid_preprocess_filter_wrapper.xml" />

### Changes ###

0.0.1: Initial version
