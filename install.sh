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

echo -e "${ARROW} ${WHITE}Checking dependencies...${RESET}"
echo ""

# ── Check Homebrew ──
if ! command -v brew &>/dev/null; then
    echo -e "  ${ARROW} ${YELLOW}Installing Homebrew...${RESET}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "  ${CHECK} ${GREEN}Homebrew${RESET} already installed"
fi

echo ""
echo -e "${ARROW} ${WHITE}Installing packages...${RESET}"
echo ""

# ── Install packages ──
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
        brew install "$pkg" &>/dev/null
        echo -e "  ${CHECK} ${GREEN}$pkg${RESET} installed"
    fi
done

echo ""
echo -e "${ARROW} ${WHITE}Installing coloreza...${RESET}"
echo ""

# ── Install coloreza ──
if [ ! -f ~/.coloreza.py ]; then
    git clone https://github.com/ebiiscoding-del/coloreza.git /tmp/coloreza &>/dev/null
    cp /tmp/coloreza/coloreza.py ~/.coloreza.py
    chmod +x ~/.coloreza.py
    rm -rf /tmp/coloreza
    echo -e "  ${CHECK} ${GREEN}coloreza${RESET} installed"
else
    echo -e "  ${CHECK} ${GREEN}coloreza${RESET} already installed"
fi

echo ""
echo -e "${ARROW} ${WHITE}Copying dotfiles...${RESET}"
echo ""

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Copy dotfiles ──
DOTFILES=(
    ".zshrc"
    ".p10k.zsh"
    ".gitconfig"
)

for file in "${DOTFILES[@]}"; do
    if [ -f "$REPO_DIR/dotfiles/$file" ]; then
        cp "$REPO_DIR/dotfiles/$file" ~/$file
        echo -e "  ${CHECK} ${GREEN}$file${RESET} copied"
    else
        echo -e "  ${CROSS} ${GRAY}$file not found, skipping${RESET}"
    fi
done

echo ""
echo -e "${ARROW} ${WHITE}Setting up fastfetch...${RESET}"
echo ""

# ── Fastfetch config ──
mkdir -p ~/.config/fastfetch
if [ -f "$REPO_DIR/fastfetch/config.jsonc" ]; then
    cp "$REPO_DIR/fastfetch/config.jsonc" ~/.config/fastfetch/
    cp "$REPO_DIR/fastfetch/combined_logo.txt" ~/.config/fastfetch/
    cp "$REPO_DIR/fastfetch/theerv.txt" ~/.config/fastfetch/
    echo -e "  ${CHECK} ${GREEN}fastfetch${RESET} configured"
fi

echo ""
echo -e "${ARROW} ${WHITE}Installing scripts...${RESET}"
echo ""

# ── Copy scripts ──
SCRIPTS=(
    "organise_downloads.sh"
    "organise_screenshots.sh"
    "backup_dotfiles.sh"
    "pomodoro.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$REPO_DIR/scripts/$script" ]; then
        cp "$REPO_DIR/scripts/$script" ~/.$script
        chmod +x ~/.$script
        echo -e "  ${CHECK} ${GREEN}$script${RESET} installed"
    fi
done

echo ""
echo -e "${ARROW} ${WHITE}Setting up launchd agents...${RESET}"
echo ""

# ── Launchd agents ──
mkdir -p ~/Library/LaunchAgents

for plist in "$REPO_DIR"/launchd/*.plist; do
    filename=$(basename "$plist")
    cp "$plist" ~/Library/LaunchAgents/
    launchctl load ~/Library/LaunchAgents/$filename 2>/dev/null
    echo -e "  ${CHECK} ${GREEN}$filename${RESET} loaded"
done

echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${CHECK} ${GREEN}All done!${RESET} 🎉"
echo ""
echo -e "  ${WHITE}Run the following to apply:${RESET}"
echo ""
echo -e "  ${CYAN}source ~/.zshrc${RESET}"
echo ""
echo -e "  ${GRAY}Enjoy your new terminal! 🚀${RESET}"
echo ""
