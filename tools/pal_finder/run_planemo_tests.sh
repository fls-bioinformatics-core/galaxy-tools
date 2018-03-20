#!/bin/bash
#
# Install dependencies and set up environment for
# pal_finder tool, then run tests using planemo
#
# Note that any arguments supplied to the script are
# passed directly to the "planemo test..." invocation
#
# e.g. --install_galaxy (to get planemo to create a
#                        Galaxy instance to run tests)
#
#      --galaxy_root DIR (to run tests using existing
#                         Galaxy instance)
#
# Run the planemo tests
planemo test  $@ $(dirname $0)/pal_finder_wrapper.xml
##
#
