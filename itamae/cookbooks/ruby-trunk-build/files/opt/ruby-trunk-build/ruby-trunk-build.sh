#!/bin/bash

set -xe

SRC='/tmp/ruby-trunk-build-src'

test -f /opt/homebrew/bin/brew && eval "$(/opt/homebrew/bin/brew shellenv)"

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

if [ -d $SRC ]; then
  rm -rf $SRC
fi

retry git clone --depth 1 https://github.com/ruby/ruby $SRC
cd $SRC



autoreconf --install
./configure --prefix=$HOME/.rbenv/versions/trunk --enable-shared
make -j
make install

$HOME/.rbenv/versions/trunk/bin/ruby -v
echo "Installing Ruby trunk successfully finished."
