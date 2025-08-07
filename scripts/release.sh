#!/bin/bash

# DevSwitch Complete Release Script
# Builds binaries and creates GitHub release in one command

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${CYAN}[RELEASE]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

VERSION=${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")}

echo -e "${CYAN}╭─────────────────────────────────────╮${NC}"
echo -e "${CYAN}│      DevSwitch Complete Release     │${NC}"
echo -e "${CYAN}╰─────────────────────────────────────╯${NC}"
echo

print_status "Building binaries for $VERSION..."
./scripts/build-release.sh "$VERSION"

echo
print_status "Creating GitHub release..."
./scripts/create-release.sh "$VERSION"

print_success "🎉 Complete release process finished!"
print_status "Your release is now live at: https://github.com/GustyCube/devswitch/releases/tag/$VERSION"