#!/bin/bash

# load the utility functions
source lib/utils.sh

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
}

install() {
  # check that necessary bundles are installed
  check_bundles "kvm-host" "kernel-kvm"

  # fmt.print "Trying to stop intentionally..."
  # return 1 2>/dev/null

  # check that kvm is properly installed
  kvm-ok
}
