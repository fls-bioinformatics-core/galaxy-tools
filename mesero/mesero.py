#!/bin/env python
#
#    mesero: helper module for Galaxy data managers
#    Copyright (C) University of Manchester 2015 Peter Briggs
#
"""
Introduction
************

'mesero' is a helper module for implementing Galaxy Data
Managers:

https://wiki.galaxyproject.org/Admin/Tools/DataManagers

In particular it provides classes for handling the JSON
dictionaries that are passed to and from the Galaxy and the
Data Manager Tool:

https://wiki.galaxyproject.org/Admin/Tools/DataManagers/DataManagerJSONSyntax?highlight=%28\bAdmin%2FTools%2FDataManagers\b%29

Specifically:

 * ``InputParams`` provides access to the values in the input
   JSON via a collection of dictionaries;
 * ``DataTableSet`` and ``DataTable`` wrap the population
   of data tables within a Data Manager Tool, and the generation
   of JSON dictionaries to be returned to Galaxy.

It also provides helper functions for common tasks such as
downloading files and unpacking ZIP and TAR archives.

Usage Examples
**************

"""

__version__='0.0.1'

# Convenience functions mapping to JSON conversion
# (this idiom borrowed from lib/galaxy/utils/json.py)
import json
to_json_string = json.dumps
from_json_string = json.loads

# Utility class for reading input JSON dictionary passed
# from Galaxy to the Data Manager Tool
#
# Example usage:
# >>> p = InputParams(jsonfile)
# >>> dbkey = p.param_dict['dbkey']
# >>> description = p.param_dict['description']
# >>> extra_files_path = p.extra_files_path

import os
class InputParams:
    """
    Class for handling input parameters to data manager tool

    When instantiated the object provides the following
    attributes which are dictionaries containing the
    data from the JSON file:

    * param_dict (an arbitrary dictionary of parameters
      input into the tool)
    * output_data (information about where the output from
      the data should go
    * 

    Additionally the 'extra_files_path' attribute is the path
    to a directory where output files must be put for the
    Galaxy to pick them up from.

    (NB the directory pointed to by 'extra_files_path'
    doesn't exist initially, it is the job of the script
    to create it if necessary.)

    """
    def __init__(self,jsonfile):
        """
        Instantiate new InputParams object

        """
        d = from_json_string(open(jsonfile).read())
        self.param_dict = d['param_dict']
        self.output_data = d['output_data'][0]
        self.job_config = d['job_config']
        self.extra_files_path = d['output_data'][0]['extra_files_path']

    def make_extra_files_path(self):
        """
        """
        os.mkdir(self.extra_files_path)

# Utility classes for managing data table contents and
# writing JSON dictionary passed from the Data Manager
# Tool to Galaxy
#
# Example usage:
# >>> d = DataTableSet()
# >>> d.add_table('my_data')
# >>> d.table('my_data').add_entry(dbkey='hg19',value='human')
# >>> d.table('my_data').add_entry(dbkey='mm9',value='mouse')
# >>> print d.json

class DataTableSet:
    def __init__(self):
        """
        Class for handling a set of data tables

        """
        self._tables = {}
    def add_table(self,name):
        """
        Add a new table to the set

        """
        if name in self._tables:
            raise KeyError("Table '%s' already exists" % name)
        self._tables[name] = DataTable(name)
    def table(self,name):
        """
        Return a data table from the set

        """
        return self._tables[name]
    def dict(self):
        """
        Return a dictionary representation

        """
        d = dict()
        d['data_tables'] = {}
        for name in self._tables:
            d['data_tables'][name] = self._tables[name].entries
        return d
    def json(self):
        """
        Return a JSON string representation

        """
        return str(to_json_string(self.dict()))

class DataTable:
    """
    Class for handling a single data table

    """
    def __init__(self,name):
        """
        Create data table instance

        """
        self._name = name
        self._entries = []
    def add_entry(self,**args):
        """
        Add an entry to the data table

        """
        self._entries.append(args)
    @property
    def name(self):
        """
        Return the name of the data table

        """
        return self._name
    @property
    def entries(self):
        """
        Return list of entries

        """
        return self._entries

