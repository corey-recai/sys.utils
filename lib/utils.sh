#!/bin/bash

tmp_dir=".tmp"
# create a random file name
tmp="$tmp_dir/$(uuidgen)"

# format printer -- normalizes multiline strings
fmt.print() {
  # only takes one argument
  if [ $# -gt 1 ]; then
    echo "fmt.print:ERROR: Too many arguments"

    # stop execution and forward default error to discard
    return 1 2>/dev/null
  fi

  # return formatted string
  echo -e "\n$1" | awk '{$1=$1};1'
}

validate_bundle() {
  # forward bundle list to temporary file and truncate stdout
  swupd bundle-list >"$tmp" >/dev/null 2>&1
  if grep -q "$1" "$tmp"; then
    echo true
  else
    echo false
  fi
}

is_installed() {
  if $(validate_bundle "$1"); then
    fmt.print "INFO: $1 is installed"
    # remove the first argument after processing
    shift
    # loop over remaining arguments
    for arg in "$@"; do
      # call is_installed recursively
      is_installed "$arg"
    done
  else
    fmt.print "INFO: $1 is NOT installed
              The process will attempt to install $1..."
    sudo swupd bundle-add "$1"
    shift
    for arg in "$@"; do
      is_installed "$arg"
    done
  fi
}

check_bundles() {
  is_installed "$@"
}

run() {
  # create a temporary directory & file
  mkdir -p "$tmp_dir"
  touch "$tmp"
  # execute the install commands
  $@
  # remove any temporary files
  rm -rf "$tmp_dir"

}
