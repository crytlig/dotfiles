# zshrc
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
	git
	docker
	kubectx
	kubectl
	gh
	fzf
	z
	zsh-syntax-highlighting
	zsh-autosuggestions
	zsh-interactive-cd
	zsh-fzf-history-search
	vscode
)

source $ZSH/oh-my-zsh.sh
# source ~/.openai
source ~/.aliases.zsh

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit
unsetopt BEEP

export PAGER=cat

# End of lines added by compinstall
#
VSCODE=code-insiders
# For a full list of active aliases, run `alias`.
alias lg=lazygit
alias nv=nvim
alias k=kubectl
alias tf=terraform
alias conf="nvim ~/.zshrc"
alias kns='kubens'
alias ktx='kubectx'

# Make fzf default to ripgrep
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m'
fi


# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

#complete -F __start_terraform tf
#complete -F __start_kubectl k

# Change comment style from dark blue to green
#ZSH_HIGHLIGHT_STYLES[comment]=fg=green,bold
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#555555'


if [ $(uname) = "Darwin" ]; then
	ZSH_HIGHLIGHT_STYLES[comment]=fg=green,bold
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#a8a8a6'
fi


pm() {
  if [[ $# -gt 0 ]]; then
    cd "$(pathmarks guess "$1")"
    return
  fi

  local p
  p="$(pathmarks pick)"
  if [[ -n "$p" ]]; then cd "$p"; fi
}

alias pms="pathmarks save"

# Completion: suggest names from `pathmarks list`
_pm() {
  compadd -- $(pathmarks list)
}
compdef _pm pm

# Other exports
export EDITOR=nvim

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/tools"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
## WSL
# export PATH=$PATH:"/mnt/c/Users/ClaesRytlig/AppData/Local/Programs/Microsoft VS Code/bin"
# export PATH=$PATH:"/mnt/c/Windows/System32"
#
export BUILDX_EXPERIMENTAL=1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U +X bashcompinit && bashcompinit

eval "$(starship init zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
