#!/usr/bin/env python
#

import sys
import os
import optparse
import shutil

from galaxy.util.json import from_json_string, to_json_string

# Download file from specified URL and put into local subdir

if __name__ == '__main__':
    #Parse Command Line
    parser = optparse.OptionParser()
    options,args = parser.parse_args()
    print "options: %s" % options
    print "args   : %s" % args
    if len(args) != 2:
        p.error("Need to supply JSON file name and description text")

    # Read the JSON supplied from the data manager tool
    # Results from this program will be returned via the
    # same file
    jsonfile = args[0]
    params = from_json_string(open(jsonfile).read() )
    print "%s" % params

    # Extract the data from the input JSON
    # See https://wiki.galaxyproject.org/Admin/Tools/DataManagers/HowTo/Define?highlight=%28\bAdmin%2FTools%2FDataManagers\b%29
    # for example of JSON
    #
    # We want the values set in the data manager XML
    dbkey = params['param_dict']['dbkey']
    description = params['param_dict']['description'].strip()
    # Where to put the output file
    # Nb we have to make this ourselves, it doesn't exist by default
    target_dir = params['output_data'][0]['extra_files_path']
    os.mkdir(target_dir)

    method = params['param_dict']['reference_source']['reference_source_selector']

    # Dictionary for returning to data manager
    data_manager_dict = {}

    if method == 'server':
        # Pull in a file from the server
        filename = params['param_dict']['reference_source']['gene_list_filename']
        create_symlink = params['param_dict']['reference_source']['create_symlink']
        print "Canonical gene list file name: %s" % filename
        print "Create symlink: %s" % create_symlink
        target_filename = os.path.join(target_dir,os.path.basename(filename))
        if create_symlink == 'copy_file':
            shutil.copyfile(filename,target_filename)
        else:
            os.symlink(filename,target_filename)
        # Check description
        if not description:
            description = "%s: %s" % (dbkey,
                                      os.path.splitext(os.path.basename(filename))[0])
        # Update the output dictionary
        data_manager_dict['data_tables'] = dict()
        data_manager_dict['data_tables']['rnachipintegrator_canonical_genes'] = {
            'dbkey': dbkey,
            'name': description,
            'value': os.path.basename(filename),
        }
    else:
        raise NotImplementedError("Method '%s' not implemented" % method)

    #save info to json file
    open(jsonfile,'wb').write(to_json_string(data_manager_dict))

