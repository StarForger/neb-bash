#!/usr/bin/env bash

# return true if string starts with http(s):// and can be considered a url
url_check() {
  local -r value="${1}"

  [[ ${value:0:8} == "https://" || ${value:0:7} == "http://" ]]    
}

# resolve url to final effective one
url_resolve() {
  local -r url="${1}"
  local -r resolved_url=$(curl -Ls -o /dev/null -w %{url_effective} "$url")
  
  echo "${resolved_url}"
}

# get filename from url
url_filename() {
  local -r url="${1}"
  local -r strippedOfQuery="${url%\?*}"
  basename "$strippedOfQuery"
}