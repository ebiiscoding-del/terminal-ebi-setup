#!/bin/bash

shopt -s nullglob

GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
RED='\033[38;5;196m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
CROSS="${RED}✘${RESET}"
ARROW="${PURPLE}❯${RESET}"

DOWNLOADS=~/Downloads
LOG_FILE=~/.logs/organise_downloads.log
mkdir -p ~/.logs

RUN_TAG="[manual]"
if [ "$1" = "--scheduled" ]; then
    RUN_TAG="[scheduled]"
fi

echo "" >> $LOG_FILE
echo "── $(date '+%Y-%m-%d %H:%M:%S') ${RUN_TAG} ──────────────────────" >> $LOG_FILE
echo "Starting Downloads Organiser" >> $LOG_FILE

echo ""
echo -e "${PURPLE}  Downloads Organiser${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

FOLDER_NAMES="Images Videos Music Documents Archives Apps Code"

folder_for_ext() {
  case "$1" in
    jpg|jpeg|png|gif|svg|webp|ico|bmp|tiff|heic) echo "Images" ;;
    mp4|mov|avi|mkv|wmv|flv|m4v|webm) echo "Videos" ;;
    mp3|wav|flac|m4a|aac|ogg|wma) echo "Music" ;;
    pdf|docx|doc|txt|md|xlsx|xls|pptx|ppt|pages|numbers|key) echo "Documents" ;;
    zip|tar|gz|rar|dmg|pkg|iso|7z) echo "Archives" ;;
    app) echo "Apps" ;;
    js|ts|py|sh|zsh|bash|json|yaml|yml|toml|html|css|scss) echo "Code" ;;
    *) echo "" ;;
  esac
}

for folder in $FOLDER_NAMES; do
  mkdir -p "$DOWNLOADS/$folder"
done
mkdir -p "$DOWNLOADS/Other"

moved=0
skipped=0
failed=0

for file in "$DOWNLOADS"/*; do
  [ -d "$file" ] && continue
  filename=$(basename "$file")
  ext="${filename##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  folder=$(folder_for_ext "$ext")
  if [ -n "$folder" ]; then
    if mv "$file" "$DOWNLOADS/$folder/$filename" 2>>"$LOG_FILE"; then
      echo -e "  ${CHECK} ${GREEN}$filename${RESET} ${GRAY}→${RESET} ${BLUE}$folder/${RESET}"
      echo "  ✔ $filename → $folder/" >> $LOG_FILE
      ((moved++))
    else
      echo -e "  ${CROSS} ${RED}$filename${RESET} ${GRAY}failed to move to $folder/${RESET}"
      echo "  ✘ $filename failed to move to $folder/" >> $LOG_FILE
      ((failed++))
    fi
  else
    if mv "$file" "$DOWNLOADS/Other/$filename" 2>>"$LOG_FILE"; then
      echo -e "  ${ARROW} ${GRAY}$filename → Other/${RESET}"
      echo "  → $filename → Other/" >> $LOG_FILE
      ((skipped++))
    else
      echo -e "  ${CROSS} ${RED}$filename${RESET} ${GRAY}failed to move to Other/${RESET}"
      echo "  ✘ $filename failed to move to Other/" >> $LOG_FILE
      ((failed++))
    fi
  fi
done

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Done!${RESET} Moved ${BLUE}$moved${RESET} files, ${GRAY}$skipped${RESET} to Other/, ${RED}$failed${RESET} failed"
echo "Done: moved $moved files, $skipped to Other/, $failed failed" >> $LOG_FILE
echo ""