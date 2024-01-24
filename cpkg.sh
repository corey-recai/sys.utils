#!/bin/bash

# cpkg install <package name>
# $1 - command install, remove, etc.
# $2 - package name
cpkg() {
  # run commands in subshells to avoid collisions & exit appropriately
  case "$1" in
  install)
    (source lib/utils.sh && do_install "$2")
    ;;
  *)
    (source lib/utils.sh && do_default "$1")
    ;;
  esac
  return 1 2>/dev/null
}
