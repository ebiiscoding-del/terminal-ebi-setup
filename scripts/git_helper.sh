#!/bin/bash

GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
YELLOW='\033[38;5;226m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
ARROW="${PURPLE}❯${RESET}"
CROSS="${RED}✘${RESET}"

# ── Check if in a git repo ──
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "\n  ${CROSS} ${RED}Not a git repository!${RESET}\n"
    exit 1
fi

BRANCH=$(git branch --show-current)

# ── Quick commit ──
gcommit() {
    echo ""
    echo -e "${PURPLE}  Quick Commit${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────${RESET}"
    echo ""

    # Show status
    echo -e "  ${ARROW} ${WHITE}Changes to commit:${RESET}"
    git status --short | while read line; do
        echo -e "  ${GRAY}$line${RESET}"
    done
    echo ""

    # Get commit message
    if [ -n "$1" ]; then
        MSG="$1"
    else
        echo -e -n "  ${ARROW} ${WHITE}Commit message: ${RESET}"
        read MSG
    fi

    if [ -z "$MSG" ]; then
        echo -e "  ${CROSS} ${RED}No commit message provided!${RESET}"
        exit 1
    fi

    # Stage, commit, push
    git add .
    echo -e "  ${CHECK} ${GREEN}Staged all changes${RESET}"

    git commit -m "$MSG"
    echo -e "  ${CHECK} ${GREEN}Committed:${RESET} ${YELLOW}$MSG${RESET}"

    git push
    echo -e "  ${CHECK} ${GREEN}Pushed to${RESET} ${BLUE}origin/$BRANCH${RESET}"

    echo ""
    echo -e "${GRAY}  ────────────────────────────────────${RESET}"
    echo -e "  ${CHECK} ${GREEN}Done!${RESET} 🚀"
    echo ""
}

# ── Smart commit (AI generated message) ──
gsmart() {
    echo ""
    echo -e "${PURPLE}  Smart Commit (AI)${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────${RESET}"
    echo ""

    # Get diff
    DIFF=$(git diff --staged 2>/dev/null)
    if [ -z "$DIFF" ]; then
        git add .
        DIFF=$(git diff --staged)
    fi

    if [ -z "$DIFF" ]; then
        echo -e "  ${CROSS} ${RED}No changes to commit!${RESET}"
        exit 1
    fi

    echo -e "  ${ARROW} ${WHITE}Generating commit message with AI...${RESET}"

    # Use gh copilot to generate message
    MSG=$(echo "Generate a concise git commit message for these changes: $DIFF" | gh copilot -p "Generate a short conventional git commit message (max 72 chars) for these changes. Reply with ONLY the commit message, nothing else: $(git diff --stat)" 2>/dev/null | head -1)

    if [ -z "$MSG" ]; then
        echo -e "  ${CROSS} ${RED}AI failed, please enter manually:${RESET}"
        echo -e -n "  ${ARROW} ${WHITE}Commit message: ${RESET}"
        read MSG
    fi

    echo ""
    echo -e "  ${ARROW} ${YELLOW}Suggested:${RESET} $MSG"
    echo -e -n "  ${ARROW} ${WHITE}Use this? (y/n/edit): ${RESET}"
    read CONFIRM

    if [ "$CONFIRM" = "n" ]; then
        echo -e -n "  ${ARROW} ${WHITE}Enter your message: ${RESET}"
        read MSG
    elif [ "$CONFIRM" = "edit" ]; then
        echo -e -n "  ${ARROW} ${WHITE}Edit message: ${RESET}"
        read -e -i "$MSG" MSG
    fi

    git add .
    git commit -m "$MSG"
    git push
    echo ""
    echo -e "  ${CHECK} ${GREEN}Committed & pushed:${RESET} ${YELLOW}$MSG${RESET}"
    echo ""
}

# ── Branch helper ──
gbranch() {
    echo ""
    echo -e "${PURPLE}  Branch Helper${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────${RESET}"
    echo ""
    echo -e "  Current branch: ${BLUE}$BRANCH${RESET}"
    echo ""
    echo -e "  ${ARROW} What do you want to do?"
    echo -e "  ${GRAY}1)${RESET} Create new branch"
    echo -e "  ${GRAY}2)${RESET} Switch branch"
    echo -e "  ${GRAY}3)${RESET} Delete branch"
    echo -e "  ${GRAY}4)${RESET} List all branches"
    echo ""
    echo -e -n "  ${ARROW} ${WHITE}Choice (1-4): ${RESET}"
    read CHOICE

    case $CHOICE in
        1)
            echo -e -n "  ${ARROW} ${WHITE}Branch name: ${RESET}"
            read BNAME
            git checkout -b "$BNAME"
            echo -e "  ${CHECK} ${GREEN}Created and switched to:${RESET} ${BLUE}$BNAME${RESET}"
            ;;
        2)
            echo -e "\n  ${ARROW} ${WHITE}Available branches:${RESET}"
            git branch | while read b; do echo -e "  ${GRAY}$b${RESET}"; done
            echo ""
            echo -e -n "  ${ARROW} ${WHITE}Switch to: ${RESET}"
            read BNAME
            git checkout "$BNAME"
            echo -e "  ${CHECK} ${GREEN}Switched to:${RESET} ${BLUE}$BNAME${RESET}"
            ;;
        3)
            echo -e "\n  ${ARROW} ${WHITE}Available branches:${RESET}"
            git branch | while read b; do echo -e "  ${GRAY}$b${RESET}"; done
            echo ""
            echo -e -n "  ${ARROW} ${WHITE}Delete branch: ${RESET}"
            read BNAME
            git branch -d "$BNAME"
            echo -e "  ${CHECK} ${GREEN}Deleted:${RESET} ${RED}$BNAME${RESET}"
            ;;
        4)
            echo ""
            git branch -a | while read b; do echo -e "  ${GRAY}$b${RESET}"; done
            echo ""
            ;;
    esac
    echo ""
}

# ── Main ──
case "$1" in
    commit|c)
        gcommit "$2"
        ;;
    smart|s)
        gsmart
        ;;
    branch|b)
        gbranch
        ;;
    *)
        echo ""
        echo -e "${PURPLE}  Git Helper${RESET}"
        echo -e "${GRAY}  ────────────────────────────────────${RESET}"
        echo ""
        echo -e "  ${ARROW} ${YELLOW}gw commit${RESET} ${GRAY}or${RESET} ${YELLOW}gw c${RESET}        Quick commit + push"
        echo -e "  ${ARROW} ${YELLOW}gw commit \"msg\"${RESET}          Commit with message"
        echo -e "  ${ARROW} ${YELLOW}gw smart${RESET}  ${GRAY}or${RESET} ${YELLOW}gw s${RESET}        AI generated commit"
        echo -e "  ${ARROW} ${YELLOW}gw branch${RESET} ${GRAY}or${RESET} ${YELLOW}gw b${RESET}        Branch helper"
        echo ""
        ;;
esac
