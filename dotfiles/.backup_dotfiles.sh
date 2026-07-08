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

REPO="$HOME/terminal-ebi-setup"
DOTFILES_DIR=$REPO/dotfiles
LOG_FILE=~/.logs/backup_dotfiles.log
mkdir -p ~/.logs

RUN_TAG="[manual]"
if [ "$1" = "--scheduled" ]; then
    RUN_TAG="[scheduled]"
fi

echo "" >> $LOG_FILE
echo "── $(date '+%Y-%m-%d %H:%M:%S') ${RUN_TAG} ──────────────────────" >> $LOG_FILE
echo "Starting Dotfiles Backup" >> $LOG_FILE

echo ""
echo -e "${PURPLE}  Dotfiles Backup${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

if [ ! -d "$REPO/.git" ]; then
    echo -e "  ${CROSS} ${RED}REPO not found or not a git repo: $REPO${RESET}"
    echo "  ✘ REPO not found or not a git repo: $REPO" >> $LOG_FILE
    exit 1
fi

mkdir -p "$DOTFILES_DIR"

# Dynamically discover what to back up from what's tracked in the repo,
# instead of a hardcoded list — a hardcoded list is exactly what caused
# dashboard.sh, ollama_start.sh, and screenshot_viewer.py to silently
# never get backed up.
declare -a FILES=()

_already_listed() {
    local needle="$1"
    for x in "${FILES[@]}"; do
        [[ "$x" == "$needle" ]] && return 0
    done
    return 1
}

for f in "$REPO"/dotfiles/.*; do
    fname=$(basename "$f")
    [[ "$fname" == "." || "$fname" == ".." ]] && continue
    [[ -f "$f" ]] || continue
    target="$HOME/$fname"
    [[ -f "$target" ]] || continue
    _already_listed "$target" || FILES+=("$target")
done

for f in "$REPO"/scripts/*.sh "$REPO"/scripts/*.py; do
    [[ -f "$f" ]] || continue
    fname=".$(basename "$f")"
    target="$HOME/$fname"
    [[ -f "$target" ]] || continue
    _already_listed "$target" || FILES+=("$target")
done

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

cd "$REPO" || { echo -e "  ${CROSS} ${RED}Could not cd into $REPO${RESET}"; echo "  ✘ Could not cd into $REPO" >> $LOG_FILE; exit 1; }

STATUS=$(git status --porcelain 2>&1)
GIT_STATUS_RC=$?

if [ $GIT_STATUS_RC -ne 0 ]; then
    echo -e "  ${CROSS} ${RED}git status failed: $STATUS${RESET}"
    echo "  ✘ git status failed: $STATUS" >> $LOG_FILE
    exit 1
elif [ -n "$STATUS" ]; then
    git add dotfiles/
    git commit -m "Auto backup: dotfiles $(date '+%Y-%m-%d %H:%M')"
    if git push; then
        echo -e "  ${CHECK} ${GREEN}Pushed to GitHub!${RESET}"
        echo "Pushed to GitHub successfully" >> $LOG_FILE
    else
        echo -e "  ${CROSS} ${RED}git push failed${RESET}"
        echo "  ✘ git push failed" >> $LOG_FILE
        exit 1
    fi
else
    echo -e "  ${CHECK} ${GRAY}No changes — already up to date${RESET}"
    echo "No changes to push" >> $LOG_FILE
fi

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Done!${RESET} Backed up ${BLUE}$copied${RESET} dotfiles"
echo "Done: backed up $copied dotfiles" >> $LOG_FILE
echo ""