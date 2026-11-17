eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(mise activate zsh)"

# zshrc
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
	docker
	kubectx
	kubectl
	gh
	fzf
	z
	zsh-syntax-highlighting
	zsh-autosuggestions
	zsh-interactive-cd
)

source $ZSH/oh-my-zsh.sh
source ~/.aliases.zsh

if [[ -f ~/.local_exports.sh ]]; then
	source ~/.local_exports.sh
fi

# Custom completions directory - must be before oh-my-zsh compinit
fpath=(~/.zsh/completions $fpath)

export PAGER=cat

unsetopt BEEP


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

HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

# Change comment style from dark blue to green
#ZSH_HIGHLIGHT_STYLES[comment]=fg=green,bold
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#555555'

if [ $(uname) = "Darwin" ]; then
	ZSH_HIGHLIGHT_STYLES[comment]=fg=green,bold
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#a8a8a6'
fi
#
# Other exports
export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/tools"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
export SHELL="/bin/zsh"

export PATH="$PATH:$HOME/.bun/bin"
export BUILDX_EXPERIMENTAL=1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
# aikido-endpoint-cert-config-start
# Allow Node.js tooling to trust the SafeChain MITM CA while preserving public roots.
export NODE_EXTRA_CA_CERTS="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-node-combined-ca.pem"
case "${NODE_OPTIONS:-}" in
  *--use-openssl-ca*) unset NODE_USE_SYSTEM_CA ;;
  *) export NODE_USE_SYSTEM_CA=1 ;;
esac
# aikido-endpoint-cert-config-end
# aikido-endpoint-pip-cert-config-start
# Allow Python package managers to trust the SafeChain MITM CA while preserving user-provided roots.
export PIP_CERT="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
export REQUESTS_CA_BUNDLE="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
export POETRY_CERTIFICATES_PYPI_CERT="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
export UV_SYSTEM_CERTS=true
# aikido-endpoint-pip-cert-config-end
# aikido-endpoint-ruby-cert-config-start
# Allow Ruby Bundler to trust the SafeChain MITM CA while preserving public roots.
export BUNDLE_SSL_CA_CERT="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-ruby-combined-ca.pem"
# aikido-endpoint-ruby-cert-config-end
# aikido-endpoint-curl-cert-config-v2-start
# Allow curl and other OpenSSL-linked tools to trust the SafeChain MITM CA while preserving the system roots.
export SSL_CERT_FILE="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-openssl-combined-ca.pem"
export CURL_CA_BUNDLE="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-openssl-combined-ca.pem"
# aikido-endpoint-curl-cert-config-v2-end
