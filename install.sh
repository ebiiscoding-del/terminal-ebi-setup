#!/bin/bash

# ── Colors ──
RED='\033[38;5;196m'
GREEN='\033[38;5;114m'
BLUE='\033[38;5;39m'
PURPLE='\033[38;5;141m'
YELLOW='\033[38;5;226m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
CROSS="${RED}✘${RESET}"
ARROW="${PURPLE}❯${RESET}"

FAILURES=()

# ── Header ──
clear
echo ""
echo -e "${PURPLE}  ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗      ${RESET}"
echo -e "${BLUE}  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║      ${RESET}"
echo -e "${PURPLE}     ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║      ${RESET}"
echo -e "${BLUE}     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║      ${RESET}"
echo -e "${PURPLE}     ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗ ${RESET}"
echo -e "${GRAY}     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝ ${RESET}"
echo ""
echo -e "${GRAY}  Ebi's Terminal Setup — One command to rule them all${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────${RESET}"
echo ""

# ── Check macOS ──
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "  ${CROSS} ${RED}This script is for macOS only!${RESET}"
    exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${ARROW} ${WHITE}Checking dependencies...${RESET}"
echo ""

# ── Check / install Homebrew ──
if ! command -v brew &>/dev/null; then
    echo -e "  ${ARROW} ${YELLOW}Installing Homebrew...${RESET}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # A fresh Homebrew install doesn't add itself to PATH for the rest of THIS
    # script — without this, every brew command below would silently fail.
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew &>/dev/null; then
        echo -e "  ${CROSS} ${RED}Homebrew install failed or still isn't on PATH. Stopping here —${RESET}"
        echo -e "      ${RED}nothing below this will work without it.${RESET}"
        exit 1
    fi
    echo -e "  ${CHECK} ${GREEN}Homebrew${RESET} installed"
else
    echo -e "  ${CHECK} ${GREEN}Homebrew${RESET} already installed"
fi

echo ""
echo -e "${ARROW} ${WHITE}Installing packages...${RESET}"
echo ""

# ── Install packages (with real error checking — no more silent failures) ──
PACKAGES=(
    "zsh"
    "eza"
    "zoxide"
    "fzf"
    "bat"
    "lazygit"
    "gh"
    "tldr"
    "fastfetch"
    "figlet"
    "lolcat"
    "btop"
    "git-delta"
    "onefetch"
    "ripgrep"
    "httpie"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "powerlevel10k"
)

for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        echo -e "  ${CHECK} ${GREEN}$pkg${RESET} ${GRAY}already installed${RESET}"
    else
        echo -e "  ${ARROW} ${YELLOW}Installing $pkg...${RESET}"
        if brew install "$pkg" &>/tmp/brew_install_err.log; then
            echo -e "  ${CHECK} ${GREEN}$pkg${RESET} installed"
        else
            echo -e "  ${CROSS} ${RED}$pkg${RESET} failed to install — see /tmp/brew_install_err.log"
            FAILURES+=("package: $pkg")
        fi
    fi
done

echo ""
echo -e "${ARROW} ${WHITE}Installing Nerd Font (for powerline icons/arrows)...${RESET}"
echo ""

# ── Nerd Font (this was never automated before — had to be done by hand every time) ──
if brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
    echo -e "  ${CHECK} ${GREEN}MesloLGS Nerd Font${RESET} ${GRAY}already installed${RESET}"
else
    if brew install --cask font-meslo-lg-nerd-font &>/tmp/brew_font_err.log; then
        echo -e "  ${CHECK} ${GREEN}MesloLGS Nerd Font${RESET} installed"
        echo -e "      ${GRAY}Set it in Terminal → Settings → Profiles → Text → Font${RESET}"
    else
        echo -e "  ${CROSS} ${RED}Font install failed${RESET} — see /tmp/brew_font_err.log"
        FAILURES+=("Nerd Font")
    fi
fi

echo ""
echo -e "${ARROW} ${WHITE}Copying dotfiles...${RESET}"
echo ""

