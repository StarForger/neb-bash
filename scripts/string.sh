#!/usr/bin/env bash

# Return true (0) if the first string (haystack) contains the second string (needle), and false (1) otherwise.
function string_contains {
  local -r haystack="$1"
  local -r needle="$2"

  [[ "$haystack" == *"$needle"* ]]
}

# Returns true (0) if the first string (haystack), which is assumed to contain multiple lines, contains the second
# string (needle), and false (1) otherwise. The needle can contain regular expressions.
function string_multiline_contains {
  local -r haystack="$1"
  local -r needle="$2"

  echo "$haystack" | grep -q "$needle"
}

# Convert the given string to uppercase
function string_to_uppercase {
  local -r str="$1"
  echo "$str" | awk '{print toupper($0)}'
}

# Strip the prefix from the given string. Supports wildcards.
#
# Example:
#
# string_strip_prefix "foo=bar" "foo="  ===> "bar"
# string_strip_prefix "foo=bar" "*="    ===> "bar"
#
# http://stackoverflow.com/a/16623897/483528
function string_strip_prefix {
  local -r str="$1"
  local -r prefix="$2"
  echo "${str#$prefix}"
}

# Strip the suffix from the given string. Supports wildcards.
#
# Example:
#
# string_strip_suffix "foo=bar" "=bar"  ===> "foo"
# string_strip_suffix "foo=bar" "=*"    ===> "foo"
#
# http://stackoverflow.com/a/16623897/483528
function string_strip_suffix {
  local -r str="$1"
  local -r suffix="$2"
  echo "${str%$suffix}"
}

# Return true if the given response is empty or "null" (the latter is from jq parsing).
function string_is_empty_or_null {
  local -r response="$1"
  [[ -z "$response" || "$response" == "null" ]]
}

# Return colour format string when given level or colour name (requires ncurses)
function string_colour() {
  [[ ! $(command -v "tput" &> /dev/null) ]] && return
  local name="${1,,}"
  case "$name" in
    "reset")
      echo $(tput sgr0)
    ;;
    "warn"|"yellow")
      echo $(tput setaf 3)
    ;;
    "error"|"fatal"|"red")
      echo $(tput setaf 1)
    ;;
    *)
      :
    ;;
  esac
}