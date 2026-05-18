#!/bin/bash

# ── Colors ──
RED='\033[38;5;196m'
GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
YELLOW='\033[38;5;226m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
RESET='\033[0m'

WORK_MINS=50
BREAK_MINS=10

notify() {
    local title="$1"
    local message="$2"
    local sound="$3"
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
}

countdown() {
    local total_secs=$1
    local label=$2
    local color=$3

    while [ $total_secs -gt 0 ]; do
        mins=$((total_secs / 60))
        secs=$((total_secs % 60))
        printf "\r  ${color}${label}${RESET} ${WHITE}%02d:%02d${RESET} remaining..." $mins $secs
        sleep 1
        ((total_secs--))
    done
    echo ""
}

pomo_work() {
    clear
    echo ""
    echo -e "${RED}  🍅 Pomodoro — Deep Work${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${WHITE}Focus for ${YELLOW}${WORK_MINS} minutes${RESET}. You got this! 💪"
    echo ""

    notify "🍅 Pomodoro Started" "Focus for ${WORK_MINS} minutes. No distractions!" "Glass"

    countdown $((WORK_MINS * 60)) "🍅 Work" $RED

    notify "✅ Pomodoro Done!" "Great work! Take a ${BREAK_MINS} minute break." "Hero"
    afplay /System/Library/Sounds/Hero.aiff 2>/dev/null

    echo ""
    echo -e "  ${GREEN}✔ Work session complete!${RESET}"
    echo -e "  ${GRAY}Take a ${BREAK_MINS} minute break. Run ${WHITE}pomobreak${RESET}${GRAY} when ready.${RESET}"
    echo ""
}

pomo_break() {
    clear
    echo ""
    echo -e "${GREEN}  ☕ Break Time!${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────${RESET}"
    echo ""
    echo -e "  ${WHITE}Rest for ${YELLOW}${BREAK_MINS} minutes${RESET}. Step away from the screen! 🌿"
    echo ""

    notify "☕ Break Time!" "Rest for ${BREAK_MINS} minutes. Step away!" "Glass"

    countdown $((BREAK_MINS * 60)) "☕ Break" $GREEN

    notify "🍅 Break Over!" "Time to get back to work!" "Hero"
    afplay /System/Library/Sounds/Hero.aiff 2>/dev/null

    echo ""
    echo -e "  ${RED}🍅 Break over!${RESET} ${WHITE}Run ${YELLOW}pomo${RESET}${WHITE} to start next session.${RESET}"
    echo ""
}

# ── Main ──
case "$1" in
    break)
        pomo_break
        ;;
    *)
        pomo_work
        ;;
esac
