#!/usr/bin/env python
#

import sys
import os
import subprocess
import tempfile
import optparse
import urllib2
import gzip

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
    description = args[1].strip()
    identifier = params['param_dict']['unique_id'].strip()
    # Where to put the output file
    # Nb we have to make this ourselves, it doesn't exist by default
    target_dir = params['output_data'][0]['extra_files_path']
    os.mkdir(target_dir)

    method = params['param_dict']['reference_source']['reference_source_selector']

    # Dictionary for returning to data manager
    data_manager_dict = {}
    data_manager_dict['data_tables'] = dict()

    # Download from URL
    if method == 'web':
        url = params['param_dict']['reference_source']['annotation_url']
        print "Downloading: %s" % url
        annotation_file_name = os.path.basename(url)
        annotation_file_path = os.path.join(target_dir,annotation_file_name)
        print "Annotation file name: %s" % annotation_file_name
        print "Annotation file path: %s" % annotation_file_path
        open(annotation_file_path,'wb').write(urllib2.urlopen(url).read())
        if annotation_file_name.endswith('.gz'):
            # Uncompress
            uncompressed_file = annotation_file_path[:-3]
            open(uncompressed_file,'wb').write(gzip.open(annotation_file_path,'rb').read())
            # Remove gzipped file
            os.remove(annotation_file_path)
            annotation_file_name = os.path.basename(uncompressed_file)
            annotation_file_path = uncompressed_file
        # Update the identifier and description
        if not identifier:
            identifier = "%s_ceas_web" % dbkey
        if not description:
            description = "%s (%s)" % (os.path.splitext(annotation_file_name)[0],dbkey)
        # Update the output dictionary
        data_manager_dict['data_tables']['ceas_annotations'] = {
            'value': identifier,
            'dbkey': dbkey,
            'name': description,
            'path': annotation_file_name,
        }
    elif method == 'server':
        # Pull in a file from the server
        filename = params['param_dict']['reference_source']['annotation_filename']
        create_symlink = params['param_dict']['reference_source']['create_symlink']
        print "Canonical gene list file name: %s" % filename
        print "Create symlink: %s" % create_symlink
        target_filename = os.path.join(target_dir,os.path.basename(filename))
        if create_symlink == 'copy_file':
            shutil.copyfile(filename,target_filename)
        else:
            os.symlink(filename,target_filename)
        # Update the identifier and description
        if not identifier:
            identifier = "%s_%s" % (dbkey,
                                    os.path.splitext(os.path.basename(filename))[0])
        if not description:
            description = "%s: %s" % (dbkey,
                                      os.path.splitext(os.path.basename(filename))[0])
        # Update the output dictionary
        data_manager_dict['data_tables']['ceas_annotations'] = {
            'value': identifier,
            'dbkey': dbkey,
            'name': description,
            'path': os.path.basename(filename),
        }
    elif method == 'from_wig':
        # Make a reference file from a wig file
        wig_file = params['param_dict']['reference_source']['wig_file']
        gene_annotation = params['param_dict']['reference_source']['gene_annotation']
        target_filename = os.path.join(target_dir,"%s_%s.%s" % (dbkey,
                                                                os.path.basename(wig_file),
                                                                gene_annotation))
        print "Wig file: %s" % wig_file
        print "Gene annotation: %s" % gene_annotation
        print "Output file: %s" % os.path.basename(target_filename)
        # Make a working directory
        working_dir = tempfile.mkdtemp()
        # Collect stderr in a file for reporting later
        stderr_filen = tempfile.NamedTemporaryFile().name
        # Build the command to run
        cmd = "build_genomeBG -d %s -g %s -w %s -o %s" % (dbkey,
                                                          gene_annotation,
                                                          wig_file,
                                                          target_filename)
        print "Running %s" %  cmd
        proc = subprocess.Popen(args=cmd,shell=True,cwd=working_dir,
                                stderr=open(stderr_filen,'wb'))
        proc.wait()
        # Copy stderr to stdout
        with open(stderr_filen,'r') as fp:
            sys.stdout.write(fp.read())
        # Update identifier and description
        if not identifier:
            identifier = "%s_%s_%s" % (dbkey,
                                       gene_annotation,
                                       os.path.basename(wig_file))
        if not description:
            description = "%s %s from %s" % (dbkey,
                                             gene_annotation,
                                             os.path.basename(wig_file))
        # Update the output dictionary
        data_manager_dict['data_tables']['ceas_annotations'] = {
            'value': identifier,
            'dbkey': dbkey,
            'name': description,
            'path': os.path.basename(target_filename),
        }
    else:
        raise NotImplementedError("Method '%s' not implemented" % method)

    #save info to json file
    open(jsonfile,'wb').write(to_json_string(data_manager_dict))

