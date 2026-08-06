#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  printf '\n==> %s\n' "$1"
}

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

if [[ ! -r /etc/os-release ]]; then
  die "Cannot identify this Linux distribution. This script supports Ubuntu."
fi

# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "Expected Ubuntu, found ${PRETTY_NAME:-unknown distribution}."
command -v sudo >/dev/null 2>&1 || die "sudo is required."

log "Authorising sudo"
sudo -v

log "Installing Ubuntu build and Neovim runtime dependencies"
sudo env DEBIAN_FRONTEND=noninteractive apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  clang \
  cmake \
  curl \
  fzf \
  git \
  gzip \
  libclang-dev \
  ninja-build \
  nodejs \
  npm \
  pkg-config \
  python3 \
  python3-pip \
  python3-venv \
  ripgrep \
  tar \
  unzip \
  xz-utils

log "Installing or updating Rust through Rustup"
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error \
    https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
fi

# Rustup writes this file during installation. Loading it also ensures its
# current Rust toolchain takes precedence over Ubuntu's older /usr/bin/rustc.
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
rustup toolchain install stable --profile minimal
rustup default stable
rustup update stable

log "Installing tree-sitter-cli"
cargo install tree-sitter-cli --locked

log "Verifying required commands"
for command_name in git curl rg fzf cc clang cmake cargo rustc tree-sitter node npm python3 tar gzip unzip; do
  command -v "$command_name" >/dev/null 2>&1 || die "Missing command after installation: $command_name"
done

rustc --version
tree-sitter --version

if command -v nvim >/dev/null 2>&1; then
  nvim_version="$(nvim --version | awk 'NR == 1 { sub(/^v/, "", $2); print $2 }')"
  if dpkg --compare-versions "$nvim_version" ge "0.12.0"; then
    printf 'NVIM v%s\n' "$nvim_version"
  else
    die "Neovim 0.12+ is required, but the active nvim is v${nvim_version}. Check your Bob PATH setup."
  fi
else
  die "Neovim is not on PATH. Install Neovim 0.12+ with Bob before starting the config."
fi

log "Bootstrap complete"
printf '%s\n' \
  "Open a new terminal so ~/.cargo/bin is available everywhere." \
  "Then start Neovim; the configuration will install or update its parsers automatically."
