# ==============================================================================
# ~/.zshrc  (Gentoo, OpenRC)
# Deps:
#   sudo emerge -av app-shells/zsh app-shells/fzf sys-apps/fd sys-apps/bat \
#        sys-apps/ripgrep sys-apps/eza app-editors/neovim app-shells/starship \
#        app-shells/zsh-autosuggestions app-shells/zsh-syntax-highlighting \
#        app-portage/gentoolkit
# ==============================================================================

# ---- editor ------------------------------------------------------------------
export EDITOR=nvim VISUAL=nvim SUDO_EDITOR=nvim

# ---- shell basics ------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space auto_cd

# ---- aliases -----------------------------------------------------------------
# portage
alias ei='sudo emerge -av'                           # install
alias eu='sudo emerge -avuDN @world'                 # full system update
alias esync='sudo emaint sync -a'                    # sync the tree
alias er='sudo emerge -avC'                          # remove a package
alias edc='sudo emerge -av --depclean'               # remove orphans / unused deps
alias es='emerge -s'                                 # search
alias einfo='emerge -pv'                             # package info (pretend)
alias el='cat /var/lib/portage/world'                # manually installed (world file)
alias ef='equery files'                              # files in a package
alias eb='equery belongs'                            # which package owns a file
alias eclean='sudo eclean-dist -d'                   # clear old distfiles
alias ecf='sudo dispatch-conf'                       # merge config file updates
alias epr='sudo emerge -av @preserved-rebuild'       # fix preserved libs
alias enews='eselect news read'

# openrc (systemd users: swap for systemctl)
alias svs='rc-status'
svr()   { sudo rc-service "$1" restart; }                                  # svr bluetooth
sven()  { sudo rc-update add "$1" default && sudo rc-service "$1" start; } # enable + start
svdis() { sudo rc-service "$1" stop; sudo rc-update del "$1" default; }    # stop + disable

# larp
alias ff='fastfetch'
alias fetch='fetch --infinite'
alias uni='unimatrix -s 95 -c magenta'
# files / system
alias sudo='doas'
alias playtest='nvim /home/haadi/Downloads/nvim-playground.txt'
alias ls='eza'
alias ll='eza -lah --git'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias ip='ip -c'
alias df='df -h'
alias free='free -h'
alias v='nvim'

# git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gd='git diff'
alias gl='git log --oneline --graph -15'

# reloads
alias mkr='makoctl reload'
alias wbr='pkill waybar; waybar &>/dev/null & disown'

# tmux / nvim helpers
alias t='tmux new -As main'                    # attach to "main", or create it
alias tmh='less -R ~/.config/tmux/help.txt'    # tmux cheat sheet
nvh() { nvim --cmd 'let g:workflow_stdin=1' -c KeyHelp -c 'autocmd WinClosed * ++once qa'; }  # nvim keybind sheet
playground() {                                 # opens a fresh copy of the practice file every time
  local d=~/.cache/nvim-playground
  mkdir -p "$d" && cp ~/.local/share/nvim-playground.txt "$d/nvim-playground.txt" || return
  (cd "$d" && nvim nvim-playground.txt)
}

# config editor:  cfg <tab>  (uses $EDITOR)
typeset -A _cfg=(
  zsh    $HOME/.zshrc
  foot   $HOME/.config/foot/foot.ini
  mako   $HOME/.config/mako/config
  waybar $HOME/.config/waybar/config.jsonc
  wbcss  $HOME/.config/waybar/style.css
  mango  $HOME/.config/mango/config.conf
)
cfg() {
  local f=${_cfg[$1]}
  [[ -z $f ]] && { echo "cfg: ${(kj:|:)_cfg}"; return 1 }
  $EDITOR "$f" && [[ $1 == zsh ]] && source ~/.zshrc
}

# basic exports

# ==============================================================================
# COMPLETION + FZF-TAB (Tokyo Night)
# ==============================================================================
typeset -g TN_FZF_COLORS="bg+:#283457,bg:#1a1b26,spinner:#bb9af7,hl:#7dcfff,\
fg:#c0caf5,header:#9ece6a,info:#0db9d7,pointer:#7dcfff,\
marker:#9ece6a,fg+:#c0caf5,prompt:#7dcfff,hl+:#7dcfff,border:#3b4261"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=rounded --color=$TN_FZF_COLORS"