# Utility functions for downloading and unpacking archive files

def fetch_files(urls,wd=None,files=None):
    """
    Download and unpack files from a list of URLs

    Given a list of URLs, download and unpack each
    one, and return a list of the extracted files.

    'wd' specifies the working directory to extract
    the files to, otherwise they are extracted to the
    current working directory.

    If 'files' is given then the list of extracted
    files will be appended to this list before being
    returned.

    """
    if files is None:
        files = []
    for url in urls:
        filen = download_file(url,wd=wd)
        files.extend(unpack_archive(filen,wd=wd))
    return files

def download_file(url,target=None,wd=None,uncompress=False):
    """
    Download a file from a URL

    Fetches a file from the specified URL.

    If 'target' is specified then the file is saved to this
    name; otherwise it's saved as the basename of the URL.

    If 'wd' is specified then it is used as the 'working
    directory' where the file will be save on the local
    system.

    If 'uncompress' is True then after download the file
    will be uncompressed (if it has an appropriate file
    extension). This option has no effect if the file is not
    compressed.

    Returns the name that the file is saved with.

    """
    print "Downloading %s" % url
    if not target:
        target = os.path.basename(url)
    if wd:
        target = os.path.join(wd,target)
    print "Saving to %s" % target
    open(target,'wb').write(urllib2.urlopen(url).read())
    if uncompress:
        print "Attempting to uncompress"
        target = uncompress_file(target)
    return target

def unpack_zip_archive(filen,wd=None):
    """
    Extract files from a ZIP archive

    Given a ZIP archive, extract the files it contains
    and return a list of the resulting file names and 
    paths.

    'wd' specifies the working directory to extract
    the files to, otherwise they are extracted to the
    current working directory.

    Once all the files are extracted the ZIP archive
    file is deleted from the file system.

    """
    if not zipfile.is_zipfile(filen):
        print "%s: not ZIP formatted file"
        return [filen]
    file_list = []
    z = zipfile.ZipFile(filen)
    for name in z.namelist():
        if reduce(lambda x,y: x or name.startswith(y),IGNORE_PATHS,False):
            print "Ignoring %s" % name
            continue
        if wd:
            target = os.path.join(wd,name)
        else:
            target = name
        if name.endswith('/'):
            # Make directory
            print "Creating dir %s" % target
            try:
                os.makedirs(target)
            except OSError:
                pass
        else:
            # Extract file
            print "Extracting %s" % name
            try:
                os.makedirs(os.path.dirname(target))
            except OSError:
                pass
            open(target,'wb').write(z.read(name))
            file_list.append(target)
    print "Removing %s" % filen
    os.remove(filen)
    return file_list

def unpack_tar_archive(filen,wd=None):
    """
    Extract files from a TAR archive

    Given a TAR archive (which optionally can be
    compressed with either gzip or bz2), extract the
    files it contains and return a list of the
    resulting file names and paths.

    'wd' specifies the working directory to extract
    the files to, otherwise they are extracted to the
    current working directory.

    Once all the files are extracted the TAR archive
    file is deleted from the file system.

    """
    file_list = []
    if wd:
        path = wd
    else:
        path = '.'
    if not tarfile.is_tarfile(filen):
        print "%s: not TAR file"
        return [filen]
    t = tarfile.open(filen)
    for name in t.getnames():
        # Check for unwanted files
        if reduce(lambda x,y: x or name.startswith(y),IGNORE_PATHS,False):
            print "Ignoring %s" % name
            continue
        # Extract file
        print "Extracting %s" % name
        t.extract(name,wd)
        if wd:
            target = os.path.join(wd,name)
        else:
            target = name
        file_list.append(target)
    print "Removing %s" % filen
    os.remove(filen)
    return file_list

