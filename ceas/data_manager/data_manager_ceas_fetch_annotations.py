#!/usr/bin/env python
#

import sys
import os
import optparse
import urllib2
import gzip

from galaxy.util.json import from_json_string, to_json_string

# Download file from specified URL and put into local subdir

if __name__ == '__main__':
    #Parse Command Line
    parser = optparse.OptionParser()
    parser.add_option('--download',dest='url',action='store',
                      type="string",default=None,help='URL to download')
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
    description = params['param_dict']['description']
    # Where to put the output file
    # Nb we have to make this ourselves, it doesn't exist by default
    target_dir = params['output_data'][0]['extra_files_path']
    os.mkdir(target_dir)

    # Dictionary for returning to data manager
    data_manager_dict = {}

    # Download from URL
    if options.url is not None:
        print "Downloading: %s" % options.url
        annotation_file_name = os.path.basename(options.url)
        annotation_file_path = os.path.join(target_dir,annotation_file_name)
        print "Annotation file name: %s" % annotation_file_name
        print "Annotation file path: %s" % annotation_file_path
        open(annotation_file_path,'wb').write(urllib2.urlopen(options.url).read())
        if annotation_file_name.endswith('.gz'):
            # Uncompress
            uncompressed_file = annotation_file_path[:-3]
            open(uncompressed_file,'wb').write(gzip.open(annotation_file_path,'rb').read())
            # Remove gzipped file
            os.remove(annotation_file_path)
            annotation_file_name = os.path.basename(uncompressed_file)
            annotation_file_path = uncompressed_file
        # Update the output dictionary
        data_manager_dict['data_tables'] = dict()
        data_manager_dict['data_tables']['ceas_annotations'] = {
            'dbkey': dbkey,
            'name': description,
            'value': annotation_file_name,
        }
    else:
        raise NotImplementedError("Non-download options not implemented")

    #save info to json file
    open(jsonfile,'wb').write(to_json_string(data_manager_dict))
        
        
        
        
        
        
    
