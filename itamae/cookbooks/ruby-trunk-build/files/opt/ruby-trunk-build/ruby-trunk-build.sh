#!/bin/bash

set -xe

SRC='/tmp/ruby-trunk-build-src'

function retry() {
  local i
  local st
  for i in {1..10}; do
    set +e
    "$@"
    st=$?
    set -e
    test $st -eq 0 && break
    sleep $i
  done
  return $st
}

if [ ! -d $SRC ]; then
  retry git clone --depth 1 https://github.com/ruby/ruby $SRC
  cd $SRC
else
  cd $SRC
  retry git fetch
  git checkout origin/trunk
fi



autoreconf
./configure --prefix=$HOME/.rbenv/versions/trunk --enable-shared
make -j
make install

$HOME/.rbenv/versions/trunk/bin/ruby -v
echo "Installing Ruby trunk successfully finished."
