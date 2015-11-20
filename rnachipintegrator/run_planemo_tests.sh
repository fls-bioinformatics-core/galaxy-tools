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
# List of dependencies
TOOL_DEPENDENCIES="rnachipintegrator/0.5.0-alpha.3
 xlwt/0.7.5
 xlrd/0.9.3
 xlutils/1.7.1"
# Where to find them
TOOL_DEPENDENCIES_DIR=$(pwd)/test.tool_dependencies.rnachipintegrator
if [ ! -d $TOOL_DEPENDENCIES_DIR ] ; then
    echo WARNING $TOOL_DEPENDENCIES_DIR not found >&2
    echo Creating tool dependencies dir
    mkdir -p $TOOL_DEPENDENCIES_DIR
    echo Installing tool dependencies
    $(dirname $0)/install_tool_deps.sh $TOOL_DEPENDENCIES_DIR
fi
# Load dependencies
for dep in $TOOL_DEPENDENCIES ; do
    env_file=$TOOL_DEPENDENCIES_DIR/$dep/env.sh
    if [ -e $env_file ] ; then
	. $env_file
    else
	echo ERROR no env.sh file found for $dep >&2
	exit 1
    fi
done
# Run the planemo tests
planemo test $@ \
    $(dirname $0)/rnachipintegrator_wrapper.xml \
    $(dirname $0)/rnachipintegrator_canonical_genes.xml \
    $(dirname $0)/data_manager/data_manager_rnachipintegrator_fetch_canonical_genes.xml
##
#
