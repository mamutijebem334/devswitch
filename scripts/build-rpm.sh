#!/bin/bash

# Build RPM package for DevSwitch
# Note: This creates the package structure, but requires rpmbuild to build

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

print_status() { echo -e "${CYAN}[RPM]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

VERSION=${1:-"0.1.0"}
RPM_DIR="packages/rpm"

print_status "Building RPM package for DevSwitch v${VERSION}..."

# Check if package structure exists
if [ ! -f "$RPM_DIR/SPECS/devswitch.spec" ]; then
    echo "Error: RPM spec file not found at $RPM_DIR/SPECS/devswitch.spec"
    echo "Run this from the project root directory."
    exit 1
fi

cd "$RPM_DIR"

print_status "Package contents:"
find . -name "devswitch*" -type f | while read file; do
    if [ -f "$file" ]; then
        size=$(ls -lh "$file" | awk '{print $5}')
        echo "  $file ($size)"
    fi
done

print_status "RPM spec file:"
cat SPECS/devswitch.spec | head -20
echo "  ... (truncated)"

# Note about building
echo
print_status "To build the actual .rpm package:"
echo "  1. Install rpm-build: dnf install rpm-build rpmdevtools"
echo "  2. Build package: rpmbuild --define '_topdir $(pwd)' -bb SPECS/devswitch.spec"
echo "  3. Install with: sudo rpm -i RPMS/x86_64/devswitch-0.1.0-1.*.rpm"
echo

print_status "Package structure ready!"

# Create installation guide
cat > INSTALL_RPM.md << EOF
# Installing DevSwitch RPM Package

## Prerequisites
\`\`\`bash
# RHEL/CentOS/Fedora
sudo dnf install rpm-build rpmdevtools

# Or for older systems
sudo yum install rpm-build rpmdevtools
\`\`\`

## Build the package
\`\`\`bash
cd packages/rpm
rpmbuild --define '_topdir \$(pwd)' -bb SPECS/devswitch.spec
\`\`\`

## Install
\`\`\`bash
sudo rpm -i RPMS/x86_64/devswitch-0.1.0-1.*.rpm
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

print_success "Created INSTALL_RPM.md with installation instructions"