#!/bin/bash
#
# container-automation-lib
# ------------------------
# author: Jason Giedymin
# license: Apache v2
# repo: https://github.com/Amuxbit/container-automation-lib
# version: 1.0.3
#

TMPDIR=${TMPDIR:-/tmp}
LIB_VERBOSE=$([[ $1 == true ]] && echo true || echo false);
LIB_TMP_DIR=$TMPDIR/automation-lib

# Verbose messages
function verbose() {
  local cmd=$1
  [[ $LIB_VERBOSE == true ]] && $cmd || return 0;
}

function debug() {
  printf "\n ---> [$@]\n"
}

# TODO: add color
function infoMsg() {
  printf "\n      [$@]\n"
}

# TODO: add color
function errorMsg() {
  printf "\n      [$@]\n"
}

#
# Returns the checksum (via shasum) to stdout.
# Works with directories and files.
#
function checksum() {
  local file_dir=$1
  if [ ! -e $file_dir ]; then
    error "Cannot find specified location $file_dir"
    return 1
  else
    if [ -d $file_dir ]; then
      tar c $file_dir | shasum -p | awk '{print $1}'
    else
      shasum -p $file_dir | awk '{print $1}'
    fi
  fi;
}

#
# Run a list of functions (map)
#
function run() {
  local cmdList=("$@")

  for cmd in "${cmdList[@]}"; do
    debug "$cmd"

    if [ $(type -t $cmd) == "function" ]; then
      if $cmd ; then
        echo "[$cmd] exited successfully."
      else
        local rc=$?
        echo "Function [$cmd] failed with return code [$rc]"
        return $rc;
      fi;
    else
      echo "$cmd not a function!"
      return 1
    fi;

  done;

  return 0;
}

#
# Run a single command for each entry of a user supplied list.
# I.e. the command being cpanm, and entries being libraries
#
function runCmd() {
  local cmd=$1
  shift
  local list=("$@")
  
  for entry in "${list[@]}" ; do
      $cmd $entry
      local rc=$?
      if [ $rc -gt 0 ]; then
        echo "Function [$cmd] failed with return code [$rc]"
        return $rc;
      else
        echo "[$cmd - $entry] exited successfully."
      fi
  done

  return 0; 
}

#
# Run a command in a loop feeding each entry as an arg
#
function runCmdShell() {
  local cmd=$1
  shift
  local list=("$@")
  
  for entry in "${list[@]}" ; do
      # echo "Running: $cmd $entry"
      shell "$cmd $entry"
      local rc=$?
      if [ $rc -gt 0 ]; then
        echo "Function [$cmd] failed with return code [$rc]"
        return $rc;
      else
        echo "[$cmd - $entry] exited successfully."
      fi
  done

  return 0; 
}

#
# My version of trap.
#
function catch() {
  local rc=$?

  if [ $rc -gt 0 ]; then
    echo "Script ran into errors, see above."
    exit $rc
  fi;
}

function cancel() {
  echo "Script canceled by user!"
  exit 2;
}

function setTrap() {
  trap cancel INT
}

#
# cpanm package installer
#
function runCpanm() {
  local packages=("$@")
  local cmd="cpanm --notest"
  runCmd "$cmd" "${packages[@]}"
}

#
# cpanm package installer from a login shell
#
function runCpanmShell() {
  local packages=("$@")
  local cmd="cpanm --notest"
  runCmdShell "$cmd" "${packages[@]}"
}

#
# Ubuntu apt-get updater, takes a list of packages to install.
#
function updateApt() {
  sudo apt-get update -y
}

#
# Ubuntu apt-get installer, takes a list of packages to install.
#
function runApt() {
  local packages=("$@")
  local cmd="sudo apt-get install -y"
  runCmd "$cmd" "${packages[@]}"
}

function cleanApt() {
  sudo apt-get clean
}

#
# Runs a command in a login shell
# shell(command)
function shell() {
  local command=$1
  $SHELL -ilc "$command"
}

#
# Example
# Update ubuntu
# -------------
# aptUpdate() {
#   update() {
#     sudo apt-get update -y
#   }
  
#   install() {
#     local packages=("curl" "libssl-dev")
#     runApt ${packages[@]}
#   }

#   local commands=(update install)
#   run "${commands[@]}"
# }

#
# Info
# -----
#
info() {
  echo "User: [$(whoami)]"
  # pushd $USER_HOME
  echo "Working directory [$(pwd)]"
  echo "Environment: $(env)"
}

#
# Library Init
# ------------
#
init() {
  banner() {
    verbose "echo Verbose mode: enabled"
  }

  prep() {
    mkdir -p $LIB_TMP_DIR
  }

  local commands=(banner prep)
  run "${commands[@]}"
}

init
