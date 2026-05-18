#!/bin/bash

GREEN='\033[38;5;114m'
RED='\033[38;5;196m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
ARROW="${PURPLE}❯${RESET}"

echo ""
echo -e "${RED}  Dev Environment Stopping...${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

# Kill dev server
pkill -f "npm run dev" 2>/dev/null
pkill -f "npm start" 2>/dev/null
pkill -f "node" 2>/dev/null
echo -e "  ${CHECK} ${GREEN}Dev server stopped${RESET}"

# Kill Firebase emulators
pkill -f "firebase" 2>/dev/null
pkill -f "java" 2>/dev/null
echo -e "  ${CHECK} ${GREEN}Firebase emulators stopped${RESET}"

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}All services stopped!${RESET}"
echo ""
