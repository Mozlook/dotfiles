# ~/.zshrc — managed by dotfiles

# --- history -----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt inc_append_history share_history hist_ignore_all_dups hist_ignore_space
setopt autocd extended_glob interactive_comments

# --- completion --------------------------------------------------------------
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zcompdump"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

# --- plugins (installed via pacman) -----------------------------------------
src() { [ -f "$1" ] && source "$1"; }
src /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
src /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

# --- keybinds ----------------------------------------------------------------
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# --- aliases -----------------------------------------------------------------
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias tree='eza --tree --icons'
alias cat='bat --paging=never'
alias vim='nvim'
alias vi='nvim'
alias grep='grep --color=auto'
alias theme='wallpaper-picker'
alias ff='fastfetch'

# --- tools -------------------------------------------------------------------
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v atuin    >/dev/null && eval "$(atuin init zsh)"
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# greeting
command -v fastfetch >/dev/null && fastfetch
