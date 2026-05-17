# terminal-ebi-setup 🖥️

> My personal terminal setup for macOS — fast, beautiful, and on-brand.

## ✨ What's included

| Tool | Purpose |
|------|---------|
| **Zsh + Powerlevel10k** | Shell + beautiful two-line prompt |
| **fastfetch** | System info with custom TH3ERV logo on launch |
| **coloreza** | Colored icons by file type with white filenames |
| **zsh-autosuggestions** | Ghost text completions |
| **zsh-syntax-highlighting** | Colorful command highlighting |
| **eza** | Better `ls` with tree view and icons |
| **zoxide** | Smart `cd` that learns your dirs |
| **fzf** | Fuzzy search — `Ctrl+R` for history |
| **bat** | Syntax highlighted `cat` |
| **lazygit** | Visual git UI via `lg` |
| **gh + gh copilot** | GitHub CLI + AI in terminal |
| **tldr** | Simple readable docs via `help` |
| **btop** | Beautiful system monitor |
| **figlet + lolcat** | Rainbow ASCII art |

## 🚀 Quick Install

### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install dependencies
```bash
brew install zsh eza zoxide fzf bat lazygit gh tldr fastfetch figlet lolcat btop git-delta onefetch
brew install zsh-autosuggestions zsh-syntax-highlighting
brew install --cask iterm2
```

### 3. Install Powerlevel10k
```bash
brew install powerlevel10k
```

### 4. Install coloreza
```bash
git clone https://github.com/ebiiscoding-del/coloreza.git
cd coloreza && bash install.sh
```

### 5. Copy config files
```bash
# zsh
cp zsh/.zshrc ~/.zshrc
cp zsh/.p10k.zsh ~/.p10k.zsh

# fastfetch
mkdir -p ~/.config/fastfetch
cp fastfetch/config.jsonc ~/.config/fastfetch/
cp fastfetch/combined_logo.txt ~/.config/fastfetch/
cp fastfetch/theerv.txt ~/.config/fastfetch/
```

### 6. Apply
```bash
source ~/.zshrc
```

## 📄 License
MIT © Ebinezar Dhanaraj
