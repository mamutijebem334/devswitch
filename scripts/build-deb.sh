#!/bin/bash

# Build DEB package for DevSwitch
# Note: This creates the package structure, but requires dpkg-deb to build

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

print_status() { echo -e "${CYAN}[DEB]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

VERSION=${1:-"0.1.0"}
PACKAGE_DIR="packages/deb"
PACKAGE_NAME="devswitch_${VERSION}-1"

print_status "Building DEB package for DevSwitch v${VERSION}..."

# Check if package structure exists
if [ ! -d "$PACKAGE_DIR/$PACKAGE_NAME" ]; then
    echo "Error: Package structure not found at $PACKAGE_DIR/$PACKAGE_NAME"
    echo "Run this from the project root directory."
    exit 1
fi

cd "$PACKAGE_DIR"

print_status "Package contents:"
find "$PACKAGE_NAME" -type f | while read file; do
    size=$(ls -lh "$file" | awk '{print $5}')
    echo "  $file ($size)"
done

print_status "Control file:"
cat "$PACKAGE_NAME/DEBIAN/control"

# Note about building
echo
print_status "To build the actual .deb package:"
echo "  1. Install dpkg-deb: apt-get install dpkg-dev"
echo "  2. Build package: dpkg-deb --build $PACKAGE_NAME"
echo "  3. Install with: sudo dpkg -i ${PACKAGE_NAME}.deb"
echo

print_status "Package structure ready!"
print_status "Users can install with: sudo dpkg -i ${PACKAGE_NAME}.deb"

# Create a simple installation guide
cat > INSTALL_DEB.md << EOF
# Installing DevSwitch DEB Package

## Prerequisites
\`\`\`bash
sudo apt-get update
sudo apt-get install dpkg-dev
\`\`\`

## Build the package
\`\`\`bash
cd packages/deb
dpkg-deb --build $PACKAGE_NAME
\`\`\`

## Install
\`\`\`bash
sudo dpkg -i ${PACKAGE_NAME}.deb
\`\`\`

## Verify installation
\`\`\`bash
devswitch --version
devswitch --help
\`\`\`

## Start using
\`\`\`bash
devswitch create work --template corporate
devswitch list
devswitch apply work
\`\`\`
EOF

print_success "Created INSTALL_DEB.md with installation instructions"