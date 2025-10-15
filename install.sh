#HOME_DIR=/home/kd
#BIN_DIR=/usr/local/bin

setup() {
  curl https://mise.run | sh
  sudo apt install stow -y 
}

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

install_apps() {
  mise install
}

apply_config() {
  dirs=($(eza ~/.dotfiles -D --git-ignore))
  for dir in "${dirs[@]}"; do
    echo "Processing: $dir"
    stow -R -t "$HOME" "$dir"
  done
}

setup
install_apps
ensure_dotfiles_repo
apply_config
