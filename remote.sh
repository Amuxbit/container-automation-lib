#!/bin/bash

#
# example:
#   remote send 'data' $REMOTE_IP $KEY_FILE /tmp
#
function remote() {
  local cmd="$1"
  local package_dir=$2
  local remote_ip=$3
  local keyfile=$4
  local remote_dir=$5
  local user=$6
  local sudo=${SUDO:-""}

  local archive=remote.tar.bz2
  local file=$LIB_TMP_DIR/$archive

  function error() {
    echo "Cannot find $package_dir."
    return 1;
  }

  function delete() {
    [[ -e $file ]] && rm $file || return 0
  }
  
  function package() {
    tar -cvjf $file $package_dir
  }

  function check() {
    checksum $file
  }

  function sendFile() {
    scp -i $keyfile $file $remote_ip:$remote_dir  
  }

  function remote_unpack() {
    ssh -i $keyfile $remote_ip "tar -xvjf $remote_dir/$archive -C $remote_dir"
  }

  function remote_clean() {
    local file=$1
    local remote_file="$remote_dir/$archive"
    local clean_file=${file:-$remote_file}

    if [ $clean_file == '/' ]; then
      echo "code would attemp 'rm /', exiting now, this might be a bug!"
      return 1
    fi;

    ssh -i $keyfile $remote_ip "[ -e $clean_file ] && rm -R $clean_file || echo \"$clean_file doesn't exist to delete\""
  }

  function send() {
    if [ -e $package_dir ]; then
      run delete package check sendFile remote_unpack remote_clean
    else
      error
    fi;
  }

  function createDirectory() {
    local remoteDir=$1
    ssh -i $keyfile $remote_ip "$sudo mkdir -p $remoteDir"
  }

  function ownResource() {
    local remoteDir=$1
    local user=$2
    ssh -i $keyfile $remote_ip "$sudo chown $user $remoteDir"
  }

  case "$cmd" in
    send)
      run send
      ;;
    remove)
      local file=$2
      function remove() {
        remote_clean $file
      }

      run $cmd
      ;;
    createDir)
      local dirs=$2
      function createDir() {
        createDirectory $dirs
      }

      run $cmd
      ;;
    own)
      function own() {
        ownResource $package_dir $user
      }

      run $cmd
      ;;
    *)
      echo 'Invalid command'
      exit 1
      ;;
  esac

  catch
}