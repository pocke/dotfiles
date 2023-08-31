#!/bin/bash

# Itamae assumes macOS has BSD tools, but actually I installs GNU coreutils. So I need to reject GNU coreutils from PATH.
export PATH="$(echo $PATH | ruby -F: -pale '$_=$F.reject{_1.include?("/coreutils/")}.join(?:)')"

itamae local itamae/roles/main.rb $*
