#!/bin/sh
set -eu

# Logging helpers
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

# Detect current shell
detect_shell() {
	if [ -n "${SHELL:-}" ]; then
		basename "$SHELL"
	elif have zsh; then
		echo "zsh"
	elif have bash; then
		echo "bash"
	else
		echo "sh"
	fi
}

# Get shell config file
get_shell_config() {
	local shell_name="${1:-$(detect_shell)}"
	case "$shell_name" in
	zsh) echo "$HOME/.zshrc" ;;
	bash) echo "$HOME/.bashrc" ;;
	fish) echo "$HOME/.config/fish/config.fish" ;;
	*) echo "$HOME/.profile" ;;
	esac
}

pkg_install() {
	if have apt-get; then
		sudo apt-get update -y || { log_error "apt-get update failed"; return 1; }
		sudo apt-get install -y "$@" || { log_error "apt-get install failed"; return 1; }
	elif have apk; then
		sudo apk add --no-cache "$@" || { log_error "apk add failed"; return 1; }
	elif have dnf; then
		sudo dnf install -y "$@" || { log_error "dnf install failed"; return 1; }
	elif have yum; then
		sudo yum install -y "$@" || { log_error "yum install failed"; return 1; }
	elif have pacman; then
		sudo pacman -Sy --noconfirm "$@" || { log_error "pacman install failed"; return 1; }
	elif have zypper; then
		sudo zypper install -y "$@" || { log_error "zypper install failed"; return 1; }
	else
		log_error "No supported package manager found (apt-get, apk, dnf, yum, pacman, zypper)"
		return 1
	fi
}

# Backup a file if it exists
backup_file() {
	local file="$1"
	if [ -e "$file" ] && [ ! -L "$file" ]; then
		local backup="${file}.bak.$(date +%s)"
		log_info "Backing up $file to $backup"
		mv -v "$file" "$backup" || {
			log_error "Failed to backup $file"
			return 1
		}
	fi
}

setup() {
	log_info "Installing required packages..."

	have git || pkg_install git || { log_error "Failed to install git"; return 1; }
	have stow || pkg_install stow || { log_error "Failed to install stow"; return 1; }
	have tmux || pkg_install tmux || { log_error "Failed to install tmux"; return 1; }

	# trash-cli may not exist on all distros; don't fail if unavailable
	if ! have trash; then
		log_info "Attempting to install trash-cli (optional)..."
		pkg_install trash-cli || log_warn "trash-cli not available, skipping"
	fi

	if ! have mise; then
		log_info "Installing mise..."
		# Download script first instead of piping directly to sh
		local mise_installer="/tmp/mise-install-$$.sh"
		if ! curl -fsSL https://mise.run -o "$mise_installer"; then
			log_error "Failed to download mise installer"
			return 1
		fi

		# Execute the installer
		if ! sh "$mise_installer"; then
			log_error "mise installation failed"
			rm -f "$mise_installer"
			return 1
		fi
		rm -f "$mise_installer"

		# Add mise to PATH for this session
		export PATH="$HOME/.local/bin:$PATH"

		# Verify installation
		if ! have mise; then
			log_error "mise installation succeeded but mise not found in PATH"
			return 1
		fi

		log_info "Configuring mise for shell..."
		# Configure for the appropriate shell(s)
		local shell_name
		shell_name="$(detect_shell)"
		local config_file
		config_file="$(get_shell_config "$shell_name")"

		# Ensure config file exists
		if [ ! -f "$config_file" ]; then
			mkdir -p "$(dirname "$config_file")"
			touch "$config_file"
		fi

		# Add mise configuration if not already present
		if ! grep -q "mise activate" "$config_file" 2>/dev/null; then
			{
				echo
				echo '# mise'
				echo 'export PATH="$HOME/.local/bin:$PATH"'
				case "$shell_name" in
				fish)
					echo 'mise activate fish | source'
					;;
				*)
					echo "eval \"\$(mise activate $shell_name)\""
					;;
				esac
			} >>"$config_file"
			log_info "Added mise configuration to $config_file"
		else
			log_info "mise already configured in $config_file"
		fi

		# Also configure bash if we're using zsh (many systems have both)
		if [ "$shell_name" = "zsh" ] && [ -f "$HOME/.bashrc" ]; then
			if ! grep -q "mise activate" "$HOME/.bashrc" 2>/dev/null; then
				{
					echo
					echo '# mise'
					echo 'export PATH="$HOME/.local/bin:$PATH"'
					echo 'eval "$(mise activate bash)"'
				} >>"$HOME/.bashrc"
				log_info "Also added mise configuration to .bashrc"
			fi
		fi
	else
		log_info "mise already installed"
	fi
}

ensure_dotfiles_repo() {
	local repo_dir="$HOME/.dotfiles"
	local repo_url="https://github.com/kensledev/dotfiles.git"

	if [ -d "$repo_dir" ] && git -C "$repo_dir" rev-parse --git-dir >/dev/null 2>&1; then
		log_info "Dotfiles repo exists at $repo_dir"
		# Ensure it's up to date
		log_info "Pulling latest changes..."
		if ! git -C "$repo_dir" pull --ff-only; then
			log_warn "Could not fast-forward; you may have local changes"
		fi
	else
		log_info "Cloning dotfiles into $repo_dir..."
		if ! git clone "$repo_url" "$repo_dir"; then
			log_error "Failed to clone dotfiles repository"
			return 1
		fi
		log_info "Successfully cloned dotfiles"
	fi
}

install_apps() {
	if have mise; then
		log_info "Running mise install..."
		export PATH="$HOME/.local/bin:$PATH"
		if mise install; then
			log_info "mise install completed successfully"
		else
			log_warn "mise install failed or had issues"
		fi
	else
		log_warn "mise not available; skipping 'mise install'"
	fi
}

apply_config() {
	local repo_dir="$HOME/.dotfiles"

	if [ ! -d "$repo_dir" ]; then
		log_error "$repo_dir not found"
		return 1
	fi

	# Backup existing config files that might conflict
	log_info "Backing up existing config files..."
	backup_file "$HOME/.zshrc"
	backup_file "$HOME/.gitconfig"

	# For each top-level package dir (skip repo internals)
	for d in "$repo_dir"/*; do
		[ -d "$d" ] || continue
		local base
		base="$(basename "$d")"
		case "$base" in
		.git | script | scripts | images-webp.zip) continue ;;
		esac

		log_info "Stowing: $base"

		# 1) Dry-run to discover conflicts and back them up
		#    We parse stow's warnings for: "existing target is neither a link nor a directory: <path>"
		stow -nvt "$HOME" -d "$repo_dir" "$base" 2>&1 |
			sed -n 's/.* existing target is neither a link nor a directory: //p' |
			while IFS= read -r rel; do
				[ -n "$rel" ] || continue
				[ -e "$HOME/$rel" ] || continue
				# timestamped backup to avoid overwriting previous backups
				backup_file "$HOME/$rel"
			done

		# 2) Real stow after backups
		if ! stow -vt "$HOME" -d "$repo_dir" "$base"; then
			log_error "Failed to stow $base"
			return 1
		fi
	done

	log_info "All configurations stowed successfully"
}

# Main execution
main() {
	log_info "Starting dotfiles installation..."

	setup || { log_error "Setup failed"; exit 1; }
	ensure_dotfiles_repo || { log_error "Failed to ensure dotfiles repo"; exit 1; }
	install_apps || { log_error "App installation failed"; exit 1; }
	apply_config || { log_error "Config application failed"; exit 1; }

	echo "✅ Dotfiles install complete."
	log_info "Please restart your shell or run: source $(get_shell_config)"
}

main
