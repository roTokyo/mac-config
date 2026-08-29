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
eval "$(rbenv init - zsh)"

# ********** NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"

# ********** Brew
eval "$(/usr/local/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=0
export HOMEBREW_NO_INSTALL_CLEANUP=1

# ********** Mac Port
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# ********** NOTE
#  inetutils has the following notes:
#    All clients are now installed with the "g" prefix. This means that you'll now, for example, find GNU telnet at
#    /opt/local/bin/gtelnet. If you dislike typing gtelnet, you can create a shell alias or you can add
#    /opt/local/libexec/gnubin to your PATH, wherein non-g* prefixed symlinks are installed. In other words,
#    /opt/local/libexec/gnubin contains GNU binaries without any prefix to the file names, so you can type telnet and
#    get GNU telnet just as before. The (g)whois client has been removed as it duplicates the separate whois port
export PATH="/opt/local/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/mozjpeg/bin:$PATH"

export PATH="/usr/local/opt/python@3.13/libexec/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"

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

alias imgproc='/Users/kazuro/zsh_files/zz-imageForBlog_v0.03.zsh'

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


. "$HOME/.local/bin/env"

source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept
# Alt + Freccia Su per scorrere la cronologia del comando
bindkey '^[^[[A' history-search-backward
# Alt + Freccia Giù per scorrere la cronologia del comando
bindkey '^[^[[B' history-search-forward

check_title() {

    if [ -z "$1" ]; then
        echo "Uso: check_title nome_immagine.jpg"
        return 1
    fi

    local file="$1"

    # Estrae il primo titolo valido trovato da ExifTool
    local titolo=$(exiftool -s3 -Title -ObjectName -ImageDescription "$file" 2>/dev/null | head -n 1)

    if [ -n "$titolo" ]; then

        echo "Presente: Sì"
        echo "Titolo attuale: $titolo"
        echo

        # Chiede all'utente se vuole cambiare il titolo
        printf "Vuoi cambiare il titolo? (s/n): "
        read -r risposta

        if [[ "$risposta" =~ ^[Ss]$ ]]; then

            printf "Inserisci il nuovo titolo (lascia VUOTO per cancellarlo): "
            read -r nuovo_titolo

            if [ -n "$nuovo_titolo" ]; then

                echo "Aggiornamento in corso..."

                exiftool -overwrite_original \
                        -Title="$nuovo_titolo" \
                        -ObjectName="$nuovo_titolo" \
                        -XMP-dc:Title="$nuovo_titolo" \
                        -ImageDescription="$nuovo_titolo" "$file"

                echo "Titolo aggiornato con successo!"

            else

                # Gestione della cancellazione completa
                printf "Hai lasciato il campo vuoto. Vuoi CANCELLARE definitivamente il titolo? (s/n): "
                read -r conferma_cancella

                if [[ "$conferma_cancella" =~ ^[Ss]$ ]]; then

                    echo "Rimozione del titolo in corso..."

                    exiftool -overwrite_original \
                            -Title= \
                            -ObjectName= \
                            -XMP-dc:Title= \
                            -ImageDescription= "$file"

                    echo "Titolo rimosso con successo!"

                else
                    echo "Operazione annullata: nessuna modifica effettuata."
                fi
            fi

        else
            echo "Operazione annullata: nessuna modifica effettuata."
        fi

    else

        echo "Presente: No"
        echo

        # Chiede se si vuole aggiungere un titolo
        printf "Vuoi aggiungere un titolo? (s/n): "
        read -r risposta

        if [[ "$risposta" =~ ^[Ss]$ ]]; then

            printf "Inserisci il titolo: "
            read -r nuovo_titolo

            if [ -n "$nuovo_titolo" ]; then

                echo "Aggiornamento in corso..."

                exiftool -overwrite_original \
                        -Title="$nuovo_titolo" \
                        -ObjectName="$nuovo_titolo" \
                        -XMP-dc:Title="$nuovo_titolo" \
                        -ImageDescription="$nuovo_titolo" "$file"

                echo "Titolo aggiunto con successo!"

            else
                echo "Nessun titolo inserito: nessuna modifica effettuata."
            fi

        else
            echo "Operazione annullata: nessuna modifica effettuata."
        fi

    fi
}
