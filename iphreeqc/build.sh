#!/bin/bash

./configure --prefix=$PREFIX \
            --enable-static=no  # Static library are >100 MB!!!

make
make check
make install
