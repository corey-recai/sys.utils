#!/bin/bash

# declare arrays for the bundle lists
declare -a installed_bundles
declare -a all_bundles

# format printer -- normalizes multiline strings
function fmt.print {
  # only takes one argument
  if [ "$#" -gt 1 ]; then
    echo "fmt.print:ERROR: Too many arguments"
    # stop execution and forward default error to discard
    return 1 2>/dev/null
  fi
  # return formatted string
  echo -e "\n$1" | awk '{$1=$1};1'
}

function create_dir {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

function create_file {
  if [ ! -e "$1" ]; then
    touch "$1"
  fi
}

# ask for elevated privileges
function get_permission {
  fmt.print "The script requires elevated privileges, please enter your user password"
  sudo echo 0 >/dev/null
}

function do_destroy {
  # unset variables and exit with supplied status code
  unset installed_bundles
  unset all_bundles
  exit $1
}

function swupd_list {
  if [ $1 = "installed" ]; then
    IFS=$'\n' installed_bundles=($(swupd bundle-list 2>&1 | awk '/Installed bundles:/ {bundles=1; next} bundles && /^ - / {print $2}' 2>/dev/null))
  elif [ $1 = "all" ]; then
    IFS=$'\n' all_bundles=($(sudo swupd bundle-list -a 2>&1 | awk '/All available bundles:/ {bundles=1; next} bundles && /^ - / {print $2}' 2>/dev/null))
  else
    return 1 2>/dev/null
  fi
}

function swupd_add {
  if [[ -z "${all_bundles[@]}" ]]; then
    # get all bundles
    swupd_list "all"
  fi

  if [[ ${all_bundles[@]} =~ "$1" ]]; then
    sudo swupd bundle-add "$1"
    installed_bundles+=("$1")
  else
    fmt.print "ERROR: Could not install $1
            Please submit an issue at https://github.com/corey-recai/sys.utils/issues, or try to install manually using the follwing command:

            $ sudo swupd bundle-add $1"

    do_destroy 1
  fi
}

function validate_bundle {
  if [[ -z "${installed_bundles[@]}" ]]; then
    # get installed bundles
    swupd_list "installed"
  fi

  if [[ ${installed_bundles[@]} =~ "$1" ]]; then
    echo true
  else
    echo false
  fi
}

function is_installed {
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
    swupd_add $1
    shift
    for arg in "$@"; do
      is_installed "$arg"
    done
  fi
}

function check_bundles {
  is_installed "$@"
}

# $1 - name of group to check
function user_in_group {
  # check is the current user is in the specified group
  if groups $USER | grep -q "$1"; then
    fmt.print "INFO: $USER is part of $1 group"
  else
    fmt.print "ERROR: $USER is not part of $1 group
            The process will attempt to add the user to the $1 group..."
    sudo usermod -aG "$1" "$USER"
  fi
}

function pkg-add {
  # execute the install commands
  $@

  fmt.print "There are ${#installed_bundles[@]} bundles installed"
  do_destroy 0
}

function do_install {
  get_permission
  # load the install script for the selected package
  source "packages/$1/install.sh"

  pkg-add "cpkg-$1"
}

function do_default {
  fmt.print "cpkg:ERROR: Unknown command: $1"
  exit 1
}
