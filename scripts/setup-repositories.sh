#!/bin/bash

# Setup APT and YUM repositories for DevSwitch
# This script creates repository metadata and can be hosted on GitHub Pages

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${CYAN}[REPO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

VERSION=${1:-"0.1.0"}
REPO_DIR="repository"

print_status "Setting up package repositories for DevSwitch v${VERSION}..."

# Create directories if they don't exist
mkdir -p "${REPO_DIR}/apt/pool/main/d/devswitch"
mkdir -p "${REPO_DIR}/apt/dists/stable/main/binary-amd64"
mkdir -p "${REPO_DIR}/yum/el8/x86_64"
mkdir -p "${REPO_DIR}/yum/el9/x86_64"
mkdir -p "${REPO_DIR}/yum/fedora/x86_64"

print_status "Copying DEB package to APT pool..."
if [ -f "packages/deb/devswitch_${VERSION}-1.deb" ]; then
    cp "packages/deb/devswitch_${VERSION}-1.deb" "${REPO_DIR}/apt/pool/main/d/devswitch/"
    print_success "DEB package copied"
else
    print_warning "DEB package not found. Build it first with: ./scripts/build-deb.sh"
fi

print_status "Copying RPM packages to YUM repos..."
for dist in el8 el9 fedora; do
    if [ -f "packages/rpm/RPMS/x86_64/devswitch-${VERSION}-1.*.rpm" ]; then
        cp packages/rpm/RPMS/x86_64/devswitch-${VERSION}-1.*.rpm "${REPO_DIR}/yum/${dist}/x86_64/"
        print_success "RPM package copied to ${dist}"
    else
        print_warning "RPM package not found for ${dist}. Build it first with: ./scripts/build-rpm.sh"
    fi
done

print_status "Generating APT repository metadata..."
cd "${REPO_DIR}/apt"

# Generate Packages file
dpkg-scanpackages pool/main/d/devswitch /dev/null > dists/stable/main/binary-amd64/Packages 2>/dev/null || {
    print_warning "dpkg-scanpackages not available. Creating basic Packages file..."
    
    cat > dists/stable/main/binary-amd64/Packages << EOF
Package: devswitch
Version: ${VERSION}-1
Architecture: amd64
Maintainer: Bennett Schwartz <gc@gustycube.xyz>
Installed-Size: 8192
Filename: pool/main/d/devswitch/devswitch_${VERSION}-1.deb
Size: $(stat -f%z "pool/main/d/devswitch/devswitch_${VERSION}-1.deb" 2>/dev/null || echo "4096000")
MD5sum: $(md5sum "pool/main/d/devswitch/devswitch_${VERSION}-1.deb" 2>/dev/null | cut -d' ' -f1 || echo "placeholder")
SHA1: $(sha1sum "pool/main/d/devswitch/devswitch_${VERSION}-1.deb" 2>/dev/null | cut -d' ' -f1 || echo "placeholder")
SHA256: $(sha256sum "pool/main/d/devswitch/devswitch_${VERSION}-1.deb" 2>/dev/null | cut -d' ' -f1 || echo "placeholder")
Section: utils
Priority: optional
Description: Instantly switch developer profiles
 DevSwitch allows developers to instantly switch between different
 configuration profiles (.gitconfig, shell rc, VSCode settings) across
 work, school, and personal environments.

EOF
}

# Compress Packages file
gzip -c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz

print_success "APT metadata generated"

cd - > /dev/null

print_status "Generating YUM repository metadata..."
for dist in el8 el9 fedora; do
    if command -v createrepo_c >/dev/null 2>&1; then
        createrepo_c "${REPO_DIR}/yum/${dist}"
        print_success "YUM metadata generated for ${dist}"
    elif command -v createrepo >/dev/null 2>&1; then
        createrepo "${REPO_DIR}/yum/${dist}"
        print_success "YUM metadata generated for ${dist}"
    else
        print_warning "createrepo not available. Install with: dnf install createrepo_c"
        # Create basic repodata structure
        mkdir -p "${REPO_DIR}/yum/${dist}/repodata"
        cat > "${REPO_DIR}/yum/${dist}/repodata/repomd.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<repomd xmlns="http://linux.duke.edu/metadata/repo" xmlns:rpm="http://linux.duke.edu/metadata/rpm">
  <revision>$(date +%s)</revision>
  <data type="primary">
    <checksum type="sha256">placeholder</checksum>
    <location href="repodata/primary.xml.gz"/>
  </data>
</repomd>
EOF
    fi
done

print_status "Creating installation guide..."

cat > "${REPO_DIR}/INSTALL_REPOSITORIES.md" << EOF
# DevSwitch Package Repositories

Host these repository files on any web server (GitHub Pages works great) to provide automatic package installation.

## APT Repository (Ubuntu/Debian)

### Add the repository:
\`\`\`bash
# Add repository key (optional for unsigned repo)
curl -fsSL https://your-domain.com/repository/devswitch.gpg | sudo gpg --dearmor -o /usr/share/keyrings/devswitch-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/devswitch-keyring.gpg] https://your-domain.com/repository/apt stable main" | sudo tee /etc/apt/sources.list.d/devswitch.list

# Update and install
sudo apt update
sudo apt install devswitch
\`\`\`

### Manual installation:
\`\`\`bash
wget https://your-domain.com/repository/apt/pool/main/d/devswitch/devswitch_${VERSION}-1.deb
sudo dpkg -i devswitch_${VERSION}-1.deb
\`\`\`

## YUM Repository (RHEL/CentOS/Fedora)

### Add the repository:
\`\`\`bash
# Add repository file
sudo curl -o /etc/yum.repos.d/devswitch.repo https://your-domain.com/repository/yum/devswitch.repo

# Install
sudo dnf install devswitch
# or
sudo yum install devswitch
\`\`\`

### Manual installation:
\`\`\`bash
# For RHEL/CentOS 8+
wget https://your-domain.com/repository/yum/el8/x86_64/devswitch-${VERSION}-1.el8.x86_64.rpm
sudo rpm -i devswitch-${VERSION}-1.el8.x86_64.rpm

# For Fedora
wget https://your-domain.com/repository/yum/fedora/x86_64/devswitch-${VERSION}-1.fc*.x86_64.rpm
sudo rpm -i devswitch-${VERSION}-1.fc*.x86_64.rpm
\`\`\`

## GitHub Pages Hosting

1. Create a \`gh-pages\` branch in your repository
2. Copy the entire \`repository/\` directory to the root
3. Enable GitHub Pages in repository settings
4. Users can then install from: \`https://username.github.io/repository-name/\`

## Verification

After installation from any source:
\`\`\`bash
devswitch --version
devswitch --help
\`\`\`

## Quick Start
\`\`\`bash
devswitch create work --template corporate
devswitch list
devswitch apply work
\`\`\`
EOF

print_success "Repository setup complete!"
echo
print_status "Repository structure:"
find "${REPO_DIR}" -type f | head -20
echo
print_status "Next steps:"
echo "1. Host the 'repository/' directory on a web server"
echo "2. Update URLs in INSTALL_REPOSITORIES.md with your domain"
echo "3. Users can install directly from your hosted repository"
echo "4. Consider signing packages with GPG for added security"