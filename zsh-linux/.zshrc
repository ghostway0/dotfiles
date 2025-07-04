export GPG_TTY=$(tty)

autoload -Uz compinit
compinit
# End of lines added by compinstall

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

PS1="%(?..[%?] )%1~ %# "

# bindkey '^F' forward-word
# bindkey '^B' backward-word

bindkey '^[F' forward-word
bindkey '^[B' backward-word

alias ls='eza -l'
alias hash_keystore='~/.cargo/bin/paq ~/.key-store'
alias rm='rm -I'

export ZIGUP_BASEDIR=/Users/ofek/.zigup
export PATH=/Users/ofek/.zigup/current:$PATH
export PATH=~/.local/bin/:$PATH
export EDITOR=nvim

source ~/.profile

git config --global alias.lola "log --graph --decorate --pretty=oneline --abbrev-commit --all"

autoload -U edit-command-line
zle -N edit-command-line

bindkey '^J' down-line-or-history
bindkey '^K' up-line-or-history

bindkey '^e' edit-command-line

bindkey '\ef' forward-word
bindkey '\eb' backward-word

bindkey '^R' history-incremental-search-backward

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
