#!/usr/bin/env bash


tmux_status() {
    local -r session_name="${1}"    
    # $(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -Ecx "^${session_name}" || true)  
    tmux has-session -t "${session_name}"  
}