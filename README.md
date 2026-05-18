```
                                                             ______           ______ ______
                                                           / ____/________ _/ __/ //_  __/__  _________ ___ 
                                                          / /   / ___/ __ `/ /_/ __// / / _ \/ ___/ __ `__ \
                                                         / /___/ /  / /_/ / __/ /_ / / /  __/ /  / / / / / /
                                                          \____/_/   \__,_/_/  \__//_/  \___/_/  /_/ /_/ /_/

```

A fully custom, opinionated macOS terminal setup built by [Ebinezar Dhanaraj](https://github.com/ebiiscoding-del) — powerline prompt with 10 cycling colors, automation scripts, AI tools, git helpers, and more. All in one install.

---

# terminal-ebi-setup 🖥️

> Ebi's personal terminal setup for macOS — fast, beautiful, and on-brand.

## ⚡ One Command Install

```bash
git clone https://github.com/ebiiscoding-del/terminal-ebi-setup.git
cd terminal-ebi-setup
bash install.sh
```

---

## ✨ What's included

| Tool | Purpose |
|------|---------|
| **Zsh + Custom Prompt** | 10-color powerline prompt with git info |
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

## ⌨️ Commands

### Dashboard
```bash
dash              # Open terminal dashboard with script status & quick actions
```

### Dev Workflow
```bash
devstart          # Start Firebase + Zed + browser for current project
devstart /path    # Start dev environment for specific project
devstop           # Stop all dev services
```

### Git Workflow
```bash
gw                # Show git helper menu
gw c              # Quick commit + push (asks for message)
gw c "message"    # Quick commit with message
gw s              # AI generates commit message
gw b              # Branch helper (create/switch/delete)
```

### Game Mode
```bash
gameon            # Launch Steam
gameoff           # Kill Steam + Wine (free up CPU/RAM)
```

### Pomodoro Timer
```bash
pomo              # Start 50 min focus session
pomobreak         # Start 10 min break
```

### Terminal Shortcuts
```bash
lg                # Open lazygit (visual git UI)
?? "query"        # Ask GitHub Copilot for a command
help <cmd>        # Simple readable docs (tldr)
z <folder>        # Jump to any folder instantly
cat <file>        # Syntax highlighted file viewer (bat)
```

### System
```bash
uptime            # Check CPU load averages
btop              # Beautiful system monitor
ncdu ~            # Visual disk usage explorer
```

---

## 🤖 Automation Scripts

| Script | What it does | When | Log |
|--------|-------------|------|-----|
| `organise_downloads.sh` | Sorts Downloads by file type | Daily 8:00AM | `~/.logs/organise_downloads.log` |
| `organise_screenshots.sh` | Moves screenshots to Downloads/Screenshots | Daily 8:05AM | `~/.logs/organise_screenshots.log` |
| `backup_dotfiles.sh` | Backs up dotfiles to GitHub | Daily 8:10AM | `~/.logs/backup_dotfiles.log` |
| `dashboard.sh` | Terminal dashboard | Manual (`dash`) | — |
| `devstart.sh` | Start dev environment | Manual (`devstart`) | — |
| `devstop.sh` | Stop dev services | Manual (`devstop`) | — |
| `git_helper.sh` | Git workflow helper | Manual (`gw`) | — |
| `pomodoro.sh` | Pomodoro timer | Manual (`pomo`) | — |

### Check logs anytime:
```bash
cat ~/.logs/organise_downloads.log
cat ~/.logs/organise_screenshots.log
cat ~/.logs/backup_dotfiles.log
```

---

## 📁 Repo Structure

```
terminal-ebi-setup/
├── install.sh              # One-stop installer
├── README.md               # This file
├── dotfiles/               # Zsh, p10k, git configs + all scripts
├── fastfetch/              # Fastfetch config + TH3ERV logo
├── scripts/
│   ├── organise_downloads.sh
│   ├── organise_screenshots.sh
│   ├── backup_dotfiles.sh
│   ├── dashboard.sh
│   ├── devstart.sh
│   ├── devstop.sh
│   ├── git_helper.sh
│   └── pomodoro.sh
└── launchd/                # launchd agents for automation
```

---

## 🔧 Manual Install

### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install packages
```bash
brew install zsh eza zoxide fzf bat lazygit gh tldr fastfetch figlet lolcat btop git-delta onefetch ripgrep httpie zsh-autosuggestions zsh-syntax-highlighting
```

### 3. Install coloreza
```bash
git clone https://github.com/ebiiscoding-del/coloreza.git
cd coloreza && bash install.sh
```

### 4. Copy dotfiles
```bash
cp dotfiles/.zshrc ~/.zshrc
cp dotfiles/.gitconfig ~/.gitconfig
cp dotfiles/.custom_prompt.zsh ~/.custom_prompt.zsh
```

### 5. Set up fastfetch
```bash
mkdir -p ~/.config/fastfetch
cp fastfetch/* ~/.config/fastfetch/
```

### 6. Install scripts
```bash
for script in scripts/*.sh; do
  cp "$script" ~/."$(basename $script)"
  chmod +x ~/."$(basename $script)"
done
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
