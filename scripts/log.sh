#!/usr/bin/env bash

. "./array.sh"

# Log the given message at the given level. All logs are written to stderr with a timestamp.
function log {
  if [[ "$#" -lt 1 ]]; then
    log "ERROR" "log() missing level"
    return 2
  fi 
  local -r level="${1}"; shift
  local -r valid_levels=(
    "INFO"
    "WARN"
    "ERROR"
  )
  if ! array_contains "${level}" "${valid_levels}"; then
    log "ERROR" "Log level ${level} is not a valid level."
    return 2
  fi  
  local -r script_name="$(basename "$0")"
  # local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  (
    ([[ "$#" -ge 1 ]] && <<<"${*}" cat -) || cat -
  ) | awk -v level="${level}" '{ printf("%s [%s] %s\n", strftime("%FT%T%z"), level, $0); fflush(); }'
} >&2

# Log the given message at INFO level. All logs are written to stderr with a timestamp.
function log_info {
  local -r message="$1"

  log "INFO" "$message" <<< -
}

# Log the given message at WARN level. All logs are written to stderr with a timestamp.
function log_warn {
  local -r message="$1"
  log "WARN" "$message"
}

# Log the given message at ERROR level. All logs are written to stderr with a timestamp.
function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}