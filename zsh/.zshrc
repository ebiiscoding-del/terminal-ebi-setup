fastfetch

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- Eza (better ls) -----
function ls() {
  script -q /dev/null eza -TL 5 --icons --color=always --group-directories-first "$@" | python3 ~/.eza_color.py
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