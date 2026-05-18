#!/bin/bash

GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
ARROW="${PURPLE}❯${RESET}"

DESKTOP=~/Desktop
SCREENSHOTS_DIR=~/Downloads/Screenshots
LOG_FILE=~/.logs/organise_screenshots.log
mkdir -p ~/.logs

echo "" >> $LOG_FILE
echo "── $(date '+%Y-%m-%d %H:%M:%S') ──────────────────────" >> $LOG_FILE
echo "Starting Screenshots Organiser" >> $LOG_FILE

echo ""
echo -e "${PURPLE}  Screenshot Organiser${RESET}"
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo ""

moved=0

for file in "$DESKTOP"/*; do
    [ -d "$file" ] && continue
    filename=$(basename "$file")
    ext="${filename##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    date_created=$(date -r "$file" +"%Y-%m-%d")
    year=$(echo $date_created | cut -d'-' -f1)
    month=$(echo $date_created | cut -d'-' -f2)
    day=$(echo $date_created | cut -d'-' -f3)

    if [[ "$filename" == Screen\ Shot* ]] || [[ "$filename" == Screenshot* ]]; then
        type="Screenshots"
    elif [ "$ext" = "mov" ] || [ "$ext" = "mp4" ]; then
        type="Recordings"
    else
        continue
    fi

    target_dir="$SCREENSHOTS_DIR/$year/$month/$day/$type"
    mkdir -p "$target_dir"
    mv "$file" "$target_dir/$filename" 2>/dev/null
    echo -e "  ${CHECK} ${GREEN}$filename${RESET} ${GRAY}→${RESET} ${BLUE}$year/$month/$day/$type/${RESET}"
    echo "  ✔ $filename → $year/$month/$day/$type/" >> $LOG_FILE
    ((moved++))
done

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Done!${RESET} Organised ${BLUE}$moved${RESET} screenshots"
echo "Done: organised $moved screenshots" >> $LOG_FILE
echo ""
