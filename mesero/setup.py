"""Description

Setup script to install mesero module

Copyright (C) University of Manchester 2015 Peter Briggs

"""
# Setup for installation etc
from setuptools import setup
import mesero
setup(name='mesero',
      version=mesero.__version__,
      py_modules=['mesero'],
  )