# fzf-tab: auto-install (not in the Gentoo tree, so we clone it)
typeset -g FZF_TAB_DIR="$HOME/.config/zsh/fzf-tab"
if [[ ! -d $FZF_TAB_DIR ]]; then
  echo "Installing fzf-tab..."
  mkdir -p "${FZF_TAB_DIR:h}"
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
fi

# compinit must come BEFORE fzf-tab. Full rebuild once a day, otherwise cached.
autoload -Uz compinit
setopt extendedglob
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi

_cfg_complete() { compadd -- ${(k)_cfg}; }
compdef _cfg_complete cfg

source "$FZF_TAB_DIR/fzf-tab.plugin.zsh"

zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags \
  --height=40% --layout=reverse --border=rounded --color="$TN_FZF_COLORS"
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-j:down' 'ctrl-k:up' 'tab:accept'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:(nvim|vim|v|cat|bat|rm|cp|mv):*' fzf-preview \
  '[[ -d $realpath ]] && eza -1 --color=always $realpath || bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null'

# ==============================================================================
# FILE TOOLS
#   nf path/to/file.c   create dirs + file, open in nvim   (nf dir/ = mkdir only)
#   nf                  pick a folder with fzf, then type a filename
#   Ctrl+P              fuzzy open file (Tab = multi-select)
#   Ctrl+F              live grep, jump to line
# ==============================================================================
nf() {
  local target
  if (( $# == 0 )); then
    local dir
    dir=$(fd --type d --hidden --exclude .git . | sed '1i ./' |
          fzf --prompt='folder > ' --preview 'eza -1 --color=always {}') || return
    vared -p "new file in ${dir}: " -c target
    [[ -z $target ]] && return
    set -- "${dir%/}/$target"
  fi
  local -a files
  for target in "$@"; do
    if [[ $target == */ ]]; then
      mkdir -p -- "$target" && print -P "%F{green}dir%f  $target"
    else
      mkdir -p -- "${target:h}" && [[ -e $target ]] || touch -- "$target"
      files+=("$target")
    fi
  done
  (( ${#files} )) && $EDITOR "${files[@]}"
}

_quick_open() {
  local -a sel
  sel=("${(@f)$(fd --type f --hidden --follow --exclude .git 2>/dev/null |
    fzf --multi --prompt='file > ' \
        --preview 'bat --color=always --style=numbers --line-range=:300 {}')}")
  zle reset-prompt
  [[ -z ${sel[1]} ]] && return
  BUFFER="$EDITOR ${(j: :)${(@q)sel}}"
  zle accept-line
}

_live_grep() {
  local out file line
  out=$(rg --line-number --no-heading --smart-case --color=never '' 2>/dev/null |
    fzf --delimiter=: --prompt='grep > ' \
        --preview 'bat --color=always --highlight-line {2} {1}' \
        --preview-window='right,60%,+{2}/3') || { zle reset-prompt; return }
  file=${out%%:*}; line=${${out#*:}%%:*}
  zle reset-prompt
  BUFFER="$EDITOR +$line ${(q)file}"
  zle accept-line
}

zle -N _quick_open
zle -N _live_grep
bindkey '^P' _quick_open
bindkey '^F' _live_grep
gfetch
# ==============================================================================
# PROMPT + PLUGINS  (autosuggestions first, syntax-highlighting LAST)
# Gentoo installs these under site-contrib; the loop also tries the Void path.
# ==============================================================================
_src() { local f; for f in "$@"; do [[ -r $f ]] && { source "$f"; return }; done; }

eval "$(starship init zsh)"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'
_src /usr/share/zsh/site-contrib/zsh-autosuggestions/zsh-autosuggestions.zsh \
     /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
     /usr/share/zsh/site-functions/zsh-autosuggestions.zsh
_src /usr/share/zsh/site-contrib/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
     /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
     /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh


export PATH="$HOME/.local/bin:$PATH"
