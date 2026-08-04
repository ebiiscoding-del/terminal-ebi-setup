# ── Custom colored path prompt ──

_home_icons=("🍏" "🍎")
_session_home_icon="${_home_icons[$((RANDOM % ${#_home_icons[@]} + 1))]}"

_home_icon() {
    echo "%F{255}${_session_home_icon} %f"
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

    # Keep the breadcrumb bounded regardless of how deep the directory nesting
    # goes -- an unbounded path here is what caused RPROMPT to overflow and
    # wrap on long paths. Show only the last N segments, with a truncation
    # marker standing in for anything dropped.
    local max_segments=3
    local -a truncated=("${filtered[@]}")
    local was_truncated=0
    if [[ ${#filtered[@]} -gt $max_segments ]]; then
        truncated=("${filtered[@]: -$max_segments}")
        was_truncated=1
    fi

    local -a bg_colors
    bg_colors=(39 141 212 114 226 208 87 183 209 75)
    local fg=232 ARROW=$'\ue0b0' result=""
    local total=${#truncated[@]}

    if [[ $was_truncated -eq 1 ]]; then
        result+="%K{242}%F{$fg} … %f%k%K{${bg_colors[1]}}%F{242}${ARROW}%f%k"
    fi

    for ((i=1; i<=total; i++)); do
        local part="${truncated[$i]}"
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

_success_words=("Yay"          "Nice"       "Boom"           "Woo"            "Nailed it"    "Sweet")
_success_exec=("took"         "in just"    "wrapped in"     "only took"      "in"           "done in")
_success_time=("clock says"   "timestamp:" "for the record" "receipts show"  "witnessed at" "logged at")

_failure_words=("Oops"          "Yikes"   "Nope"            "Ugh"         "D'oh"        "Busted")
_failure_exec=("blew up after" "died in" "gave up after"   "failed in"   "broke after" "crashed in")
_failure_time=("time of death" "RIP at"  "per the record"  "clock says"  "stamped at"  "evidence shows")

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
    local time_box="%K{205}%F{232} ${time_phrase} ${timestamp} %f%k"

    # Status boxes now live on their own line, right-aligned by manually
    # padding based on $COLUMNS -- this makes their position depend only on
    # the terminal width, never on the path breadcrumb below, which is what
    # caused the RPROMPT overflow/wrap/color-bleed on long or deep paths.
    local visible_len=$(( 1 + ${#s_word} + 1 + 1 + 1 ))
    visible_len=$(( visible_len + 1 + ${#exec_phrase} + 1 + ${#_cmd_exec_time} + 1 ))
    visible_len=$(( visible_len + 1 + ${#time_phrase} + 1 + ${#timestamp} + 1 ))

    local cols=${COLUMNS:-80}
    local padding=$(( cols - visible_len ))
    [[ $padding -lt 0 ]] && padding=0
    local pad_str=""
    if [[ $padding -gt 0 ]]; then
        pad_str="${(l:$padding:: :)pad_str}"
    fi

    PROMPT="%f%k
${pad_str}${status_box}${exec_box}${time_box}
%F{238}╭─%f ${home_icon}${path_colored}${git_info}
%F{238}╰─❯%f "

    RPROMPT=""
    ZLE_RPROMPT_INDENT=0
}

precmd() {
    _last_exit=$?
    _resync_terminal_size 2>/dev/null
    if [[ $_cmd_start_time -gt 0 ]]; then
        local elapsed=$(( EPOCHSECONDS - _cmd_start_time ))
        _cmd_exec_time="${elapsed}s"
        _cmd_start_time=0
    else
        _cmd_exec_time="0s"
    fi
    _build_prompt
}
