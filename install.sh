#!/bin/sh
set -eu

have() { command -v "$1" >/dev/null 2>&1; }

pkg_install() {
  if have apt-get; then
    sudo apt-get update -y
    sudo apt-get install -y "$@"
  elif have apk; then
    sudo apk add --no-cache "$@"
  elif have dnf; then
    sudo dnf install -y "$@"
  else
    echo "No supported package manager found." >&2
    return 1
  fi
}

setup() {
  have git || pkg_install git
  have stow || pkg_install stow
  # trash-cli may not exist on all distros; ignore failures
  have trash || pkg_install trash-cli || true

  if ! have mise; then
    # Install mise to $HOME/.local/bin
    curl https://mise.run | sh
    PATH="$HOME/.local/bin:$PATH"
    # Persist for future shells
    if [ -f "$HOME/.bashrc" ] && ! grep -q "mise activate" "$HOME/.bashrc"; then
      {
        echo
        echo '# mise'
        echo 'export PATH="$HOME/.local/bin:$PATH"'
        echo 'eval "$(mise activate bash)"'
      } >> "$HOME/.bashrc"
    fi
  fi
}

ensure_dotfiles_repo() {
  REPO_DIR="$HOME/.dotfiles"
  REPO_URL="https://github.com/kensledev/dotfiles.git"

  if [ -d "$REPO_DIR/.git" ]; then
    echo "Dotfiles repo exists at $REPO_DIR"
  else
    echo "Cloning dotfiles into $REPO_DIR..."
    git clone "$REPO_URL" "$REPO_DIR"
  fi
}

install_apps() {
  if have mise; then
    PATH="$HOME/.local/bin:$PATH" mise install || true
  else
    echo "mise not on PATH; skipping 'mise install'"
  fi
}

apply_config() {
  REPO_DIR="$HOME/.dotfiles"
  [ -d "$REPO_DIR" ] || { echo "$REPO_DIR not found" >&2; return 1; }

  rm $HOME/.zshrc
  rm $HOME/.git


  # For each top-level package dir (skip repo internals)
  for d in "$REPO_DIR"/*; do
    [ -d "$d" ] || continue
    base="$(basename "$d")"
    case "$base" in
      .git|script|scripts) continue ;;
    esac

    echo "Stowing: $base"

    # 1) Dry-run to discover conflicts and back them up
    #    We parse stow's warnings for: "existing target is neither a link nor a directory: <path>"
    stow -nvt "$HOME" -d "$REPO_DIR" "$base" 2>&1 \
      | sed -n 's/.* existing target is neither a link nor a directory: //p' \
      | while IFS= read -r rel; do
          [ -n "$rel" ] || continue
          [ -e "$HOME/$rel" ] || continue
          # timestamped backup to avoid overwriting previous backups
          mv -v "$HOME/$rel" "$HOME/$rel.bak.$(date +%s)"
        done

    # 2) Real stow after backups
    stow -vt "$HOME" -d "$REPO_DIR" "$base"
  done
}


# Don’t install Docker inside DevPod containers
install_docker() {
  echo "Skipping Docker installation inside DevPod container."
}

setup
ensure_dotfiles_repo
install_apps
apply_config

echo "✅ Dotfiles install complete."
