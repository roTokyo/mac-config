# ========================================
# .zshrc di configurazione personalizzata
# ========================================

# -------- Storia dei comandi ----------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=2000
SAVEHIST=2000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt append_history
setopt share_history
setopt inc_append_history

# -------- Colori e Prompt ----------
setopt prompt_subst
autoload -U colors && colors

# -------- Funzione Git Ottimizzata ----------
git_branch_name() {
  # Usa git direttamente per estrarre il nome, più veloce di awk
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -n "$branch" ]] && echo "*$branch"
}

# -------- Prompt personalizzato (Pulito) ----------
# Ho rimosso i commenti su Nix per coerenza con la tua scelta
PROMPT='%F{red}%n@%m%f in %F{cyan}%2~ %F{yellow}$(git_branch_name)
%f><(((º> '

# -------- File aggiuntivi (se esistono) ----------
# ********** rBenv & Ruby
command -v rbenv >/dev/null && eval "$(rbenv init - zsh)"

# ********** NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"

# ********** Brew
eval "$(/usr/local/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

export PATH="/usr/local/opt/python@3.13/libexec/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
command -v go >/dev/null && export PATH="$PATH:$(go env GOPATH)/bin"

# ********** Aliases in uso **********

# Navigazione
alias ..='cd ..'
alias cls='clear'
alias reload='cls; source ~/.zshrc'

# ls
alias ls='ls -lah'

# DNS e cache
alias flush='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# File di sistema
alias dsclean='find . -type f -name .DS_Store -delete'
alias hosts='sudo nano /etc/hosts'

# Apache (gestione via Homebrew)
# alias ss='brew services start httpd'      # Start server
# alias qs='brew services stop httpd'       # Stop server
# alias rs='brew services restart httpd'    # Restart server
alias errlog='tail -f /usr/local/var/log/httpd/error_log'
alias check='sudo lsof -i:80'

# Mostra/nasconde file nascosti nel Finder
alias show='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hide='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

alias imgproc='$HOME/zsh_files/zz-imageForBlog_v0.03.zsh'

function exif() {
  exiftool -a -s -H -G1 -sort "$@"
}

function mt() {
  exiftool -sort "$@"
}

# -------- Info di sistema all’avvio ----------
echo -e "\033[0;39mKernel Information: \033[0;31m$(uname -smr)"
echo -e "\033[0;39mUptime: \033[0;31m$(uptime | sed 's/.*up *//; s/,.*//')"
echo -e "\033[0;39mServer time is: \033[0;31m$(date)"

# -------- Config Autosuggestions ----------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_MIN_SIZE=3
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=242"


[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

[ -r /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept
# Alt + Freccia Su per scorrere la cronologia del comando
bindkey '^[^[[A' history-search-backward
# Alt + Freccia Giù per scorrere la cronologia del comando
bindkey '^[^[[B' history-search-forward
