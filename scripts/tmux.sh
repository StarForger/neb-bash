#!/usr/bin/env bash

function tmux_session_running() {
    local -r session_name="${1}"    
    local -r sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -Ecx "^${session_name}" || true)  
    # tmux has-session -t "${session_name}" 2>/dev/null
    [[ "${sessions}" -gt "0" ]]        
}