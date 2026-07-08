#!/bin/bash

# ── Colors ──
GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
YELLOW='\033[38;5;226m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
CYAN='\033[38;5;87m'
RESET='\033[0m'
BOLD='\033[1m'

clear

# ── Header ──
echo ""
echo -e "${PURPLE}${BOLD}  ╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}${BOLD}  ║         Ebi's Terminal Dashboard                 ║${RESET}"
echo -e "${PURPLE}${BOLD}  ╚══════════════════════════════════════════════════╝${RESET}"
echo -e "${GRAY}  $(date '+%A, %B %d %Y  %H:%M:%S')${RESET}"
echo ""

# ── System Status ──
echo -e "${CYAN}${BOLD}  ── System ─────────────────────────────────────────${RESET}"
load=$(uptime | awk '{print $10}' | tr -d ',')
battery=$(pmset -g batt | grep -o '[0-9]*%' | head -1)
disk=$(df -h / | tail -1 | awk '{print $5}')
mem=$(top -l 1 | grep PhysMem | awk '{print $2}')
echo -e "  ${GRAY}Load:${RESET}    ${WHITE}$load${RESET}   ${GRAY}Battery:${RESET} ${WHITE}$battery${RESET}   ${GRAY}Disk:${RESET} ${WHITE}$disk${RESET}   ${GRAY}RAM:${RESET} ${WHITE}$mem${RESET}"
echo ""

# ── Automation Scripts Status ──
echo -e "${CYAN}${BOLD}  ── Automation Scripts ──────────────────────────────${RESET}"
echo ""

check_script() {
    local name=$1
    local log=$2
    local schedule=$3
    local today=$(date '+%Y-%m-%d')

    if [ -f "$log" ]; then
        local last_scheduled_line=$(grep -E "^── [0-9]{4}-[0-9]{2}-[0-9]{2}.*\[scheduled\]" "$log" | tail -1)
        local last_any_line=$(grep -E "^── [0-9]{4}-[0-9]{2}-[0-9]{2}" "$log" | tail -1)
        local last_status=$(tail -1 "$log")

        # A run only actually failed if it shows a ✘ marker, or a "N failed"
        # count where N > 0 -- the routine success summary always includes
        # "0 failed" as part of its normal wording, which isn't a failure.
        local status_color="$GREEN"
        if echo "$last_status" | grep -q "✘"; then
            status_color="$RED"
        else
            local fail_count=$(echo "$last_status" | grep -oE "[0-9]+ failed" | grep -oE "^[0-9]+")
            if [ -n "$fail_count" ] && [ "$fail_count" -gt 0 ]; then
                status_color="$RED"
            fi
        fi

        echo -e "  ${WHITE}${name}${RESET}"
        echo -e "    ${GRAY}Schedule:${RESET}  ${YELLOW}${schedule}${RESET}"

        if [ -n "$last_scheduled_line" ]; then
            local sched_date=$(echo "$last_scheduled_line" | awk '{print $2}')
            local sched_time=$(echo "$last_scheduled_line" | awk '{print $3}')
            if [ "$sched_date" = "$today" ]; then
                echo -e "  ${GREEN}✔${RESET}  ${GRAY}Last scheduled run:${RESET}  ${BLUE}${sched_date} ${sched_time}${RESET} ${GREEN}(today)${RESET}"
            else
                echo -e "  ${YELLOW}⚠${RESET}  ${GRAY}Last scheduled run:${RESET}  ${YELLOW}${sched_date} ${sched_time}${RESET} ${YELLOW}(not today -- automation hasn't fired yet)${RESET}"
            fi
        else
            echo -e "  ${YELLOW}⚠${RESET}  ${GRAY}Last scheduled run:${RESET}  ${YELLOW}never recorded${RESET}"
        fi

        if [ -n "$last_any_line" ]; then
            local any_date=$(echo "$last_any_line" | awk '{print $2}')
            local any_time=$(echo "$last_any_line" | awk '{print $3}')
            local any_tag=$(echo "$last_any_line" | grep -oE "\[manual\]|\[scheduled\]")
            echo -e "    ${GRAY}Last run (any):${RESET} ${BLUE}${any_date} ${any_time}${RESET} ${GRAY}${any_tag}${RESET}"
        fi

        echo -e "    ${GRAY}Status:${RESET}    ${status_color}${last_status}${RESET}"
    else
        echo -e "  ${YELLOW}◎${RESET} ${WHITE}${name}${RESET}"
        echo -e "    ${GRAY}Schedule:${RESET}  ${YELLOW}${schedule}${RESET}"
        echo -e "    ${GRAY}Status:${RESET}    ${GRAY}No logs yet${RESET}"
    fi
    echo ""
}

check_script "organise downloads" ~/.logs/organise_downloads.log "On login + every 4hrs while awake"
check_script "organise screenshots" ~/.logs/organise_screenshots.log "On login + every 4hrs while awake"
check_script "backup dotfiles" ~/.logs/backup_dotfiles.log "On login + every 4hrs while awake"

# ── Quick Actions ──
echo -e "${CYAN}${BOLD}  ── Quick Actions ───────────────────────────────────${RESET}"
echo ""
echo -e "  ${YELLOW}[1]${RESET} View Downloads log"
echo -e "  ${YELLOW}[2]${RESET} View Screenshots log"
echo -e "  ${YELLOW}[3]${RESET} View Dotfiles backup log"
echo -e "  ${YELLOW}[4]${RESET} Run Downloads organiser now"
echo -e "  ${YELLOW}[5]${RESET} Run Screenshots organiser now"
echo -e "  ${YELLOW}[6]${RESET} Run Dotfiles backup now"
echo -e "  ${YELLOW}[7]${RESET} Check system load"
echo -e "  ${YELLOW}[q]${RESET} Quit"
echo ""
echo -e "${GRAY}  ────────────────────────────────────────────────────${RESET}"
echo -e -n "  ${PURPLE}❯${RESET} Choose: "

read choice
echo ""

case $choice in
    1) bat ~/.logs/organise_downloads.log 2>/dev/null || cat ~/.logs/organise_downloads.log ;;
    2) bat ~/.logs/organise_screenshots.log 2>/dev/null || cat ~/.logs/organise_screenshots.log ;;
    3) bat ~/.logs/backup_dotfiles.log 2>/dev/null || cat ~/.logs/backup_dotfiles.log ;;
    4) bash ~/.organise_downloads.sh ;;
    5) bash ~/.organise_screenshots.sh ;;
    6) bash ~/.backup_dotfiles.sh ;;
    7) uptime && echo "" && top -l 1 | head -10 ;;
    q) echo -e "${GRAY}  Goodbye! 👋${RESET}" ;;
    *) echo -e "${RED}  Invalid choice${RESET}" ;;
esac
echo ""
