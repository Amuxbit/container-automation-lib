#!/bin/bash

#
# Downloads the container library and immediately sources it.
#
# Usage:
#   Download and source this file. Libs will automatically be pulled
#   OR
#   Execute this script in the desired base location.
#

LIB_VERBOSE=$([[ $1 == true ]] && echo true || echo false);

#
# Only runs cmd, passed in as $1, if verbose is enabled.
# Useful for when logging is desired only in certain situations.
#
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

source ./lib/core.sh;