def unpack_archive(filen,wd=None):
    """
    Extract files from an archive

    Wrapper function that calls the appropriate
    unpacking function depending on the archive
    type, and returns a list of files that have
    been extracted.

    'wd' specifies the working directory to extract
    the files to, otherwise they are extracted to the
    current working directory.

    """
    print "Unpack %s" % filen
    f,ext = os.path.splitext(filen)
    print "Extension: %s" % ext
    if ext == ".zip":
        return unpack_zip_archive(filen,wd=wd)
    elif ext == ".tgz" or ext == '.tbz2':
        return unpack_tar_archive(filen,wd=wd)
    elif ext == ".gz" or ext == '.bz2':
        ext2 = os.path.splitext(f)[1]
        if ext2 == '.tar':
            return unpack_tar_archive(filen,wd=wd)
    return [filen]

def uncompress_file(filen,keep=False):
    """
    """
    print "Uncompress %s" % filen
    target,ext = os.path.splitext(filen)
    print "Extension: %s" % ext
    if ext == ".gz":
        open(target,'wb').write(gzip.open(filen,'rb').read())
    elif ext == ".bz2":
        open(target,'wb').write(bz2.BZ2File(filen,'rb').read())
    else:
        # Nothing to do
        return filen
    if not keep:
        os.remove(annotation_file_path)
    return target

# Unit tests
import unittest
import tempfile
import os

class TestInputParams(unittest.TestCase):
    def setUp(self):
        # Make a JSON example file
        fp,self.jsonfile = tempfile.mkstemp()
        fp = os.fdopen(fp,'w')
        fp.write("""{
   "param_dict":{
      "__datatypes_config__":"/Users/dan/galaxy-central/database/tmp/tmphyQRH3",
      "__get_data_table_entry__":"<function get_data_table_entry at 0x10d435b90>",
      "userId":"1",
      "userEmail":"dan@bx.psu.edu",
      "dbkey":"sacCer2",
      "sequence_desc":"",
      "GALAXY_DATA_INDEX_DIR":"/Users/dan/galaxy-central/tool-data",
      "__admin_users__":"dan@bx.psu.edu",
      "__app__":"galaxy.app:UniverseApplication",
      "__user_email__":"dan@bx.psu.edu",
      "sequence_name":"",
      "GALAXY_DATATYPES_CONF_FILE":"/Users/dan/galaxy-central/database/tmp/tmphyQRH3",
      "__user_name__":"danb",
      "sequence_id":"",
      "reference_source":{
         "reference_source_selector":"ncbi",
         "requested_identifier":"sacCer2",
         "__current_case__":"1"
      },
      "__new_file_path__":"/Users/dan/galaxy-central/database/tmp",
      "__user_id__":"1",
      "out_file":"/Users/dan/galaxy-central/database/files/000/dataset_200.dat",
      "GALAXY_ROOT_DIR":"/Users/dan/galaxy-central",
      "__tool_data_path__":"/Users/dan/galaxy-central/tool-data",
      "__root_dir__":"/Users/dan/galaxy-central",
      "chromInfo":"/Users/dan/galaxy-central/tool-data/shared/ucsc/chrom/sacCer2.len"
   },
   "output_data":[
      {
         "extra_files_path":"/Users/dan/galaxy-central/database/job_working_directory/000/202/dataset_200_files",
         "file_name":"/Users/dan/galaxy-central/database/files/000/dataset_200.dat",
         "ext":"data_manager_json",
         "out_data_name":"out_file",
         "hda_id":201,
         "dataset_id":200
      }
   ],
   "job_config":{
      "GALAXY_ROOT_DIR":"/Users/dan/galaxy-central",
      "GALAXY_DATATYPES_CONF_FILE":"/Users/dan/galaxy-central/database/tmp/tmphyQRH3",
      "TOOL_PROVIDED_JOB_METADATA_FILE":"galaxy.json"
   }
}
""")
        fp.close()
    def tearDown(self):
        # Remove the temporary JSON file
        if os.path.exists(self.jsonfile):
            os.remove(self.jsonfile)
    def test_input_params(self):
        # Read in some JSON
        p = InputParams(self.jsonfile)
        # Check some values from param_dict
        self.assertEqual(p.param_dict['dbkey'],'sacCer2')
        self.assertEqual(p.param_dict['sequence_desc'],'')
        self.assertEqual(p.param_dict['sequence_name'],'')
        self.assertEqual(p.param_dict['sequence_id'],'')
        self.assertEqual(p.param_dict['reference_source']['reference_source_selector'],'ncbi')
        self.assertEqual(p.param_dict['reference_source']['requested_identifier'],'sacCer2')
        # Check some values from output_data
        self.assertEqual(p.extra_files_path,"/Users/dan/galaxy-central/database/job_working_directory/000/202/dataset_200_files")
        # Check some values from job_config
        self.assertEqual(p.job_config['GALAXY_ROOT_DIR'],
                         "/Users/dan/galaxy-central")
        self.assertEqual(p.job_config['GALAXY_DATATYPES_CONF_FILE'],
                         "/Users/dan/galaxy-central/database/tmp/tmphyQRH3")

