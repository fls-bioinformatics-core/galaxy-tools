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
INSTALL_DIR=$(pwd)/test.tool_dependencies/pal_finder
if [ -e $INSTALL_DIR ] ; then
    echo $INSTALL_DIR already exists >&2
else
    # Download and install pal_finder and primer3_core
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    # pal_finder
    echo Installing pal_finder
    wget -q http://sourceforge.net/projects/palfinder/files/pal_finder_v0.02.04.tar.gz
    tar xzf pal_finder_v0.02.04.tar.gz
    mkdir $INSTALL_DIR/bin
    mv pal_finder_v0.02.04/pal_finder_v0.02.04.pl $INSTALL_DIR/bin
    mkdir $INSTALL_DIR/data
    mv pal_finder_v0.02.04/config.txt $INSTALL_DIR/data/
    mv pal_finder_v0.02.04/simple.ref $INSTALL_DIR/data/
    # primer3_core
    echo Installing primer3_core
    wget -q https://sourceforge.net/projects/primer3/files/primer3/2.0.0-alpha/primer3-2.0.0-alpha.tar.gz
    tar xzf primer3-2.0.0-alpha.tar.gz
    cd primer3-2.0.0-alpha
    make -C src -f Makefile >/dev/null 2>&1
    mv src/primer3_core $INSTALL_DIR/bin
    cd ..
    # Perl 5.16.3
    echo Installing Perl
    wget -q http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz
    tar xzf perl-5.16.3.tar.gz
    cd perl-5.16.3
    ./Configure -des -Dprefix=$INSTALL_DIR -D startperl='#!/usr/bin/env perl' >/dev/null 2>&1
    make install >/dev/null 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
fi
# Set up the environment
export PATH=$INSTALL_DIR/bin:$PATH
export PALFINDER_SCRIPT_DIR=$INSTALL_DIR/bin
export PALFINDER_DATA_DIR=$INSTALL_DIR/data
# Run the planemo tests
planemo test $@ $(dirname $0)/pal_finder_wrapper.xml
##
#
