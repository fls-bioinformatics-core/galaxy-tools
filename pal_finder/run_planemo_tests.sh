#!/bin/bash
#
# Install dependencies and set up environment for
# pal_finder tool
#
INSTALL_DIR=$(pwd)/tool_dependencies/pal_finder/0.02.04
if [ -e $INSTALL_DIR ] ; then
    echo $INSTALL_DIR already exists >&2
    exit 1
fi
mkdir -p $INSTALL_DIR
#
# Download and install pal_finder and primer3_core
wd=$(mktemp -d)
echo Moving to $wd
pushd $wd
# pal_finder
wget http://sourceforge.net/projects/palfinder/files/pal_finder_v0.02.04.tar.gz
tar xzf pal_finder_v0.02.04.tar.gz
mkdir $INSTALL_DIR/bin
mv pal_finder_v0.02.04/pal_finder_v0.02.04.pl $INSTALL_DIR/bin
mkdir $INSTALL_DIR/data
mv pal_finder_v0.02.04/config.txt $INSTALL_DIR/data/
mv pal_finder_v0.02.04/simple.ref $INSTALL_DIR/data/
# primer3_core
wget https://sourceforge.net/projects/primer3/files/primer3/2.0.0-alpha/primer3-2.0.0-alpha.tar.gz
tar xzf primer3-2.0.0-alpha.tar.gz
cd primer3-2.0.0-alpha
make -C src -f Makefile
mv src/primer3_core $INSTALL_DIR/bin
cd ..
# Perl
wget http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz
tar xvf perl-5.16.3.tar.gz
cd perl-5.16.3
./Configure -des -Dprefix=$INSTALL_DIR -D startperl='#!/usr/bin/env perl'
make install
popd
#rm -rf $wd/*
#rmdir $wd
# Set up the environment
export PATH=$INSTALL_DIR/bin:$PATH
export PALFINDER_SCRIPT_DIR=$INSTALL_DIR/bin
export PALFINDER_DATA_DIR=$INSTALL_DIR/data
# Run the planemo tests
planemo test --install_galaxy $(dirname $0)/pal_finder_wrapper.xml
##
#
