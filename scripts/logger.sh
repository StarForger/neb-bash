#!/usr/bin/env bash

## Description {{{
#
# Logger for shell script.
#
# Homepage: https://github.com/rcmdnk/shell-logger
#
# }}}

# Default variables {{{
LOGGER_DATE_FORMAT=${LOGGER_DATE_FORMAT:-'%Y-%m-%d %H:%M:%S'}
LOGGER_LEVEL=${LOGGER_LEVEL:-1} # 0: debug, 1: info, 2: notice, 3: warning, 4: error
LOGGER_STDERR_LEVEL=${LOGGER_STDERR_LEVEL:-4}

LOGGER_DEBUG_COLOR=${LOGGER_INFO_COLOR:-"3"}
LOGGER_INFO_COLOR=${LOGGER_INFO_COLOR:-""}
LOGGER_NOTICE_COLOR=${LOGGER_INFO_COLOR:-"36"}
LOGGER_WARNING_COLOR=${LOGGER_INFO_COLOR:-"33"}
LOGGER_ERROR_COLOR=${LOGGER_INFO_COLOR:-"31"}
LOGGER_COLOR=${LOGGER_COLOR:-auto}
LOGGER_COLORS=("$LOGGER_DEBUG_COLOR" "$LOGGER_INFO_COLOR" "$LOGGER_NOTICE_COLOR" "$LOGGER_WARNING_COLOR" "$LOGGER_ERROR_COLOR")

if [ "${LOGGER_LEVELS}" = "" ];then
  LOGGER_LEVELS=("DEBUG" "INFO" "NOTICE" "WARNING" "ERROR")
fi
LOGGER_SHOW_TIME=${LOGGER_SHOW_TIME:-1}
LOGGER_SHOW_FILE=${LOGGER_SHOW_FILE:-1}
LOGGER_SHOW_LEVEL=${LOGGER_SHOW_LEVEL:-1}
LOGGER_ERROR_RETURN_CODE=${LOGGER_ERROR_RETURN_CODE:-100}
LOGGER_ERROR_TRACE=${LOGGER_ERROR_TRACE:-1}
# }}}

# Other global variables {{{
_LOGGER_WRAP=0
#}}}

