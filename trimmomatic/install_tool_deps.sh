#!/bin/bash
#
# Install dependencies for Trimmomatic for testing from the command line
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
# Trimmomatic 0.32
INSTALL_DIR=$TOP_DIR/trimmomatic/0.32
mkdir -p $INSTALL_DIR
wd=$(mktemp -d)
pushd $wd
wget -q http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.32.zip
unzip -qq Trimmomatic-0.32.zip
mv Trimmomatic-0.32/trimmomatic-0.32.jar $INSTALL_DIR/
mv Trimmomatic-0.32/adapters/ $INSTALL_DIR/
popd
rm -rf $wd/*
rmdir $wd
# Make setup file
cat > trimmomatic/0.32/env.sh <<EOF
#!/bin/sh
# Source this to setup trimmomatic/0.32
echo Setting up Trimmomatic 0.32
export TRIMMOMATIC_DIR=$INSTALL_DIR
export TRIMMOMATIC_ADAPTERS_DIR=$INSTALL_DIR/adapters
#
EOF
##
#
