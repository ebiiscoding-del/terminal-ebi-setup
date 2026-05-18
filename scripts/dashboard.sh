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

    if [ -f "$log" ]; then
        last_run=$(grep "──" "$log" | tail -1 | awk '{print $2, $3}')
        last_status=$(tail -1 "$log")
        echo -e "  ${GREEN}✔${RESET} ${WHITE}${name}${RESET}"
        echo -e "    ${GRAY}Schedule:${RESET}  ${YELLOW}${schedule}${RESET}"
        echo -e "    ${GRAY}Last run:${RESET}  ${BLUE}${last_run}${RESET}"
        echo -e "    ${GRAY}Status:${RESET}    ${GREEN}${last_status}${RESET}"
    else
        echo -e "  ${YELLOW}◎${RESET} ${WHITE}${name}${RESET}"
        echo -e "    ${GRAY}Schedule:${RESET}  ${YELLOW}${schedule}${RESET}"
        echo -e "    ${GRAY}Status:${RESET}    ${GRAY}No logs yet${RESET}"
    fi
    echo ""
}

check_script "organise downloads" ~/.logs/organise_downloads.log "Daily 8:00AM"
check_script "organise screenshots" ~/.logs/organise_screenshots.log "Daily 8:05AM"
check_script "backup dotfiles" ~/.logs/backup_dotfiles.log "Daily 8:10AM"

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
