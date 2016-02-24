data_manager_mothur_reference_data
==================================

Data manager to install reference data for Mothur toolsuite.

Specifically it can download data directly from the Mothur website, or
import files and directories on the server filesystem.

This tool needs a version of the mothur toolsuite that has been switched to
use data tables, and should be installed into a Galaxy instance from a
toolshed (you can use the `package_mothur_data_manager.sh` script to create
a .tgz file suitable for upload to a toolshed).

Note that Galaxy's support for data managers is generally still quite limited,
so it is possible that this tool may produce unexpected results. It also only
possible to add entries to the data tables i.e. edit or delete functionality
is not available via the tool.

Changes
-------

0.1.1: extended to allow import of multiple files from server
       filesystem in a single operation.

0.1.0: added function to import single file from server filesystem.

0.0.1: initial version with download from Mothur website option.