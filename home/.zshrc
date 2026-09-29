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

# --- keybinds ----------------------------------------------------------------
# Up/Down: search history for lines starting with what's already typed
# (cursor goes to end of line). Ctrl-R: fuzzy history search (fzf, below).
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for key in '^[[A' '^[OA'; do bindkey "$key" up-line-or-beginning-search; done
for key in '^[[B' '^[OB'; do bindkey "$key" down-line-or-beginning-search; done

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
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# --- greeting ----------------------------------------------------------------
# fastfetch only in a fresh kitty window — not in nvim's :terminal/toggleterm
# ($NVIM) or VS Code's terminal, which inherit KITTY_WINDOW_ID when launched from kitty.
if [[ -n $KITTY_WINDOW_ID && -z $NVIM && $TERM_PROGRAM != vscode ]] && command -v fastfetch >/dev/null; then
  # clear re-shows fastfetch here (Ctrl-L still does a plain clear)
  clear() { command clear; fastfetch; }
  fastfetch
fi

# --- plugins (installed via pacman) -----------------------------------------
# Last on purpose: zsh-syntax-highlighting must wrap every widget defined above.
src() { [ -f "$1" ] && source "$1"; }
src /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
src /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
