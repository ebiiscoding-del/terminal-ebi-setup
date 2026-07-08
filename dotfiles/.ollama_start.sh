#!/bin/bash

GREEN='\033[38;5;114m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
RESET='\033[0m'

echo ""
echo -e "${PURPLE}  Starting Ollama...${RESET}"

# Fix missing wezterm completions warning
rm -f /opt/homebrew/share/zsh/site-functions/_wezterm 2>/dev/null

# Start ollama in background
ollama serve > ~/.logs/ollama.log 2>&1 &
OLLAMA_PID=$!

# Wait for it to be ready
sleep 3

# Check if running
if curl -s http://localhost:11434 > /dev/null 2>&1; then
    echo -e "  ${GREEN}✔ Ollama is running${RESET} ${GRAY}(PID: $OLLAMA_PID)${RESET}"
    echo -e "  ${GRAY}Models available:${RESET}"
    ollama list | tail -n +2 | while read line; do
        echo -e "  ${PURPLE}❯${RESET} $line"
    done
else
    echo -e "  ${GREEN}✔ Ollama started${RESET} ${GRAY}(PID: $OLLAMA_PID)${RESET}"
fi
echo ""
