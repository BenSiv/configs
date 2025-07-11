#!/bin/bash

prefix="/org/gnome/"

function read_keys() {
  local path=$1
  for key in $(dconf list "$path"); do
    if [[ "$key" == */ ]]; then
      # If ends with slash, recurse into that subpath
      read_keys "${path}${key}"
    else
      # Else print key and its value
      value=$(dconf read "${path}${key}")
      echo "${path}${key} = ${value}"
    fi
  done
}

read_keys "$prefix"
