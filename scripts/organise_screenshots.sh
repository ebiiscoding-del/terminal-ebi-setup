#!/bin/bash

# ── Colors ──
GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
ARROW="${PURPLE}❯${RESET}"

DESKTOP=~/Desktop
SCREENSHOTS_DIR=~/Downloads/Screenshots

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

    # Get file creation date
    date_created=$(GetFileInfo -d "$file" 2>/dev/null | awk '{print $1}' | tr '/' '-')
    if [ -z "$date_created" ]; then
        date_created=$(date -r "$file" +"%Y-%m-%d")
    fi

    year=$(echo $date_created | cut -d'-' -f1)
    month=$(echo $date_created | cut -d'-' -f2)
    day=$(echo $date_created | cut -d'-' -f3)

    # Determine type
    if [[ "$filename" == Screen\ Shot* ]] || [[ "$filename" == Screenshot* ]]; then
        type="Screenshots"
    elif [ "$ext" = "mov" ] || [ "$ext" = "mp4" ]; then
        type="Recordings"
    else
        continue  # Skip non-screenshot files
    fi

    # Create folder structure
    target_dir="$SCREENSHOTS_DIR/$year/$month/$day/$type"
    mkdir -p "$target_dir"

    # Move file
    mv "$file" "$target_dir/$filename" 2>/dev/null
    echo -e "  ${CHECK} ${GREEN}$filename${RESET} ${GRAY}→${RESET} ${BLUE}$year/$month/$day/$type/${RESET}"
    ((moved++))
done

echo ""
echo -e "${GRAY}  ────────────────────────────────────${RESET}"
echo -e "  ${CHECK} ${GREEN}Done!${RESET} Organised ${BLUE}$moved${RESET} screenshots"
echo ""
