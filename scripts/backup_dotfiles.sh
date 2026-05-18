#!/bin/bash

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
LOG_FILE=~/.logs/backup_dotfiles.log
mkdir -p ~/.logs

echo "" >> $LOG_FILE
echo "── $(date '+%Y-%m-%d %H:%M:%S') ──────────────────────" >> $LOG_FILE
echo "Starting Dotfiles Backup" >> $LOG_FILE

echo ""
echo -e "${PURPLE}  Dotfiles Backup${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

mkdir -p "$DOTFILES_DIR"

declare -a FILES=(
    "$HOME/.zshrc"
    "$HOME/.p10k.zsh"
    "$HOME/.gitconfig"
    "$HOME/.coloreza.py"
    "$HOME/.organise_downloads.sh"
    "$HOME/.organise_screenshots.sh"
    "$HOME/.backup_dotfiles.sh"
    "$HOME/.devstart.sh"
    "$HOME/.devstop.sh"
    "$HOME/.git_helper.sh"
    "$HOME/.pomodoro.sh"
    "$HOME/.custom_prompt.zsh"
)

copied=0

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$DOTFILES_DIR/"
        filename=$(basename "$file")
        echo -e "  ${CHECK} ${GREEN}$filename${RESET} ${GRAY}backed up${RESET}"
        echo "  ✔ $filename backed up" >> $LOG_FILE
        ((copied++))
    else
        filename=$(basename "$file")
        echo -e "  ${CROSS} ${GRAY}$filename not found, skipping${RESET}"
        echo "  ✘ $filename not found" >> $LOG_FILE
    fi
done

echo ""
echo -e "${ARROW} ${BLUE}Pushing to GitHub...${RESET}"
echo "Pushing to GitHub..." >> $LOG_FILE

cd "$REPO"
if [ -n "$(git status --porcelain)" ]; then
    git add dotfiles/
    git commit -m "Auto backup: dotfiles $(date '+%Y-%m-%d %H:%M')"
    git push
    echo -e "  ${CHECK} ${GREEN}Pushed to GitHub!${RESET}"
    echo "Pushed to GitHub successfully" >> $LOG_FILE
else
    echo -e "  ${CHECK} ${GRAY}No changes — already up to date${RESET}"
    echo "No changes to push" >> $LOG_FILE
fi

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Done!${RESET} Backed up ${BLUE}$copied${RESET} dotfiles"
echo "Done: backed up $copied dotfiles" >> $LOG_FILE
echo ""
