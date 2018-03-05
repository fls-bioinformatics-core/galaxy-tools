#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make -C src -f Makefile

mkdir -p $PREFIX/bin
cp src/primer3_core $PREFIX/bin
