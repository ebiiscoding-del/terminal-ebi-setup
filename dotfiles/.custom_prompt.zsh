# ── Custom colored path prompt ──

_home_icon() {
    echo "%F{255} \uf8ff %f"
}

_color_path() {
    local path_str="$PWD"
    local home="$HOME"
    if [[ "$path_str" == "$home" ]]; then
        path_str=""
    elif [[ "$path_str" == "$home"/* ]]; then
        path_str="${path_str#$home/}"
    fi
    local -a parts filtered
    parts=("${(s:/:)path_str}")
    for part in "${parts[@]}"; do [[ -n "$part" ]] && filtered+=("$part"); done
    [[ ${#filtered[@]} -eq 0 ]] && { echo ""; return; }
    local -a bg_colors
    bg_colors=(39 141 212 114 226 208 87 183 209 75)
    local fg=232 ARROW=$'\ue0b0' result=""
    local total=${#filtered[@]}
    for ((i=1; i<=total; i++)); do
        local part="${filtered[$i]}"
        local bg="${bg_colors[$(( ((i-1) % 10) + 1 ))]}"
        local next_bg="${bg_colors[$(( (i % 10) + 1 ))]}"
        result+="%K{$bg}%F{$fg} ${part} %f%k"
        if [[ $i -lt $total ]]; then result+="%K{$next_bg}%F{$bg}${ARROW}%f%k"
        else result+="%F{$bg}${ARROW}%f"; fi
    done
    echo "$result"
}

_git_info() {
    local branch=$(git branch --show-current 2>/dev/null)
    if [[ -n "$branch" ]]; then
        local dirty=""
        if [[ -n "$(git status --short 2>/dev/null)" ]]; then
            dirty="%F{214} !%f"
        fi
        echo " %F{238}on%f %F{141} ${branch}%f${dirty}"
    fi
}

_cmd_start_time=0
_cmd_exec_time="0s"
_last_exit=0

preexec() { _cmd_start_time=$EPOCHSECONDS }

_success_words=("Yay"  "Nice"      "Boom"        "Woo"        "Nailed it" "Sweet")
_success_exec=("took"  "in just"   "wrapped in"  "only took"  "in"        "done in")
_success_time=("@"     "at"        "right at"    "@"          "at"        "@")

_failure_words=("Oops" "Yikes"   "Nope"           "Ugh"       "D'oh"        "Busted")
_failure_exec=("blew up after" "died in" "gave up after" "failed in" "broke after" "crashed in")
_failure_time=("@"     "at"      "@"              "at"        "@"           "right at")

_build_prompt() {
    local home_icon=$(_home_icon)
    local path_colored=$(_color_path)
    local git_info=$(_git_info)
    local timestamp=$(date +%H:%M:%S)

    local s_color s_icon s_word exec_phrase time_phrase idx
    if [[ $_last_exit -eq 0 ]]; then
        s_color=114
        s_icon="✔"
        idx=$((RANDOM % ${#_success_words[@]} + 1))
        s_word="${_success_words[$idx]}"
        exec_phrase="${_success_exec[$idx]}"
        time_phrase="${_success_time[$idx]}"
    else
        s_color=196
        s_icon="✘"
        idx=$((RANDOM % ${#_failure_words[@]} + 1))
        s_word="${_failure_words[$idx]}"
        exec_phrase="${_failure_exec[$idx]}"
        time_phrase="${_failure_time[$idx]}"
    fi

    local status_box="%K{${s_color}}%F{232} ${s_word} ${s_icon} %f%k"
    local exec_box="%K{141}%F{232} ${exec_phrase} ${_cmd_exec_time} %f%k"
    local time_box="%K{205}%F{255} ${time_phrase} ${timestamp} %f%k"

    PROMPT="
%F{238}╭─%f ${home_icon}${path_colored}${git_info}
%F{238}╰─❯%f "

    RPROMPT="${status_box}${exec_box}${time_box}"
    ZLE_RPROMPT_INDENT=0
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