class TestDataTable(unittest.TestCase):
    def test_data_table(self):
        # Create a data table
        tbl = DataTable('ceas_annotations')
        self.assertEqual(tbl.name,'ceas_annotations')
        self.assertEqual(tbl.entries,[])
        # Add first entry
        tbl.add_entry(dbkey='hg19',name='Human',value='/path/to/hg19')
        self.assertEqual(len(tbl.entries),1)
        self.assertEqual(tbl.entries[0]['dbkey'],'hg19')
        self.assertEqual(tbl.entries[0]['name'],'Human')
        self.assertEqual(tbl.entries[0]['value'],'/path/to/hg19')
        # Add second entry
        tbl.add_entry(dbkey='mm9',name='Mouse',value='/path/to/mm9')
        self.assertEqual(len(tbl.entries),2)
        self.assertEqual(tbl.entries[1]['dbkey'],'mm9')
        self.assertEqual(tbl.entries[1]['name'],'Mouse')
        self.assertEqual(tbl.entries[1]['value'],'/path/to/mm9')

class TestDataTableSet(unittest.TestCase):
    def test_data_table_set(self):
        # Create a set of data tables
        tbls = DataTableSet()
        tbls.add_table('ceas_annotations')
        tbls.table('ceas_annotations').add_entry(dbkey='hg19',
                                                 name='Human',
                                                 value='/path/to/hg19')
        self.assertEqual(tbls.json(),
                         """{"data_tables": {"ceas_annotations": [{"value": "/path/to/hg19", "name": "Human", "dbkey": "hg19"}]}}""")
        tbls.table('ceas_annotations').add_entry(dbkey='mm9',
                                                 name='Mouse',
                                                 value='/path/to/mm9')
        self.assertEqual(tbls.json(),
                         """{"data_tables": {"ceas_annotations": [{"value": "/path/to/hg19", "name": "Human", "dbkey": "hg19"}, {"value": "/path/to/mm9", "name": "Mouse", "dbkey": "mm9"}]}}""")

class TestFetchFiles(unittest.TestCase):
    @unittest.skip("Test not yet implemented")
    def test_fetch_files(self):
        raise NotImplementedError

class TestDownloadFile(unittest.TestCase):
    @unittest.skip("Test not yet implemented")
    def test_download_file(self):
        raise NotImplementedError

class TestUnpackZipArchive(unittest.TestCase):
    @unittest.skip("Test not yet implemented")
    def test_unpack_zip_archive(self):
        raise NotImplementedError

class TestUnpackTarArchive(unittest.TestCase):
    @unittest.skip("Test not yet implemented")
    def test_unpack_tar_archive(self):
        raise NotImplementedError

class TestUnpackArchive(unittest.TestCase):
    @unittest.skip("Test not yet implemented")
    def test_unpack_archive(self):
        raise NotImplementedError

class TestUncompressFile(unittest.TestCase):
    @unittest.skip("Test not yet implemented")
    def test_uncompress_file(self):
        raise NotImplementedError


        
