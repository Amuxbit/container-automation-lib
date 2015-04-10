#!/bin/bash
#
# container-automation-lib
# ------------------------
# author: Jason Giedymin
# license: Apache v2
# repo: https://github.com/Amuxbit/container-automation-lib
# version: 1.0.1
#

function debug() {
  printf "\n ---> [$@]\n"
}

#
# Run a list of functions (map)
#
function run() {
  local cmdList=("$@")

  for cmd in "${cmdList[@]}" ; do
      debug "$cmd"
      $cmd
      local rc=$?
      if [ $rc -gt 0 ]; then
        echo "Function [$cmd] failed with return code [$rc]"
        return $rc;
      else
        echo "[$cmd] exited successfully."
      fi
  done

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
      # echo "Running $cmd"
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
