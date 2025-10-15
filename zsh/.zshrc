eval "$(starship init zsh)"
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

###
# Alias
###

# ------------------------------ Nvim
alias v="nvim"
# alias vim="nvim"
# alias lv="NVIM_APPNAME=lazy nvim"
# alias fv="NVIM_APPNAME=folke nvim"
# alias jv="NVIM_APPNAME=jujuvim nvim ."
# alias jvv="NVIM_APPNAME=jujuvim nvim"
# alias o="nvr --remote"
# alias k="nvr --remote-send"

# ------------------------------ Git
alias g="git"
alias gpl="git pull"
alias gd="git diff"
alias ga="git add ."
alias gac="git add . && git commit"
alias gl="git lg"
alias gll="git lg2"
alias gc="git commit"
alias gch="git checkout"
alias gs="~/.config/tmux/scripts/git_status"
alias gps="git push"
alias cgs="clear && git status"
alias lzg="lazygit"

# ------------------------------ Apt get

alias install='sudo apt install -y'
alias remove='sudo apt purge'
alias update='sudo apt update'
alias upgrade='sudo apt update && sudo apt upgrade'

#alias list='sudo dpkg -l'
#alias findapp='sudo apt list --installed | grep -i apache'

# ----------------------------- Pacman
#alias install='sudo pacman -S --noconfirm '
#alias remove='sudo pacman -R '
#alias update='sudo pacman -Sy '

# --------------------------------File Ops

alias cl='clear'


alias la='eza -l --icons --git'
alias l='eza -l --icons --git -a'
alias lsa='eza --icons --git'
alias ls='eza --icons --git -a'
alias lt='eza --tree --level=2 --long --icons --git -a'
alias lta='eza --tree --level=2 --long --icons --git'

alias lh='ls -d .?* '    # Hidden only
alias lha='ls -ld .?* '    # Hidden inline

alias DELETE='sudo rm -rf'
# alias del='rm -rf'
alias del='trash'
alias rm='trash'

alias es='sudo chmod u+x'
alias aliases="nvim ~/.config/zsh/aliases"


# ------------------------------ Pnpm
alias p="pnpm"
alias pd="pnpm dev"
alias pt="pnpm test"
alias pti="pnpm test:ui"
alias pte="pnpm test:e2e"
alias pb="pnpm build"


# ---------------------------------TMUX

alias tmux='tmux -f ~/.config/tmux/tmux.conf'
alias tmns='tmux new -s'
alias tmas='tmux a -t'
alias tmks='tmux kill-session -t'
alias tmsc='tmux a -t sysconfig'
alias tmls='tmux list'
alias tma='tmux a'
alias ts='~/.config/zsh/scripts/tmux-sessionizer'


#---- DOCKER
alias dkrmi='sudo docker rmi $(docker images -a -q)'
alias dkrmc='sudo docker ps -a'
alias dkrma='sudo docker rmi $(docker images -a -q) && docker ps -a'
alias dk='lazydocker'


# FZF
alias s=displayFZFFiles
alias sd=fdFzf
alias sl=nvimGoToLine
alias sf=nvimGoToFiles

###
# Mice
###

export MISE_SHELL=zsh
export __MISE_ORIG_PATH="$PATH"

mise() {
  local command
  command="${1:-}"
  if [ "$#" = 0 ]; then
    command mise
    return
  fi
  shift

  case "$command" in
  deactivate|shell|sh)
    # if argv doesn't contains -h,--help
    if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]; then
      eval "$(command mise "$command" "$@")"
      return $?
    fi
    ;;
  esac
  command mise "$command" "$@"
}

_mise_hook() {
  eval "$(mise hook-env -s zsh)";
}
typeset -ag precmd_functions;
if [[ -z "${precmd_functions[(r)_mise_hook]+1}" ]]; then
  precmd_functions=( _mise_hook ${precmd_functions[@]} )
fi
typeset -ag chpwd_functions;
if [[ -z "${chpwd_functions[(r)_mise_hook]+1}" ]]; then
  chpwd_functions=( _mise_hook ${chpwd_functions[@]} )
fi

