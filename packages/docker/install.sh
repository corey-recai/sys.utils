#!/bin/bash

# check if kvm is properly installed
function check_kvm {
  # look for /dev/kvm binary
  if [ -e /dev/kvm ]; then
    fmt.print "INFO: /dev/kvm exists
              KVM acceleration can be used"
  else
    fmt.print "INFO: /dev/kvm does not exist
              KVM acceleration can NOT be used"
  fi
}

function cpkg-docker {
  # check that necessary bundles are installed
  check_bundles "kvm-host" "kernel-kvm"
  # check that kvm is properly installed
  check_kvm
  user_in_group "kvm"
}
