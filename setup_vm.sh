#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Packages to be installed via APT (standard Ubuntu repositories)
# Note: Added 'git' and 'curl' to ensure the zoxide install works.
APT_PACKAGES="fzf neovim ripgrep fd-find bat fish tmux git curl"

# --- Function Definitions ---

install_tools() {
    echo "## 📦 Starting Installation..."

    # Determine SUDO usage
    local SUDO=""
    if [ "$EUID" -ne 0 ]; then
        echo "-> Running commands with sudo..."
        SUDO="sudo"
    fi

    # 1. Update package lists
    echo "-> Updating package lists..."
    $SUDO apt update

    # 2. Install APT packages (Safe, repository versions)
    echo "-> Installing via apt: $APT_PACKAGES"
    $SUDO apt install -y $APT_PACKAGES

    # 3. Fix Ubuntu naming quirks (Symlinks)
    # Ubuntu installs 'fd' as 'fdfind' and 'bat' as 'batcat' due to naming conflicts.
    # We create symlinks so you can use the standard commands 'fd' and 'bat'.
    
    echo "-> checking/creating symlinks for fd and bat..."
    
    # fd symlink
    if command -v fdfind &> /dev/null && [ ! -f /usr/local/bin/fd ]; then
        $SUDO ln -s "$(which fdfind)" /usr/local/bin/fd
    fi
    
    # bat symlink
    if command -v batcat &> /dev/null && [ ! -f /usr/local/bin/bat ]; then
        $SUDO ln -s "$(which batcat)" /usr/local/bin/bat
    fi

    # 4. Install Zoxide via Curl (User specified method)
    echo "-> Installing zoxide..."
    # We run this WITHOUT sudo so it installs to the user's home directory (~/.local/bin)
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    echo "## ✅ Installation complete."
    echo "---"
}

# --- Main Execution ---

main() {
    install_tools
    
    echo "*******************************************************"
    echo "* Setup Finished!                                     *"
    echo "* Note: Ensure ~/.local/bin is in your PATH for zoxide.*"
    echo "*******************************************************"
}

main
