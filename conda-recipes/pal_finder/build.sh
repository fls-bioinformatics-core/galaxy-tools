#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM $PREFIX/share/$PKG_NAME

files="config.txt COPYING.txt pal_finder_v0.02.04.pl README.txt simple.ref"
for f in $files ; do
    cp ./$f $outdir/
done
mv $outdir/pal_finder_v$PKG_VERSION.pl $outdir/pal_finder
sed -i 's,^#!/usr/bin/perl,#!/usr/bin/env perl,g' $outdir/pal_finder
chmod +x $outdir/pal_finder

mkdir -p $PREFIX/bin
ln -s $outdir/pal_finder $PREFIX/bin
