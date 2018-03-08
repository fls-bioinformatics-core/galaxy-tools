#!/bin/bash
#
# Install dependencies and set up environment for
# rnachipintegrator tool, then run tests using planemo
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
planemo test $@ \
    $(dirname $0)/rnachipintegrator_wrapper.xml \
    $(dirname $0)/rnachipintegrator_canonical_genes.xml \
    $(dirname $0)/data_manager/data_manager_rnachipintegrator_fetch_canonical_genes.xml
##
#