# ── Copy dotfiles — every file in dotfiles/, dynamically. ──
# No more hand-maintained list that silently drops new files (this is exactly
# what caused .custom_prompt.zsh and others to go missing on fresh installs).
# Files that are actually script backups (refreshed daily by backup_dotfiles.sh)
# are skipped here since the scripts/ loop below handles those authoritatively.
if [ -d "$REPO_DIR/dotfiles" ]; then
    for filepath in "$REPO_DIR"/dotfiles/.* "$REPO_DIR"/dotfiles/*; do
        filename="$(basename "$filepath")"
        [[ "$filename" == "." || "$filename" == ".." ]] && continue
        [[ -f "$filepath" ]] || continue
        if [ -f "$REPO_DIR/scripts/${filename#.}" ]; then
            continue
        fi
        if cp "$filepath" "$HOME/$filename"; then
            echo -e "  ${CHECK} ${GREEN}$filename${RESET} copied"
        else
            echo -e "  ${CROSS} ${RED}$filename${RESET} failed to copy"
            FAILURES+=("dotfile: $filename")
        fi
    done
else
    echo -e "  ${CROSS} ${RED}dotfiles/ folder not found in repo${RESET}"
    FAILURES+=("dotfiles/ folder missing")
fi

echo ""
echo -e "${ARROW} ${WHITE}Setting up fastfetch...${RESET}"
echo ""

# ── Fastfetch config ──
mkdir -p ~/.config/fastfetch
if [ -f "$REPO_DIR/fastfetch/config.jsonc" ]; then
    cp "$REPO_DIR/fastfetch/config.jsonc" ~/.config/fastfetch/
    cp "$REPO_DIR/fastfetch/combined_logo.txt" ~/.config/fastfetch/ 2>/dev/null
    cp "$REPO_DIR/fastfetch/theerv.txt" ~/.config/fastfetch/ 2>/dev/null
    echo -e "  ${CHECK} ${GREEN}fastfetch${RESET} configured"
else
    echo -e "  ${CROSS} ${RED}fastfetch config not found in repo${RESET}"
    FAILURES+=("fastfetch config")
fi

echo ""
echo -e "${ARROW} ${WHITE}Installing scripts...${RESET}"
echo ""

# ── Copy scripts — every .sh and .py in scripts/, dynamically. ──
# Same fix as dotfiles: this used to be a hardcoded list that missed
# dashboard.sh and ollama_start.sh entirely.
if [ -d "$REPO_DIR/scripts" ]; then
    for filepath in "$REPO_DIR"/scripts/*.sh "$REPO_DIR"/scripts/*.py; do
        [[ -f "$filepath" ]] || continue
        script="$(basename "$filepath")"
        if cp "$filepath" ~/."$script"; then
            chmod +x ~/."$script"
            echo -e "  ${CHECK} ${GREEN}$script${RESET} installed"
        else
            echo -e "  ${CROSS} ${RED}$script${RESET} failed to install"
            FAILURES+=("script: $script")
        fi
    done
else
    echo -e "  ${CROSS} ${RED}scripts/ folder not found in repo${RESET}"
    FAILURES+=("scripts/ folder missing")
fi

echo ""
echo -e "${ARROW} ${WHITE}Setting up launchd agents...${RESET}"
echo ""

# ── Launchd agents — templated at install time, no hardcoded username ──
# The committed plists use a __HOME__ placeholder instead of a real path,
# specifically so this never has to be manually fixed again after a rename
# or on a different machine.
mkdir -p ~/Library/LaunchAgents

if [ -d "$REPO_DIR/launchd" ]; then
    for plist in "$REPO_DIR"/launchd/*.plist; do
        [[ -f "$plist" ]] || continue
        filename=$(basename "$plist")
        dest=~/Library/LaunchAgents/$filename

        launchctl unload "$dest" 2>/dev/null

        sed "s|__HOME__|$HOME|g" "$plist" > "$dest"

        if launchctl load "$dest" 2>/tmp/launchd_err.log; then
            echo -e "  ${CHECK} ${GREEN}$filename${RESET} loaded"
        else
            echo -e "  ${CROSS} ${RED}$filename${RESET} failed to load — see /tmp/launchd_err.log"
            FAILURES+=("launchd: $filename")
        fi
    done
else
    echo -e "  ${CROSS} ${RED}launchd/ folder not found in repo${RESET}"
    FAILURES+=("launchd/ folder missing")
fi

echo ""
echo -e "${ARROW} ${WHITE}Suppressing the default login message...${RESET}"
echo ""

# ── Hush the default "Last login: ..." line so the custom greeting shows instead ──
touch ~/.hushlogin
echo -e "  ${CHECK} ${GREEN}.hushlogin${RESET} created"

echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────${RESET}"
echo ""

if [ ${#FAILURES[@]} -eq 0 ]; then
    echo -e "  ${CHECK} ${GREEN}All done!${RESET} 🎉"
else
    echo -e "  ${YELLOW}Finished with ${#FAILURES[@]} issue(s):${RESET}"
    for f in "${FAILURES[@]}"; do
        echo -e "    ${CROSS} ${RED}$f${RESET}"
    done
fi

echo ""
echo -e "  ${WHITE}Run the following to apply:${RESET}"
echo ""
echo -e "  ${BLUE}source ~/.zshrc${RESET}"
echo ""
echo -e "  ${GRAY}Enjoy your new terminal! 🚀${RESET}"
echo ""
