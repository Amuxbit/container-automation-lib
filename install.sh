#!/bin/bash

#
# Downloads the container library and immediately sources it.
#
# Usage:
#   Download and source this file. Libs will automatically be pulled
#   OR
#   Execute this script in the desired base location.
#   OR
#   Optionally pass in true when calling this script for verbose output:
#     $ bash lib.sh true
#

LIB_VERBOSE=$([[ $1 == true ]] && echo true || echo false);

function verbose() {
  local cmd=$1
  [[ $LIB_VERBOSE == true ]] && $cmd
}

verbose "echo Verbose mode: enabled"

function gitInfo() {
  git status
  git remote show origin
}

if [ ! -e ./lib ]; then
  git clone git@github.com:Amuxbit/container-automation-lib.git lib
else
  pushd lib
  verbose gitInfo
  git pull
  popd
fi;

unset -f verbose # if in the future I want to create an verbose f(x)
source lib/core.sh