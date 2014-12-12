RnaChipIntegrator
=================

XML files and wrapper script for the FLS RnaChipIntegrator program (see
http://fls-bioinformatics-core.github.com/RnaChipIntegrator/). Assumes
that `RnaChipIntegrator.py` is installed on the Galaxy user's path.

There are two tools available that are built around RnaChipIntegrator:

 1. General RnaChipIntegrator tool that allows any peaks to be analysed
    against any gene list
 2. A "cannonical gene" variant which allows ChIP peaks to be analysed
    against a list of cannonical genes for different genomes

To add these to Galaxy put the following lines in tool_conf.xml for each:
tool that you want:

    <tool file="rnachipintegrator/rnachipintegrator_wrapper.xml" />
    <tool file="rnachipintegrator/rnachipintegrator_canonical_genes.xml" />

In addition for the histone modification and cannonical gene variants, it's
necessary to set up .loc files.

 * **Cannonical genes**: its necessary to manually acquire cannonical gene
   list files from UCSC; then make a copy of the
   `rnachipintegrator_canonical_genes.loc.sample` file and add references
   to the genes there.

In either case the final .loc files need to be put into the `tool-data`
directory of the Galaxy installation.

### Note on Excel output files and Galaxy ###

RnaChipIntegrator produces an Excel spreadsheet as one of its outputs,
however Galaxy is not currently set up by default to handle these.

To enable Excel output file handling in Galaxy, edit the `datatypes_conf.xml`
file and add:

   <datatype extension="xls" type="galaxy.datatypes.data:Data" mimetype="application/vnd.ms-excel" />

(you'll also need to remove the existing datatype with extension "xls".)

Restarting Galaxy should mean that the browser correctly handles Excel
outputs from RnaChipIntegrator.
