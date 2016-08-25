qc_boxplotter
=============

XML and wrapper script for the FLS SOLiD QC boxplotter. Assumes that
`qc_boxplotter.sh` (the driver for the boxplotter) is on the Galaxy
user's path (currently it's in `genomics/NGS-general/`).

To add to Galaxy put this somewhere in tool_conf.xml:

    <tool file="fls_qc_boxplotter/qc_boxplotter.xml" />