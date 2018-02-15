#!/bin/bash
#
# Install dependencies and set up environment for
# the ceas tool, then run tests using planemo
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
# Install conda/conda-build
CONDA_DIR=$(mktemp -u -d --tmpdir=$(pwd) --suffix=.miniconda)
planemo conda_init --conda_prefix $CONDA_DIR
$CONDA_DIR/bin/conda install -y conda-build
# Build and install local cistrome-ceas
$CONDA_DIR/bin/conda-build --python 2.7 $(dirname $0)/../../conda-recipes/cistrome-ceas
planemo conda_install --conda_prefix $CONDA_DIR --conda_use_local $(dirname $0)/ceas_wrapper.xml
# Run the planemo tests
planemo test $@ --conda_prefix $CONDA_DIR --conda_use_local $(dirname $0)/ceas_wrapper.xml
# Remove conda installation
rm -rf $CONDA_DIR
##
#
