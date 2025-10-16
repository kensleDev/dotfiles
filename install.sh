#!/usr/bin/env bash
set -euo pipefail

# --- helpers ---------------------------------------------------------------
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
    echo "❌ No supported package manager found."
    return 1
  fi
}

ensure_tool() {
  local bin="$1"; shift
  if ! have "$bin"; then
    pkg_install "$@"
  fi
}

# --- 1) base setup ---------------------------------------------------------
setup() {
  # Ensure common tools
  ensure_tool git git
  ensure_tool stow stow
  ensure_tool trash trash-cli || true  # ignore if not available on this distro

  # Install mise (user-local)
  if ! have mise; then
    curl https://mise.run | sh
    # Ensure mise is on PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    # Persist for future shells
    if ! grep -q 'mise activate' "$HOME/.bashrc" 2>/dev/null; then
      {
        echo ''
        echo '# mise'
        echo 'export PATH="$HOME/.local/bin:$PATH"'
        echo 'eval "$(mise activate bash)"'
      } >> "$HOME/.bashrc"
    fi
  fi
}

# --- 2) dotfiles repo presence --------------------------------------------
ensure_dotfiles_repo() {
  local repo_dir="$HOME/.dotfiles"
  local repo_url="https://github.com/kensledev/dotfiles.git"

  if [ -d "$repo_dir/.git" ]; then
    echo "✅ Dotfiles repo already exists at $repo_dir"
  else
    echo "⬇️  Cloning dotfiles repo into $repo_dir..."
    git clone "$repo_url" "$repo_dir" && echo "✅ Clone successful!" || echo "❌ Clone failed."
  fi
}

# --- 3) language/tools via mise -------------------------------------------
install_apps() {
  if have mise; then
    mise install
  else
    echo "⚠️ mise not found on PATH; skipping 'mise install'"
  fi
}

# --- 4) apply stow configs -------------------------------------------------
apply_config() {
  local repo_dir="$HOME/.dotfiles"
  [ -d "$repo_dir" ] || { echo "❌ $repo_dir not found"; return 1; }

  # List only top-level directories (no eza dependency), exclude .git and any scripts dir
  mapfile -t dirs < <(find "$repo_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
    | grep -Ev '^(\.git|scripts?)$' || true)

  for dir in "${dirs[@]}"; do
    echo "🔗 Stowing: $dir"
    stow -d "$repo_dir" -R -t "$HOME" "$dir"
  done
}

# --- 5) (intentionally) skip Docker-in-Docker ------------------------------
install_docker() {
  echo "ℹ️ Skipping Docker installation inside DevPod container."
}

# --- run -------------------------------------------------------------------
setup
ensure_dotfiles_repo
install_apps
apply_config

echo "✅ Dotfiles install complete."
