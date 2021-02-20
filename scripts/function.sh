#!/usr/bin/env bash

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${dir}/log.sh"

function_exists() {
  local -r name="${1}"
  [ "$(type -t "${name}")" == "function" ]
}

function_call() {
  local -r function_name="${1}"
  if function_exists "${function_name}"; then
    eval "${@}"
  else
    log error "${function_name} is not a valid function!"
    return 1
  fi
}