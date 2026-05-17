#!/bin/bash

# ── Colors ──
GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
RED='\033[38;5;196m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
CROSS="${RED}✘${RESET}"
ARROW="${PURPLE}❯${RESET}"

REPO=~/Documents/Ebi\'s\ Workspace/terminal-ebi-setup
DOTFILES_DIR=$REPO/dotfiles

echo ""
echo -e "${PURPLE}  Dotfiles Backup${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

# ── Create dotfiles directory ──
mkdir -p "$DOTFILES_DIR"

# ── Files to backup ──
declare -a FILES=(
    "$HOME/.zshrc"
    "$HOME/.p10k.zsh"
    "$HOME/.gitconfig"
    "$HOME/.coloreza.py"
    "$HOME/.organise_downloads.sh"
    "$HOME/.organise_screenshots.sh"
)

copied=0

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$DOTFILES_DIR/"
        filename=$(basename "$file")
        echo -e "  ${CHECK} ${GREEN}$filename${RESET} ${GRAY}backed up${RESET}"
        ((copied++))
    else
        filename=$(basename "$file")
        echo -e "  ${CROSS} ${GRAY}$filename not found, skipping${RESET}"
    fi
done

echo ""
echo -e "${ARROW} ${BLUE}Pushing to GitHub...${RESET}"
echo ""

# ── Git commit and push ──
cd "$REPO"

if [ -n "$(git status --porcelain)" ]; then
    git add dotfiles/
    git commit -m "Auto backup: dotfiles $(date '+%Y-%m-%d %H:%M')"
    git push
    echo ""
    echo -e "  ${CHECK} ${GREEN}Pushed to GitHub!${RESET}"
else
    echo -e "  ${CHECK} ${GRAY}No changes — dotfiles already up to date${RESET}"
fi

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Done!${RESET} Backed up ${BLUE}$copied${RESET} dotfiles"
echo ""
