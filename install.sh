#!/usr/bin/env bash

#HOME_DIR=/home/kd
#BIN_DIR=/usr/local/bin

setup() {
  curl https://mise.run | sh
  sudo mv $HOME/.local/bin/mise /usr/local/bin/mise
  source ~/.bashrc
  sudo apt install stow -y
  install_docker
}

install_docker() {
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sudo sh -eux <<EOF
  # Install newuidmap & newgidmap bi sudo sh -eux <<EOF
  # Install newuidmap & newgidmap binaries
  apt-get install -y uidmap
  EOF sudo sh -eux <<EOF
  # Install newuidmap & newgidmap binaries
  apt-get install -y uidmap
  EOF
  
  rm get-docker.sh
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
