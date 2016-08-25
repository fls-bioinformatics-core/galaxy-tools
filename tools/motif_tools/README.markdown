motif_tools
===========

XML files and Perl scripts for various motif-finding utilities.

There are five tools available:

 * **IUPAC scan and output each match** Returns all matches to a given IUPAC in
   GFF format

 * **IUPAC scan and output matches per seq** Counts the matches to a given IUPAC

 * **Count unique seq in GFF** Gives the non-redundant count of sequences

 * **TFBScluster two TFBS** Identifies clusters of two TFBS

 * **TFBScluster three TFBS** Identifies clusters of three TFBS

To add these to Galaxy put the following lines in tool_conf.xml for each:
tool that you want:

    <tool file="motif_tools/Scan_IUPAC_output_each_match.xml" />
    <tool file="motif_tools/Scan_IUPAC_output_matches_per_seq.xml" />
    <tool file="motif_tools/CountUniqueIDs.xml" />
    <tool file="motif_tools/TFBScluster_candidates_2TFBS.xml" />
    <tool file="motif_tools/TFBScluster_candidates_3TFBS.xml" />