# Functions {{{
_get_level () {
  if [ $# -eq 0 ]; then
    local level=1
  else
    local level=$1
  fi
  if ! expr "$level" : '[0-9]*' >/dev/null; then
    [ -z "$ZSH_VERSION" ] || emulate -L ksh
    local i=0
    while [ $i -lt ${#LOGGER_LEVELS[@]} ];do
      if [ "$level" = "${LOGGER_LEVELS[$i]}" ]; then
        level=$i
        break
      fi
      ((i++))
    done
  fi
  echo $level
}

_logger_level () {
  [ "$LOGGER_SHOW_LEVEL" -ne 1 ] && return
  if [ $# -eq 1 ];then
    local level=$1
  else
    local level=1
  fi
  [ -z "$ZSH_VERSION" ] || emulate -L ksh
  printf "[${LOGGER_LEVELS[$level]}]"
}

_logger_time () {
  [ "$LOGGER_SHOW_TIME" -ne 1 ] && return
  printf "[$(date +"$LOGGER_DATE_FORMAT")]"
}

_logger_file () {
  [ "$LOGGER_SHOW_FILE" -ne 1 ] && return
  local i=0
  if [ $# -ne 0 ];then
    i=$1
  fi
  if [ -n "$BASH_VERSION" ];then
    printf "[${BASH_SOURCE[$((i+1))]}:${BASH_LINENO[$i]}]"
  else
    emulate -L ksh
    printf "[${funcfiletrace[$i]}]"
  fi
}

_logger () {
  ((_LOGGER_WRAP++))
  local wrap=${_LOGGER_WRAP}
  _LOGGER_WRAP=0
  if [ $# -eq 0 ];then
    return
  fi
  local level="$1"
  shift
  if [ "$level" -lt "$(_get_level "$LOGGER_LEVEL")" ];then
    return
  fi
  local msg="$(_logger_time)$(_logger_file "$wrap")$(_logger_level "$level") $*"
  local _logger_printf=printf
  local out=1
  if [ "$level" -ge "$LOGGER_STDERR_LEVEL" ];then
    out=2
    _logger_printf=">&2 printf"
  fi
  if [ "$LOGGER_COLOR" = "always" ] || { test "$LOGGER_COLOR" = "auto"  && test -t $out ; };then
    [ -z "$ZSH_VERSION" ] || emulate -L ksh
    eval "$_logger_printf \"\\e[${LOGGER_COLORS[$level]}m%s\\e[m\\n\"  \"$msg\""
  else
    eval "$_logger_printf \"%s\\n\" \"$msg\""
  fi
}

debug () {
  ((_LOGGER_WRAP++))
  _logger 0 "$*"
}

information () {
  ((_LOGGER_WRAP++))
  _logger 1 "$*"
}
info () {
  ((_LOGGER_WRAP++))
  information "$*"
}

notification () {
  ((_LOGGER_WRAP++))
  _logger 2 "$*"
}
notice () {
  ((_LOGGER_WRAP++))
  notification "$*"
}

warning () {
  ((_LOGGER_WRAP++))
  _logger 3 "$*"
}
warn () {
  ((_LOGGER_WRAP++))
  warning "$*"
}

error () {
  ((_LOGGER_WRAP++))
  if [ "$LOGGER_ERROR_TRACE" -eq 1 ];then
    {
      [ -z "$ZSH_VERSION" ] || emulate -L ksh
      local first=0
      if [ -n "$BASH_VERSION" ];then
        local current_source=$(echo "${BASH_SOURCE[0]##*/}"|cut -d"." -f1)
        local func="${FUNCNAME[1]}"
        local i=$((${#FUNCNAME[@]}-2))
      else
        local current_source=$(echo "${funcfiletrace[0]##*/}"|cut -d":" -f1|cut -d"." -f1)
        local func="${funcstack[1]}"
        local i=$((${#funcstack[@]}-1))
        local last_source=${funcfiletrace[$i]%:*}
        if [ "$last_source" = zsh ];then
          ((i--))
        fi
      fi
      if [ "$current_source" = "shell-logger" ] && [ "$func" = err ];then
        local first=1
      fi
      if [ $i -ge $first ];then
        echo "Traceback (most recent call last):"
      fi
      while [ $i -ge $first ];do
        if [ -n "$BASH_VERSION" ];then
          local file=${BASH_SOURCE[$((i+1))]}
          local line=${BASH_LINENO[$i]}
          local func=""
          if [ ${BASH_LINENO[$((i+1))]} -ne 0 ];then
            if [ "${FUNCNAME[$((i+1))]}" = "source" ];then
              func=", in ${BASH_SOURCE[$((i+2))]}"
            else
              func=", in ${FUNCNAME[$((i+1))]}"
            fi
          fi
          local func_call="${FUNCNAME[$i]}"
          if [ "$func_call" = "source" ];then
            func_call="${func_call} ${BASH_SOURCE[$i]}"
          else
            func_call="${func_call}()"
          fi
        else
          local file=${funcfiletrace[$i]%:*}
          local line=${funcfiletrace[$i]#*:}
          local func=""
          if [ -n "${funcstack[$((i+1))]}" ];then
            if [ "${funcstack[$((i+1))]}" = "${funcfiletrace[$i]%:*}" ];then
              func=", in ${funcfiletrace[$((i+1))]%:*}"
            else
              func=", in ${funcstack[$((i+1))]}"
            fi
          fi
          local func_call="${funcstack[$i]}"
          if [ "$func_call" = "${funcfiletrace[$((i-1))]%:*}" ];then
            func_call="source ${funcfiletrace[$((i-1))]%:*}"
          else
            func_call="${func_call}()"
          fi
        fi
        echo "  File \"${file}\", line ${line}${func}"
        if [ $i -gt $first ];then
          echo "    $func_call"
        else
          echo ""
        fi
        ((i--))
      done
    } 1>&2
  fi
  _logger 4 "$*"
  return "$LOGGER_ERROR_RETURN_CODE"
}
err () {
  ((_LOGGER_WRAP++))
  error "$*"
}
# }}}