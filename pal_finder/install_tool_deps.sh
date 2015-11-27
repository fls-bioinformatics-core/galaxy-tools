#!/bin/bash
#
# Install the tool dependencies for pal_finder for testing from command line
#
# Installation directory
TOP_DIR=$1
if [ -z "$TOP_DIR" ] ; then
    echo Usage: $(basename $0) DIR
    exit
fi
if [ -z "$(echo $TOP_DIR | grep ^/)" ] ; then
    TOP_DIR=$(pwd)/$TOP_DIR
fi
if [ ! -d "$TOP_DIR" ] ; then
    mkdir -p $TOP_DIR
fi
cd $TOP_DIR
# Perl 5.16.3
echo Installing Perl
INSTALL_DIR=$TOP_DIR/perl/5.16.3
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
echo Moving to $wd
pushd $wd
wget -q http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz
tar xzf perl-5.16.3.tar.gz
cd perl-5.16.3
./Configure -des -Dprefix=$INSTALL_DIR -D startperl='#!/usr/bin/env perl' >/dev/null 2>&1
make install >/dev/null 2>&1
popd
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > perl/5.16.3/env.sh <<EOF
#!/bin/sh
# Source this to setup perl/5.16.3
echo Setting up perl 5.16.3
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
# primer3_core3
echo Installing primer3_core
INSTALL_DIR=$TOP_DIR/primer3_core/2.0.0
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
echo Moving to $wd
pushd $wd
wget -q https://sourceforge.net/projects/primer3/files/primer3/2.0.0-alpha/primer3-2.0.0-alpha.tar.gz
tar xzf primer3-2.0.0-alpha.tar.gz
cd primer3-2.0.0-alpha
make -C src -f Makefile >/dev/null 2>&1
mkdir $INSTALL_DIR/bin
mv src/primer3_core $INSTALL_DIR/bin
popd
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > primer3_core/2.0.0/env.sh <<EOF
#!/bin/sh
# Source this to setup primer3_core/2.0.0
echo Setting up primer3_core 2.0.0
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
# Pal_finder 0.02.04
echo Installing pal_finder
INSTALL_DIR=$TOP_DIR/pal_finder/0.02.04
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
echo Moving to $wd
pushd $wd
wget -q http://sourceforge.net/projects/palfinder/files/pal_finder_v0.02.04.tar.gz
tar xzf pal_finder_v0.02.04.tar.gz
mkdir $INSTALL_DIR/bin
mv pal_finder_v0.02.04/pal_finder_v0.02.04.pl $INSTALL_DIR/bin
mkdir $INSTALL_DIR/data
mv pal_finder_v0.02.04/config.txt $INSTALL_DIR/data/
mv pal_finder_v0.02.04/simple.ref $INSTALL_DIR/data/
popd
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > pal_finder/0.02.04/env.sh <<EOF
#!/bin/sh
# Source this to setup pal_finder/0.02.04
echo Setting up pal_finder 0.02.04
export PATH=$INSTALL_DIR/bin:\$PATH
export PALFINDER_SCRIPT_DIR=$INSTALL_DIR/bin
export PALFINDER_DATA_DIR=$INSTALL_DIR/data
#
EOF
# BioPython 1.65
echo Installing BioPython
INSTALL_DIR=$TOP_DIR/biopython/1.65
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
echo Moving to $wd
pushd $wd
pip install --install-option "--prefix=$INSTALL_DIR" https://pypi.python.org/packages/source/b/biopython/biopython-1.65.tar.gz >/dev/null 2>&1
popd
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > biopython/1.65/env.sh <<EOF
#!/bin/sh
# Source this to setup biopython/1.65
echo Setting up biopython 1.65
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib64/python2.7/site-packages:\$PYTHONPATH
#
EOF
# PandaSeq 2.8
echo Installing PandaSeq
INSTALL_DIR=$TOP_DIR/pandaseq/2.8.1
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
echo Moving to $wd
pushd $wd
wget -q https://github.com/neufeld/pandaseq/archive/v2.8.1.tar.gz
tar xzf v2.8.1.tar.gz
cd pandaseq-2.8.1
./autogen.sh >/dev/null 2>&1
./configure --prefix=$INSTALL_DIR >/dev/null 2>&1
make; make install >/dev/null 2>&1
popd
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > pandaseq/2.8.1/env.sh <<EOF
#!/bin/sh
# Source this to setup pandaseq/2.8.1
echo Setting up pandaseq 2.8.1
export PATH=$INSTALL_DIR/bin:\$PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH
#
EOF
##
#
