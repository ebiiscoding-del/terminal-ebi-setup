# ── Custom colored path prompt ──

_color_path() {
    local path_str="$PWD"
    local home="$HOME"
    if [[ "$path_str" == "$home" ]]; then path_str="~"
    elif [[ "$path_str" == "$home"/* ]]; then path_str="~${path_str#$home}"; fi
    local -a parts filtered
    parts=("${(s:/:)path_str}")
    for part in "${parts[@]}"; do [[ -n "$part" ]] && filtered+=("$part"); done
    [[ ${#filtered[@]} -eq 0 ]] && filtered=("~")
    local -a bg_colors
    bg_colors=(39 141 212 114 226 208 87 183 209 75)
    local fg=232 ARROW=$'\ue0b0' result=""
    local total=${#filtered[@]}
    for ((i=1; i<=total; i++)); do
        local part="${filtered[$i]}"
        local bg="${bg_colors[$(( ((i-1) % 10) + 1 ))]}"
        local next_bg="${bg_colors[$(( (i % 10) + 1 ))]}"
        if [[ $i -eq 1 ]]; then result+="%K{$bg}%F{$fg}  ${part} %f%k"
        else result+="%K{$bg}%F{$fg} ${part} %f%k"; fi
        if [[ $i -lt $total ]]; then result+="%K{$next_bg}%F{$bg}${ARROW}%f%k"
        else result+="%F{$bg}${ARROW}%f"; fi
    done
    echo "$result"
}

_plain_path_len() {
    local path_str="$PWD"
    local home="$HOME"
    if [[ "$path_str" == "$home" ]]; then path_str="~"
    elif [[ "$path_str" == "$home"/* ]]; then path_str="~${path_str#$home}"; fi
    local -a parts filtered
    parts=("${(s:/:)path_str}")
    for part in "${parts[@]}"; do [[ -n "$part" ]] && filtered+=("$part"); done
    [[ ${#filtered[@]} -eq 0 ]] && filtered=("~")
    local len=0
    for part in "${filtered[@]}"; do
        len=$(( len + ${#part} + 4 ))  # 2 spaces + part + space + arrow(2wide)
    done
    echo $len
}

_git_info() {
    local branch=$(git branch --show-current 2>/dev/null)
    if [[ -n "$branch" ]]; then
        local dirty="" dirty_len=0
        if [[ -n "$(git status --short 2>/dev/null)" ]]; then
            dirty="%F{214} !%f"; dirty_len=2
        fi
        _git_len=$(( ${#branch} + dirty_len + 8 ))
        echo " %F{238}on%f %F{141} ${branch}%f${dirty}"
    else
        _git_len=0; echo ""
    fi
}

_cmd_start_time=0
_cmd_exec_time="0s"
_last_exit=0
_git_len=0

preexec() { _cmd_start_time=$EPOCHSECONDS }

_build_prompt() {
    local path_colored=$(_color_path)
    local git_info=$(_git_info)
    local timestamp=$(date +%H:%M:%S)
    local s_color s_icon
    if [[ $_last_exit -eq 0 ]]; then s_color=114; s_icon="✔"
    else s_color=196; s_icon="✘"; fi

    local path_len=$(_plain_path_len)
    local right_len=$(( 2 + 1 + 2 + ${#_cmd_exec_time} + 2 + ${#timestamp} + 2 ))
    local left_len=$(( 3 + path_len + _git_len ))
    local fill_len=$(( COLUMNS - left_len - right_len - 3 ))
    [[ $fill_len -lt 1 ]] && fill_len=1

    local filler="%F{238}${(l:${fill_len}::─:):-}%f"
    local status_box="%K{${s_color}}%F{232} ${s_icon} %f%k"
    local exec_box="%K{141}%F{232} ${_cmd_exec_time} %f%k"
    local time_box="%K{24}%F{255} ${timestamp} %f%k"

    PROMPT="
%F{238}╭─%f ${path_colored}${git_info}${filler}${status_box}${exec_box}${time_box}
%F{238}╰─❯%f "
    RPROMPT=""
}

precmd() {
    _last_exit=$?
    if [[ $_cmd_start_time -gt 0 ]]; then
        local elapsed=$(( EPOCHSECONDS - _cmd_start_time ))
        _cmd_exec_time="${elapsed}s"
        _cmd_start_time=0
    else
        _cmd_exec_time="0s"
    fi
    _build_prompt
}
