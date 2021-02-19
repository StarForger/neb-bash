#!/usr/bin/env bash

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${dir}/array.sh"
source "${dir}/string.sh"

# Log the given message at the given level. All logs are written to stderr with a timestamp.
function log {
  if [[ "$#" -lt 1 ]]; then
    log "ERROR" "log() missing level"
    return
  fi 
  local -r level="${1^^}"; shift
  local valid_levels=(
    "INFO"
    "WARN"
    "ERROR"
  )
  if ! array_contains "${level}" "${valid_levels[@]}"; then
    log "ERROR" "Log level \"${level}\" is not a valid level."
    return
  fi  
  local colour=$(string_colour ${level})
  local reset=$(string_colour reset)
  (
    ([[ "$#" -ge 1 ]] && <<<"${*}" cat -) || cat -
  ) | awk -v level="${level}" -v name="$(basename "$0")" -v colour="$colour" -v r="$reset" \
    '{ printf("%s [%s] [%s] %s%s%s\n", strftime("%FT%T"), level, name, colour, $0, r); fflush(); }'
} >&2
