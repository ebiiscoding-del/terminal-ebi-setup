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

PROJECT_DIR="${1:-$(pwd)}"
PORT=5002

clear
echo ""
echo -e "${PURPLE}  Dev Environment Starter${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""
echo -e "  ${ARROW} ${WHITE}Project:${RESET} ${BLUE}$PROJECT_DIR${RESET}"
echo ""

# Check project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "  ${RED}✘ Directory not found: $PROJECT_DIR${RESET}"
    exit 1
fi

# Check for firebase.json or package.json
HAS_FIREBASE=false
HAS_NPM=false

if [ -f "$PROJECT_DIR/firebase.json" ]; then
    HAS_FIREBASE=true
    echo -e "  ${CHECK} ${GREEN}Firebase project detected${RESET}"
fi

if [ -f "$PROJECT_DIR/package.json" ]; then
    HAS_NPM=true
    echo -e "  ${CHECK} ${GREEN}Node.js project detected${RESET}"
fi

if [ "$HAS_FIREBASE" = false ] && [ "$HAS_NPM" = false ]; then
    echo -e "  ${RED}✘ No firebase.json or package.json found${RESET}"
    exit 1
fi

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

# Escape path for osascript
ESCAPED_DIR=$(printf '%s' "$PROJECT_DIR" | sed "s/'/'\\\\''/g")

# Start Firebase emulators
if [ "$HAS_FIREBASE" = true ]; then
    echo -e "  ${ARROW} ${WHITE}Starting Firebase emulators...${RESET}"
    osascript -e "tell application \"Terminal\" to do script \"cd '$ESCAPED_DIR' && firebase emulators:start\""
    echo -e "  ${CHECK} ${GREEN}Firebase emulators starting${RESET}"
fi

# Start npm dev server
if [ "$HAS_NPM" = true ]; then
    sleep 1
    echo -e "  ${ARROW} ${WHITE}Starting dev server...${RESET}"
    osascript -e "tell application \"Terminal\" to do script \"cd '$ESCAPED_DIR' && npm run dev\""
    echo -e "  ${CHECK} ${GREEN}Dev server starting${RESET}"
fi

# Open Zed
sleep 1
echo -e "  ${ARROW} ${WHITE}Opening Zed...${RESET}"
open -a Zed "$PROJECT_DIR"
echo -e "  ${CHECK} ${GREEN}Zed opened${RESET}"

# Open browser
sleep 4
echo -e "  ${ARROW} ${WHITE}Opening browser...${RESET}"
open "http://127.0.0.1:$PORT"
echo -e "  ${CHECK} ${GREEN}Browser opened${RESET} ${GRAY}→${RESET} ${BLUE}http://127.0.0.1:$PORT${RESET}"

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Dev environment ready!${RESET} 🚀"
echo ""
echo -e "  ${GRAY}To stop everything run:${RESET} ${WHITE}devstop${RESET}"
echo ""
