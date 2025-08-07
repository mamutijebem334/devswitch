#!/bin/bash

# DevSwitch Installation Script
# Automatically detects OS and architecture and installs the appropriate binary

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GitHub repository info
REPO="GustyCube/devswitch"
VERSION="latest"
INSTALL_DIR="/usr/local/bin"

# Function to print colored output
print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to detect OS and architecture
detect_platform() {
    local os
    local arch
    
    # Detect OS
    case "$(uname -s)" in
        Darwin*)    os="darwin" ;;
        Linux*)     os="linux" ;;
        CYGWIN*|MINGW*|MSYS*) os="windows" ;;
        *)          print_error "Unsupported operating system: $(uname -s)" && exit 1 ;;
    esac
    
    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64)   arch="amd64" ;;
        arm64|aarch64)  arch="arm64" ;;
        *)              print_error "Unsupported architecture: $(uname -m)" && exit 1 ;;
    esac
    
    echo "${os}-${arch}"
}

# Function to get the latest release version
get_latest_version() {
    if command -v curl >/dev/null 2>&1; then
        curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4
    else
        print_error "Neither curl nor wget found. Please install one of them and try again."
        exit 1
    fi
}

# Function to download and install DevSwitch
install_devswitch() {
    local platform=$1
    local version=$2
    local binary_name="devswitch-${platform}"
    local download_url="https://github.com/${REPO}/releases/download/${version}/${binary_name}"
    
    if [[ "$platform" == *"windows"* ]]; then
        binary_name="${binary_name}.exe"
        download_url="${download_url}.exe"
    fi
    
    local temp_file="/tmp/${binary_name}"
    
    print_status "Downloading DevSwitch ${version} for ${platform}..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L "$download_url" -o "$temp_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$temp_file" "$download_url"
    fi
    
    if [ ! -f "$temp_file" ]; then
        print_error "Failed to download DevSwitch"
        exit 1
    fi
    
    # Make the binary executable
    chmod +x "$temp_file"
    
    # Try to install to /usr/local/bin, fall back to ~/bin if no sudo access
    if [ -w "$INSTALL_DIR" ] || sudo -n true 2>/dev/null; then
        print_status "Installing DevSwitch to ${INSTALL_DIR}..."
        if [ -w "$INSTALL_DIR" ]; then
            mv "$temp_file" "${INSTALL_DIR}/devswitch"
        else
            sudo mv "$temp_file" "${INSTALL_DIR}/devswitch"
        fi
        print_success "DevSwitch installed to ${INSTALL_DIR}/devswitch"
    else
        # Fall back to user's home bin directory
        local user_bin_dir="$HOME/bin"
        mkdir -p "$user_bin_dir"
        mv "$temp_file" "${user_bin_dir}/devswitch"
        print_success "DevSwitch installed to ${user_bin_dir}/devswitch"
        print_warning "Please add ${user_bin_dir} to your PATH if it's not already there:"
        echo "    export PATH=\"${user_bin_dir}:\$PATH\""
    fi
}

# Function to verify installation
verify_installation() {
    if command -v devswitch >/dev/null 2>&1; then
        local installed_version
        installed_version=$(devswitch --version 2>&1 | head -n1)
        print_success "Installation verified: ${installed_version}"
        echo
        print_status "Quick start:"
        echo "  devswitch create work          # Create a work profile"
        echo "  devswitch create personal --template personal  # Create from template"
        echo "  devswitch list                 # List all profiles"
        echo "  devswitch apply work           # Switch to work profile"
        echo
        print_status "For more information, visit: https://github.com/${REPO}"
    else
        print_error "Installation verification failed. DevSwitch command not found."
        print_warning "You may need to restart your terminal or update your PATH."
        exit 1
    fi
}

# Main installation process
main() {
    echo -e "${BLUE}╭─────────────────────────────────╮${NC}"
    echo -e "${BLUE}│     DevSwitch Installer         │${NC}"
    echo -e "${BLUE}╰─────────────────────────────────╯${NC}"
    echo
    
    print_status "Detecting platform..."
    platform=$(detect_platform)
    print_status "Detected platform: ${platform}"
    
    print_status "Fetching latest version..."
    if [ "$VERSION" = "latest" ]; then
        VERSION=$(get_latest_version)
    fi
    print_status "Latest version: ${VERSION}"
    
    install_devswitch "$platform" "$VERSION"
    verify_installation
    
    print_success "🎉 DevSwitch installation completed successfully!"
}

# Run the installer
main "$@"