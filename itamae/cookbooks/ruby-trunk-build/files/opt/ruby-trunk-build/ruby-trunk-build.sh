#!/bin/bash

set -xe

SRC='/tmp/ruby-trunk-build-src'

if [ ! -d $SRC ]; then
  git clone --depth 1 https://github.com/ruby/ruby $SRC
  cd $SRC
else
  cd $SRC
  git fetch
  git checkout origin/trunk
fi



autoreconf
./configure --prefix=$HOME/.rbenv/versions/trunk --enable-shared
make -j
make install

$HOME/.rbenv/versions/trunk/bin/ruby -v
echo "Installing Ruby trunk successfully finished."
