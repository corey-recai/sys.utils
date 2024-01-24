#!/bin/bash

tmp="$HOME/.$(uuidgen)"

# format printer -- normalizes multiline strings
fmt.print() {
  # only takes one argument
  if [ $# -gt 1 ]; then
    echo "fmt.print:ERROR: Too many arguments"

    # stop execution and forward default error to discard
    return 1 2>/dev/null
  fi

  # return formatted string
  echo -e $1 | awk '{$1=$1};1'
}

validate_bundle() {
  # forward bundle list to temporary file and truncate stdout
  swupd bundle-list >.tmp >/dev/null 2>&1
  if grep -q "$1" .tmp; then
    echo true
  else
    echo false
  fi
}

is_installed() {
  if $(validate_bundle "$1"); then
    echo -e "\nINFO: $1 is installed"
    # remove the first argument after processing
    shift
    # loop over remaining arguments
    for arg in "$@"; do
      # call is_installed recursively
      is_installed "$arg"
    done
  else
    echo -e "\nINFO: $1 is NOT installed"
    echo -e "The process will attempt to install $1..."
    sudo swupd bundle-add "$1"
    shift
    for arg in "$@"; do
      is_installed "$arg"
    done
  fi
}

check_bundles() {
  is_installed "kvm-host" "kernel-kvm"
}

# check if kvm is properly installed
kvm-ok() {
  # look for /dev/kvm binary
  if [ -e /dev/kvm ]; then
    fmt.print "INFO: /dev/kvm exists
              KVM acceleration can be used"
  else
    fmt.print "INFO: /dev/kvm does not exist
              KVM acceleration can NOT be used"
  fi
  check_bundles

}