_mise_hook
if [ -z "${_mise_cmd_not_found:-}" ]; then
    _mise_cmd_not_found=1
    # preserve existing handler if present
    if typeset -f command_not_found_handler >/dev/null; then
        functions -c command_not_found_handler _command_not_found_handler
    fi

    typeset -gA _mise_cnf_tried

    # helper for fallback behavior
    _mise_fallback() {
        local _cmd="$1"; shift
        if typeset -f _command_not_found_handler >/dev/null; then
            _command_not_found_handler "$_cmd" "$@"
            return $?
        else
            print -u2 -- "zsh: command not found: $_cmd"
            return 127
        fi
    }

    command_not_found_handler() {
        local cmd="$1"; shift

        # never intercept mise itself or retry already-attempted commands
        if [[ "$cmd" == "mise" || "$cmd" == mise-* || -n "${_mise_cnf_tried["$cmd"]}" ]]; then
            _mise_fallback "$cmd" "$@"
            return $?
        fi

        # run the hook; only retry if the command is actually found afterward
        if mise hook-not-found -s zsh -- "$cmd"; then
            _mise_hook
            if command -v -- "$cmd" >/dev/null 2>&1; then
                "$cmd" "$@"
                return $?
            fi
        else
            # only mark as tried if mise explicitly can't handle it
            _mise_cnf_tried["$cmd"]=1
        fi

        # fall back
        _mise_fallback "$cmd" "$@"
    }
fi

# Smart cd: path -> builtin cd, otherwise try zoxide; then ls
alias c="cd $1"
cd() {
  # no args: go home
  if [[ $# -eq 0 ]]; then
    builtin cd ~ || return
    ls -a
    return
  fi

  local arg="$1"

  # If it's clearly a path or an existing dir, use builtin cd
  if [[ -d "$arg" || "$arg" == "-" || "$arg" == ~* || "$arg" == /* || "$arg" == .* ]]; then
    builtin cd -- "$arg" || return
    ls -a
    return
  fi

  # Otherwise, try zoxide jump (frecency match)
  if command -v __zoxide_z >/dev/null 2>&1; then
    __zoxide_z "$@" || return
    ls -a
    return
  fi

  # Fallback: try builtin cd anyway
  builtin cd -- "$arg" || return
  ls -a
}

# Fzf config file editor
edit() {
  local editor="${EDITOR:-vim}"

  # Candidate config files/dirs (add/remove freely)
  local -a candidates=(
    "$HOME/.zshrc"
    "$HOME/.config/zsh/zshrc"
    "$HOME/.config/mise/config.toml"
    "$HOME/.config/mise/config.yaml"
    "$HOME/.config/mice/config.yml"      # in case your path is this
    "$HOME/.config/tmux/tmux.conf"
    "$HOME/.gitconfig"
    "$HOME/.config/git/config"
    "$HOME/.config/starship.toml"
    "$HOME/.config/nvim/init.lua"
    "$HOME/.config/nvim"                  # whole folder, if you prefer
    "$HOME/.ssh/config"
  )

  # Keep only those that currently exist
  local -a existing=()
  local f
  for f in "${candidates[@]}"; do
    [[ -e "$f" ]] && existing+=("$f")
  done

  if (( ${#existing[@]} == 0 )); then
    echo "No known config files found. Edit the candidate list in the function."
    return 1
  fi

  # Optional query: `edit zsh` pre-filters the list
  local query="$*"

  # fzf preview: bat if available, else sed/ls
  local preview='
    if command -v bat >/dev/null 2>&1; then
      if [ -d {} ]; then ls -la --color=always {}; else bat --style=numbers --color=always --line-range :200 {}; fi
    else
      if [ -d {} ]; then ls -la {}; else sed -n "1,200p" {}; fi
    fi
  '

  local chosen
  chosen="$(printf "%s\n" "${existing[@]}" \
    | fzf --prompt="Edit config > " \
          --height=80% \
          --preview="$preview" \
          --preview-window=right:60% \
          --border \
          ${query:+--query="$query"})" || return

  [[ -z "$chosen" ]] && return 0

  # Open dir vs file
  if [[ -d "$chosen" ]]; then
    "$editor" "$chosen"
  else
    "$editor" "$chosen"
  fi
}
