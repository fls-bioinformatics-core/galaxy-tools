make_macs_xls
=============

XML file defining a tool to run the `make_macs2_xls.py` program for the
UoM Bioinformatics Core Facility `genomics` repository.

Assumes that `make_macs2_xls.py` is installed on the Galaxy user's path,
that the `.../genomics/share` directory is in the `PYTHONPATH`, and that
the `xlwt`, `xlrd` and `xlutils` Python packages have also been installed
and are available to the Galaxy user.

To enable this tool add an entry to the appropriate tools conf file e.g.:

    <tool file="make_macs_xls/make_macs_xls.xml" />

### Note on Excel output files and Galaxy ###

RnaChipIntegrator produces an Excel spreadsheet as one of its outputs,
however Galaxy is not currently set up by default to handle these.

To enable Excel output file handling in Galaxy, edit the `datatypes_conf.xml`
file and add:

    <datatype extension="xls" type="galaxy.datatypes.data:Data" mimetype="application/vnd.ms-excel" />

(you'll also need to remove the existing datatype with extension "xls".)

Restarting Galaxy should mean that the browser correctly handles Excel
outputs.
