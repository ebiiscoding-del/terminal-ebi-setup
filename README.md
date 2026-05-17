# terminal-ebi-setup 🖥️

> Ebi's personal terminal setup for macOS — fast, beautiful, and on-brand.

## ⚡ One Command Install

```bash
git clone https://github.com/ebiiscoding-del/terminal-ebi-setup.git
cd terminal-ebi-setup
bash install.sh
```

That's it! Everything is installed and configured automatically.

---

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
| **ripgrep** | Blazing fast search via `rg` |
| **httpie** | Beautiful API testing |
| **git-delta** | Beautiful git diffs |
| **onefetch** | Repo stats on `cd` into git folders |
| **ollama** | Run AI models locally on M1 |

---

## 🤖 Automation Scripts

| Script | What it does | When |
|--------|-------------|------|
| `organise_downloads.sh` | Sorts Downloads by file type | Daily 8:00AM |
| `organise_screenshots.sh` | Moves screenshots to Downloads/Screenshots | Daily 8:05AM |
| `backup_dotfiles.sh` | Backs up dotfiles to GitHub | Daily 8:10AM |
| `pomodoro.sh` | 50min work / 10min break timer | Manual |

### Manual script commands:
```bash
pomo          # Start 50 min focus session
pomobreak     # Start 10 min break
gameon        # Launch Steam
gameoff       # Kill Steam + Wine
??            # Ask GitHub Copilot for a command
```

---

## 📁 Repo Structure

```
terminal-ebi-setup/
├── install.sh          # One-stop installer
├── README.md           # This file
├── dotfiles/           # Zsh, p10k, git configs
├── fastfetch/          # Fastfetch config + TH3ERV logo
├── scripts/            # Automation scripts
└── launchd/            # launchd agents for automation
```

---

## 🔧 Manual Install

If you prefer to install manually:

### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install packages
```bash
brew install zsh eza zoxide fzf bat lazygit gh tldr fastfetch figlet lolcat btop git-delta onefetch ripgrep httpie zsh-autosuggestions zsh-syntax-highlighting powerlevel10k
```

### 3. Install coloreza
```bash
git clone https://github.com/ebiiscoding-del/coloreza.git
cd coloreza && bash install.sh
```

### 4. Copy dotfiles
```bash
cp dotfiles/.zshrc ~/.zshrc
cp dotfiles/.p10k.zsh ~/.p10k.zsh
cp dotfiles/.gitconfig ~/.gitconfig
```

### 5. Set up fastfetch
```bash
mkdir -p ~/.config/fastfetch
cp fastfetch/* ~/.config/fastfetch/
```

### 6. Install scripts
```bash
cp scripts/*.sh ~/.
chmod +x ~/.organise_downloads.sh ~/.organise_screenshots.sh ~/.backup_dotfiles.sh ~/.pomodoro.sh
```

### 7. Set up launchd
```bash
cp launchd/*.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.ebi.organise_downloads.plist
launchctl load ~/Library/LaunchAgents/com.ebi.organise_screenshots.plist
launchctl load ~/Library/LaunchAgents/com.ebi.backup_dotfiles.plist
```

### 8. Apply
```bash
source ~/.zshrc
```

---

## 📄 License
MIT © [Ebinezar Dhanaraj](https://github.com/ebiiscoding-del)
