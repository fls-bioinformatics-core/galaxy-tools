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
# Install conda/conda-build
CONDA_DIR=$(mktemp -u -d --tmpdir=$(pwd) --suffix=.miniconda)
planemo conda_init --conda_prefix $CONDA_DIR
$CONDA_DIR/bin/conda install -y conda-build
# Build local primer3, pal_finder and pandaseq
$CONDA_DIR/bin/conda build -c bioconda $(dirname $0)/../../conda-recipes/primer3
$CONDA_DIR/bin/conda build -c bioconda $(dirname $0)/../../conda-recipes/pal_finder
$CONDA_DIR/bin/conda build -c bioconda -m $(dirname $0)/../../conda-recipes/scripts/bioconda_env_matrix.yml $(dirname $0)/../../conda-recipes/pandaseq
# Install local packages
planemo conda_install --conda_prefix $CONDA_DIR --conda_use_local $(dirname $0)/pal_finder_wrapper.xml
# Run the planemo tests
planemo test --conda_prefix $CONDA_DIR --conda_use_local $@ $(dirname $0)/pal_finder_wrapper.xml
# Remove the local conda install
rm -rf $CONDA_DIR
##
#
