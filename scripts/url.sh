#!/usr/bin/env bash

# return true if string starts with http(s):// and can be considered a url
function url_check() {
  local -r value="${1}"

  [[ ${value:0:8} == "https://" || ${value:0:7} == "http://" ]]    
}

# return true if url points to file with suffix
function url_valid_file() {
  local -r suffix=${1}
  local -r url=${2}

  [[ "$url" == http*://*.${suffix} || "$url" == http*://*.${suffix}\?* ]]
}

# resolve url to final effective one
function url_resolve() {
  local -r url="${1}"
  local -r resolved_url=$(curl -Ls -o /dev/null -w %{url_effective} "$url")
  
  echo "${resolved_url}"
}

# get filename from url
function url_filename() {
  local -r url="${1}"
  local -r strippedOfQuery="${url%\?*}"
  basename "$strippedOfQuery"
}