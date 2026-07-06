figlet -f slant "CraftTerm" | while IFS= read -r line; do
  padding=$(( (COLUMNS - ${#line}) / 2 ))
  printf "%${padding}s%s\n" "" "$line"
done | lolcat --freq 0.2 --seed 40
fastfetch

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#env secrets
[ -f ~/.env.secrets ] && source ~/.env.secrets


# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

ZSH_AUTOSUGGEST_USE_ASYNC=0
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- Eza (better ls) -----
function ls() {
  script -q /dev/null eza -TL 5 --icons --color=always --group-directories-first "$@" | python3 ~/.coloreza.py
}

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PATH="$HOME/.nvm/versions/node/v22.16.0/lib/node_modules/@webos-tools/cli/bin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$HOME/.local/bin:$PATH"

(( ! ${+functions[p10k]} )) || p10k finalize

# ── fzf ──
eval "$(fzf --zsh)"

# ── bat (better cat) ──
alias cat="bat"
alias bat="bat --theme=Dracula"

# ── lazygit ──
alias lg="lazygit"

# ── tldr ──
alias help="tldr"

# Show repo info when entering a git project
function cd() {
  z "$@" && if git rev-parse --git-dir > /dev/null 2>&1; then
    onefetch
  fi
}

# ── eza colors ──
export EZA_COLORS="\
di=38;5;141:\
ln=38;5;212:\
ex=38;5;84:\
fi=2:\
*.js=38;5;220:\
*.ts=38;5;39:\
*.json=38;5;196:\
*.md=38;5;117:\
*.html=38;5;208:\
*.css=38;5;171:\
*.env=38;5;196:\
*.sh=38;5;114:\
*.png=38;5;213:\
*.jpg=38;5;213:\
*.svg=38;5;213:\
*.zip=38;5;227:\
*.gitignore=38;5;242:"

# ── GitHub Copilot CLI ──
alias '??'='gh copilot -p'
alias 'git?'='gh copilot -p "git command to"'

# ── httpie ──
alias api="http"

# ── Game Mode ──
function gameon() {
  echo "🎮 Starting Steam..."
  open -a Steam
  echo "✔ Steam launched! Have fun!"
}

function gameoff() {
  echo "🎮 Shutting down game mode..."
  launchctl remove com.valvesoftware.steam.ipctool 2>/dev/null
  pkill -9 -f "Steam.AppBundle" 2>/dev/null
  pkill -9 -f "ipcserver" 2>/dev/null
  pkill -9 -f "wine" 2>/dev/null
  pkill -9 -f "winedevice" 2>/dev/null
  echo "✔ Steam and Wine killed! Your Mac is free!"
  uptime
}

# ── Pomodoro ──
alias pomo='bash ~/.pomodoro.sh'
alias pomobreak='bash ~/.pomodoro.sh break'

# ── Dev Environment ──
alias devstart='bash ~/.devstart.sh'
alias devstop='bash ~/.devstop.sh'

# ── Git Helper ──
alias gw='bash ~/.git_helper.sh'

# ── List Applications ──
alias apps="eza -TL 1 /Applications"

# ── Custom colored path prompt ──
source ~/.custom_prompt.zsh

# ── Dashboard ──
alias dash='bash ~/.dashboard.sh'

# -- Ollama --
alias ollamastart='bash ~/.ollama_start.sh'
alias ollamastop='pkill ollama'

# -- Tandem --
alias killtandem='kill -9 $(lsof -ti :1420) 2>/dev/null; kill -9 $(lsof -ti :1421) 2>/dev/null'
alias tandemclean='kill -9 $(lsof -tiTCP:1420) 2>/dev/null; kill -9 $(lsof -tiTCP:1421) 2>/dev/null; pkill -f vite 2>/dev/null'
alias tandemclean='kill -9 $(lsof -tiTCP:1420) 2>/dev/null; kill -9 $(lsof -tiTCP:1421) 2>/dev/null; pkill -f vite 2>/dev/null; pkill -f "cargo  run" 2>/dev/null; pkill -f "cargo run" 2>/dev/null; pkill -f "target/debug/tandem" 2>/dev/null; pkill -f "caffeinate -i" 2>/dev/null; pkill -f "caffeinate -i -w" 2>/dev/null'

# -- Ranger --
alias ranger='ranger --choosedir=$HOME/.rangerdir; cd "$(cat $HOME/.rangerdir)"'


# ------------------------------------------------------------------------------------------------------------------------


# ThoughtForge — extract blueprint-drop.zip and deploy to project
thoughtforge-deploy() {
  local BASE=~/Documents/Ebi-Workspace/craftlane/web-apps/thoughtforge
  local DL=~/Downloads
  local ZIP="$DL/blueprint-drop.zip"
  local EXTRACT_DIR="$DL/blueprint-drop"

  local -A FILES=(
    # Service TASK files
    document-service-TASK.md   services/document-service/TASK.md
    character-service-TASK.md  services/character-service/TASK.md
    project-service-TASK.md    services/project-service/TASK.md
    agent-service-TASK.md      services/agent-service/TASK.md
    search-service-TASK.md     services/search-service/TASK.md
    assistant-service-TASK.md  services/assistant-service/TASK.md
    frontend-TASK.md           frontend/TASK.md
    flutter-app-TASK.md        flutter-app/TASK.md
    # Root-level docs
    BLUEPRINT_LOG.md           BLUEPRINT_LOG.md
    AGENTS.md                  AGENTS.md
    CLAUDE.md                  CLAUDE.md
    AI_WORKFLOW.md             AI_WORKFLOW.md
    AI_INDEX.md                AI_INDEX.md
    AI_INDEX_PATCH.md          AI_INDEX_PATCH.md
    SECURITY_REPORT.md         SECURITY_REPORT.md
    README.md                  README.md
  )

  local PURPLE='\033[0;35m'
  local CYAN='\033[0;36m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[0;33m'
  local RED='\033[0;31m'
  local DIM='\033[2m'
  local BOLD='\033[1m'
  local RESET='\033[0m'

  _div()  { printf "  ${DIM}────────────────────────────────────────${RESET}\n"; }
  _hdiv() { printf "  ${DIM}════════════════════════════════════════${RESET}\n"; }

  # Inline spinner — runs command directly, no background job, no zsh noise
  _spin() {
    local msg="$1"; shift
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    "$@" &
    local pid=$!
    while kill -0 $pid 2>/dev/null; do
      printf "\r  ${CYAN}${frames[$((i % 10))]}${RESET}  ${DIM}${msg}${RESET}"
      ((i++))
      sleep 0.08
    done
    wait $pid 2>/dev/null
    printf "\r\033[K"
  }

  [[ -n "$1" ]] && ZIP="$1"

  echo ""
  _hdiv
  printf "  ${BOLD}${PURPLE}🏗  Mr. Blueprint's Deploy Pipeline${RESET}\n"
  _hdiv
  echo ""

  # Extract
  if [[ -f "$ZIP" ]]; then
    _spin "Unrolling blueprints..." unzip -o "$ZIP" -d "$EXTRACT_DIR" > /dev/null 2>&1
    printf "  ${GREEN}▸${RESET}  Blueprints unrolled\n"
  else
    printf "  ${YELLOW}▸${RESET}  No zip — checking Downloads for loose files\n"
    EXTRACT_DIR="$DL"
  fi

  # Deliver
  echo ""
  _div
  printf "  ${BOLD}${CYAN}📬  Delivering to the crew${RESET}\n"
  _div
  echo ""

  local moved=0 skipped=0
  local -a staged=()

  for src dest in ${(kv)FILES}; do
    if [[ -f "$EXTRACT_DIR/$src" ]]; then
      # Ensure destination directory exists (handles new dirs like flutter-app/)
      mkdir -p "$BASE/$(dirname "$dest")" 2>/dev/null
      cp "$EXTRACT_DIR/$src" "$BASE/$dest" 2>/dev/null
      if [[ $? -eq 0 ]]; then
        printf "  ${GREEN}✦${RESET}  ${BOLD}%-36s${RESET}  ${DIM}→ %s${RESET}\n" "$src" "$dest"
        staged+=("$dest")
        ((moved++))
        rm -f "$EXTRACT_DIR/$src" 2>/dev/null
      else
        printf "  ${RED}✗${RESET}  ${BOLD}%-36s${RESET}  ${RED}copy failed${RESET}\n" "$src"
      fi
    else
      printf "  ${DIM}◌  %-36s not in the bag${RESET}\n" "$src"
      ((skipped++))
    fi
  done

  echo ""
  _div
  printf "  ${GREEN}✦ %d delivered${RESET}   ${DIM}◌ %d skipped${RESET}\n" $moved $skipped
  _div
  echo ""

  # Cleanup
  printf "  ${BOLD}${PURPLE}🧹  Shredding the evidence${RESET}\n"
  echo ""

  local cleaned=0
  if [[ -d "$EXTRACT_DIR" && "$EXTRACT_DIR" != "$DL" ]]; then
    rm -rf "$EXTRACT_DIR" 2>/dev/null
    printf "  ${GREEN}✦${RESET}  ${DIM}Extracted folder — gone${RESET}\n"
    ((cleaned++))
  fi
  if [[ -f "$ZIP" ]]; then
    rm -f "$ZIP" 2>/dev/null
    printf "  ${GREEN}✦${RESET}  ${DIM}blueprint-drop.zip — gone${RESET}\n"
    ((cleaned++))
  fi
  for src in ${(k)FILES}; do
    if [[ -f "$DL/$src" ]]; then
      rm -f "$DL/$src" 2>/dev/null
      printf "  ${GREEN}✦${RESET}  ${DIM}${src} — gone${RESET}\n"
      ((cleaned++))
    fi
  done
  [[ $cleaned -eq 0 ]] && printf "  ${DIM}◌  Nothing to clean${RESET}\n"

  # Git push
  if [[ ${#staged[@]} -gt 0 ]]; then
    echo ""
    _div
    printf "  ${BOLD}${CYAN}🚀  Sending to the repo${RESET}\n"
    _div
    echo ""

    _spin "Staging..." git -C "$BASE" add "${staged[@]}" > /dev/null 2>&1
    printf "  ${GREEN}✦${RESET}  ${DIM}Staged${RESET}\n"

    _spin "Committing..." git -C "$BASE" commit -m "🤖 Mr. Blueprint dropped the blueprints. The crew has their orders." > /dev/null 2>&1
    printf "  ${GREEN}✦${RESET}  ${DIM}Committed${RESET}\n"

    _spin "Pushing to main..." git -C "$BASE" push origin main > /dev/null 2>&1
    local push_status=$?

    if [[ $push_status -eq 0 ]]; then
      printf "  ${GREEN}✦${RESET}  ${DIM}Pushed to main${RESET}\n"
      echo ""
      _hdiv
      printf "  ${BOLD}${GREEN}🎯  The crew has their orders. Go build, Ebi.${RESET}\n"
      _hdiv
    else
      printf "  ${RED}✗  Push failed — check the repo${RESET}\n"
    fi
  else
    echo ""
    printf "  ${DIM}◌  Nothing staged — no push needed${RESET}\n"
  fi

  echo ""
}


# ------------------------------------------------------------------------------------------------------------------------

# Generic git add/commit/push — run from any repo directory
gp() {
  local PURPLE='\033[0;35m'
  local CYAN='\033[0;36m'
  local GREEN='\033[0;32m'
  local RED='\033[0;31m'
  local DIM='\033[2m'
  local BOLD='\033[1m'
  local RESET='\033[0m'

  _div()  { printf "  ${DIM}────────────────────────────────────────${RESET}\n"; }
  _hdiv() { printf "  ${DIM}════════════════════════════════════════${RESET}\n"; }

  _spin() {
    local msg="$1"; shift
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    "$@" &
    local pid=$!
    while kill -0 $pid 2>/dev/null; do
      printf "\r  ${CYAN}${frames[$((i % 10))]}${RESET}  ${DIM}${msg}${RESET}"
      ((i++))
      sleep 0.08
    done
    wait $pid 2>/dev/null
    printf "\r\033[K"
  }

  # Check for changes
  if [[ -z "$(git status --porcelain)" ]]; then
    echo ""
    printf "  ${DIM}◌  Nothing to commit — working tree clean${RESET}\n"
    echo ""
    return 0
  fi

  echo ""
  _hdiv
  printf "  ${BOLD}${CYAN}⬆  Git Push${RESET}   ${DIM}$(git branch --show-current)${RESET}\n"
  _hdiv
  echo ""

  # Show changes
  printf "  ${BOLD}Changes:${RESET}\n"
  git status --porcelain | sed 's/^/    /'
  echo ""
  _div
  echo ""

  # Commit message — blank defaults to "✦ update"
  printf "  ${BOLD}Commit message${RESET} ${DIM}(blank = \"✦ update\")${RESET}:\n  ❯ "
  read -r MSG
  [[ -z "$MSG" ]] && MSG="✦ update"

  echo ""

  _spin "Staging..." git add -A
  printf "  ${GREEN}✦${RESET}  ${DIM}Staged. Mr. Repository is paying attention.${RESET}\n"

  _spin "Committing..." git commit -m "$MSG"
  printf "  ${GREEN}✦${RESET}  ${DIM}Committed: \"$MSG\"${RESET}\n"

  _spin "Pushing to main..." git push origin "$(git branch --show-current)"
  local push_status=$?

  if [[ $push_status -eq 0 ]]; then
    printf "  ${GREEN}✦${RESET}  ${DIM}Pushed to main. Mr. Repository caught it.${RESET}\n"
    echo ""
    _hdiv
    printf "  ${BOLD}${GREEN}🎯  Shipped. The repo has it. You can breathe now.${RESET}\n"
    _hdiv
  else
    printf "  ${RED}✗  Push failed — check the repo${RESET}\n"
  fi

  echo ""
}


# ------------------------------------------------------------------------------------------------------------------------



# nthtaste — extract nthtaste-drop.zip and deploy to project
nthtaste-deploy() {
  local BASE=~/workshop/"Nth Taste"/app-merged/app
  local DL=~/Downloads
  local ZIP="$DL/Nthtaste.zip"
  local EXTRACT_DIR="$DL/Nthtaste"

  local PURPLE='\033[0;35m'
  local CYAN='\033[0;36m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[0;33m'
  local RED='\033[0;31m'
  local DIM='\033[2m'
  local BOLD='\033[1m'
  local RESET='\033[0m'

  _div()  { printf "  ${DIM}────────────────────────────────────────${RESET}\n"; }
  _hdiv() { printf "  ${DIM}════════════════════════════════════════${RESET}\n"; }

  _spin() {
    local msg="$1"; shift
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    "$@" &
    local pid=$!
    while kill -0 $pid 2>/dev/null; do
      printf "\r  ${CYAN}${frames[$((i % 10))]}${RESET}  ${DIM}${msg}${RESET}"
      ((i++))
      sleep 0.08
    done
    wait $pid 2>/dev/null
    printf "\r\033[K"
  }

  echo ""
  _hdiv
  printf "  ${BOLD}${PURPLE}🥙  Nth Taste Deploy Pipeline${RESET}\n"
  _hdiv
  echo ""

  if [[ ! -f "$ZIP" ]]; then
    printf "  ${RED}✗  No Nthtaste.zip found in Downloads${RESET}\n"
    printf "  ${DIM}◌  Zip up your files with the destination folder structure inside, name it Nthtaste.zip, drop it in ~/Downloads${RESET}\n"
    echo ""
    return 1
  fi

  _spin "Unwrapping the drop..." unzip -o "$ZIP" -d "$EXTRACT_DIR" > /dev/null 2>&1
  printf "  ${GREEN}▸${RESET}  Drop unwrapped\n"

  # If the zip contained a single top-level folder matching its own name, flatten one level
  if [[ -d "$EXTRACT_DIR/Nthtaste" ]]; then
    EXTRACT_DIR="$EXTRACT_DIR/Nthtaste"
  fi

  echo ""
  _div
  printf "  ${BOLD}${CYAN}📬  Mirroring into the repo${RESET}\n"
  _div
  echo ""

  local moved=0
  local -a staged=()

  while IFS= read -r -d '' file; do
    local rel="${file#$EXTRACT_DIR/}"
    mkdir -p "$BASE/$(dirname "$rel")" 2>/dev/null
    cp "$file" "$BASE/$rel" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      printf "  ${GREEN}✦${RESET}  ${BOLD}%-40s${RESET}\n" "$rel"
      staged+=("$rel")
      ((moved++))
    else
      printf "  ${RED}✗${RESET}  ${BOLD}%-40s${RESET}  ${RED}copy failed${RESET}\n" "$rel"
    fi
  done < <(find "$EXTRACT_DIR" -type f -print0)

  echo ""
  _div
  printf "  ${GREEN}✦ %d delivered${RESET}\n" $moved
  _div
  echo ""

  # Cleanup — remove the zip and extracted folder
  printf "  ${BOLD}${PURPLE}🧹  Clearing the counter${RESET}\n"
  echo ""
  rm -rf "$DL/Nthtaste" 2>/dev/null
  printf "  ${GREEN}✦${RESET}  ${DIM}Extracted folder — gone${RESET}\n"
  rm -f "$ZIP" 2>/dev/null
  printf "  ${GREEN}✦${RESET}  ${DIM}Nthtaste.zip — gone${RESET}\n"

  # Git push
  if [[ ${#staged[@]} -gt 0 ]]; then
    echo ""
    _div
    printf "  ${BOLD}${CYAN}🚀  Sending to the repo${RESET}\n"
    _div
    echo ""

    _spin "Staging..." git -C "$BASE" add "${staged[@]}" > /dev/null 2>&1
    printf "  ${GREEN}✦${RESET}  ${DIM}Staged${RESET}\n"

    _spin "Committing..." git -C "$BASE" commit -m "🥙 Architect dropped specs. The crew has their orders." > /dev/null 2>&1
    printf "  ${GREEN}✦${RESET}  ${DIM}Committed${RESET}\n"

    _spin "Pushing to main..." git -C "$BASE" push origin main > /dev/null 2>&1
    local push_status=$?

    if [[ $push_status -eq 0 ]]; then
      printf "  ${GREEN}✦${RESET}  ${DIM}Pushed to main${RESET}\n"
      echo ""
      _hdiv
      printf "  ${BOLD}${GREEN}🎯  The crew has their orders. Go build, Ebi.${RESET}\n"
      _hdiv
    else
      printf "  ${RED}✗  Push failed — check the repo${RESET}\n"
    fi
  else
    echo ""
    printf "  ${DIM}◌  Nothing staged — no push needed${RESET}\n"
  fi

  echo ""
}