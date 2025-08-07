#!/bin/bash

# DevSwitch APT Repository Installer
# This script adds the DevSwitch repository to your system

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${CYAN}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root or with sudo"
   exit 1
fi

print_status "Adding DevSwitch APT repository..."

# Add repository
echo "deb https://devswitch.gustycube.com/repository/apt stable main" > /etc/apt/sources.list.d/devswitch.list

print_success "Repository added to /etc/apt/sources.list.d/devswitch.list"

print_status "Updating package list..."
apt update

print_success "DevSwitch repository is now ready!"
echo
echo "Install DevSwitch with:"
echo "  sudo apt install devswitch"
echo
echo "Then get started with:"
echo "  devswitch create work --template corporate"
echo "  devswitch list"
echo "  devswitch apply work"