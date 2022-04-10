#!/usr/bin/env bash
# A collection of useful assertions. Each one checks a condition and if the condition is not satisfied, exits the
# program. This is useful for defensive programming.

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=./log.sh
source "${dir}/log.sh"
# shellcheck source=./array.sh
source "${dir}/array.sh"

# Check that the given binary is available on the PATH.
function assert_is_installed {
  local -r name="${1}"

  if ! command -v "${name}" > /dev/null; then
    log_error "The command '${name}' is required but is not installed or in the system's PATH."
    exit 1
  fi
}

# Check that the value of the given arg is not empty.
function assert_not_empty {
  local -r arg_name="${1}"
  local -r arg_value="${2}"
  local -r reason="${3}"

  if [[ -z "${arg_value}" ]]; then
    log error "The value for '${arg_name}' cannot be empty. ${reason}"
    exit 1
  fi
}

# Check that the given value is one of the values from the given list.
function assert_value_in_list {
  local -r arg_name="${1}"
  local -r arg_value="${2}"
  shift 2
  local -ar list=("$@")

  if ! array_contains "${arg_value}" "${list[@]}"; then
    log error "'${arg_value}' is not a valid value for ${arg_name}. Must be one of: [${list[@]}]."
    exit 1
  fi
}

# Check that the given file exists
function assert_file_exists {
  local -r file_name="${1}"  
  local -r reason="${2}"

  if [[ ! -f "${file_name}" ]]; then
    log error "'${file_name}' must exist. ${reason}"
    exit 1
  fi  
}

#TODO function call assert