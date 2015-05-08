#!/bin/bash

function remote() {
  local package_dir=$1
  local remote_ip=$2
  local keyfile=$3

  local remote_dir=/tmp
  # local cmd="$3"

  exists() {
    local archive=remote.tar.bz2
    local file=$LIB_TMP_DIR/$archive

    delete() {
      [[ -e $file ]] && rm $file || return 0
    }
    
    package() {
      tar -cvjf $file $package_dir
    }

    check() {
      checksum $file    
    }

    send() {
      # echo "scp $file $remote_ip:/tmp"
      scp -i $keyfile $file $remote_ip:$remote_dir
    }

    unpack() {
      ssh -i $keyfile $remote_ip "tar -xvjf $remote_dir/$archive -C $remote_dir"
    }

    clean() {
      ssh -i $keyfile $remote_ip "rm $remote_dir/$archive"
    }

    run delete package check send unpack clean
  }

  error() {
    echo "Cannot find $package_dir."
    return 1;
  }

  if [ -e $package_dir ]; then
    exists
  else
    error
  fi;
}