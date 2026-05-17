#!/bin/bash

# ── Colors ──
GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
ARROW="${PURPLE}❯${RESET}"

DOWNLOADS=~/Downloads

echo ""
echo -e "${PURPLE}  Downloads Organiser${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

# ── Folder to extension mapping ──
declare -A FOLDERS
FOLDERS["Images"]="jpg jpeg png gif svg webp ico bmp tiff heic"
FOLDERS["Videos"]="mp4 mov avi mkv wmv flv m4v webm"
FOLDERS["Music"]="mp3 wav flac m4a aac ogg wma"
FOLDERS["Documents"]="pdf docx doc txt md xlsx xls pptx ppt pages numbers key"
FOLDERS["Archives"]="zip tar gz rar dmg pkg iso 7z"
FOLDERS["Apps"]="app"
FOLDERS["Code"]="js ts py sh zsh bash json yaml yml toml html css scss"

# ── Create directories ──
for folder in "${!FOLDERS[@]}"; do
  mkdir -p "$DOWNLOADS/$folder"
done
mkdir -p "$DOWNLOADS/Other"

moved=0
skipped=0

# ── Move files ──
for file in "$DOWNLOADS"/*; do
  [ -d "$file" ] && continue

  filename=$(basename "$file")
  ext="${filename##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  moved_flag=false

  for folder in "${!FOLDERS[@]}"; do
    for e in ${FOLDERS[$folder]}; do
      if [ "$ext" = "$e" ]; then
        mv "$file" "$DOWNLOADS/$folder/$filename" 2>/dev/null
        echo -e "  ${CHECK} ${GREEN}$filename${RESET} ${GRAY}→${RESET} ${BLUE}$folder/${RESET}"
        ((moved++))
        moved_flag=true
        break 2
      fi
    done
  done

  if [ "$moved_flag" = false ]; then
    mv "$file" "$DOWNLOADS/Other/$filename" 2>/dev/null
    echo -e "  ${ARROW} ${GRAY}$filename → Other/${RESET}"
    ((skipped++))
  fi
done

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Done!${RESET} Moved ${BLUE}$moved${RESET} files, ${GRAY}$skipped${RESET} to Other/"
echo ""
