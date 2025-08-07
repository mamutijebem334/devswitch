#!/bin/bash

# Script to update package manager configurations after a new release
# Run this after creating a new GitHub release

set -e

VERSION=${1:-$(git describe --tags --abbrev=0)}
if [ -z "$VERSION" ]; then
    echo "❌ No version specified and no git tags found"
    echo "Usage: $0 [version]"
    exit 1
fi

echo "🚀 Updating package managers for version: $VERSION"

# Update Homebrew formula
echo "📦 Updating Homebrew formula..."
# Calculate SHA256 hashes for binaries
DARWIN_AMD64_SHA=$(curl -sL "https://github.com/GustyCube/devswitch/releases/download/$VERSION/devswitch-darwin-amd64" | shasum -a 256 | cut -d' ' -f1)
DARWIN_ARM64_SHA=$(curl -sL "https://github.com/GustyCube/devswitch/releases/download/$VERSION/devswitch-darwin-arm64" | shasum -a 256 | cut -d' ' -f1)
LINUX_AMD64_SHA=$(curl -sL "https://github.com/GustyCube/devswitch/releases/download/$VERSION/devswitch-linux-amd64" | shasum -a 256 | cut -d' ' -f1)
LINUX_ARM64_SHA=$(curl -sL "https://github.com/GustyCube/devswitch/releases/download/$VERSION/devswitch-linux-arm64" | shasum -a 256 | cut -d' ' -f1)
WINDOWS_SHA=$(curl -sL "https://github.com/GustyCube/devswitch/releases/download/$VERSION/devswitch-windows-amd64.exe" | shasum -a 256 | cut -d' ' -f1)

# Update homebrew formula
sed -i.bak "s/version \".*\"/version \"${VERSION#v}\"/" homebrew/devswitch.rb
sed -i.bak "s/REPLACE_WITH_ACTUAL_SHA256_FOR_ARM64/$DARWIN_ARM64_SHA/" homebrew/devswitch.rb
sed -i.bak "s/REPLACE_WITH_ACTUAL_SHA256_FOR_AMD64/$DARWIN_AMD64_SHA/" homebrew/devswitch.rb
sed -i.bak "s/REPLACE_WITH_ACTUAL_SHA256_FOR_LINUX_ARM64/$LINUX_ARM64_SHA/" homebrew/devswitch.rb
sed -i.bak "s/REPLACE_WITH_ACTUAL_SHA256_FOR_LINUX_AMD64/$LINUX_AMD64_SHA/" homebrew/devswitch.rb
rm homebrew/devswitch.rb.bak

# Update Scoop manifest
echo "🪣 Updating Scoop manifest..."
sed -i.bak "s/\"version\": \".*\"/\"version\": \"${VERSION#v}\"/" scoop/devswitch.json
sed -i.bak "s/REPLACE_WITH_ACTUAL_SHA256/$WINDOWS_SHA/" scoop/devswitch.json
sed -i.bak "s/v[0-9.]*/v${VERSION#v}/g" scoop/devswitch.json
rm scoop/devswitch.json.bak

# Update AUR PKGBUILD
echo "🏛️ Updating AUR PKGBUILD..."
sed -i.bak "s/pkgver=.*/pkgver=${VERSION#v}/" aur/PKGBUILD
sed -i.bak "s/REPLACE_WITH_ACTUAL_SHA256_AMD64/$LINUX_AMD64_SHA/" aur/PKGBUILD
sed -i.bak "s/REPLACE_WITH_ACTUAL_SHA256_ARM64/$LINUX_ARM64_SHA/" aur/PKGBUILD
rm aur/PKGBUILD.bak

# Generate new .SRCINFO
echo "📄 Updating .SRCINFO..."
cd aur
makepkg --printsrcinfo > .SRCINFO
cd ..

# Update Debian changelog
echo "📦 Updating Debian changelog..."
TODAY=$(date -R)
cat > debian/changelog << EOF
devswitch (${VERSION#v}) stable; urgency=medium

  * Release ${VERSION}
  * See GitHub releases for detailed changelog

 -- Bennett Schwartz <gc@gustycube.xyz>  $TODAY
EOF

# Update RPM spec
echo "🎩 Updating RPM spec..."
sed -i.bak "s/Version:.*/Version:        ${VERSION#v}/" rpm/devswitch.spec
rm rpm/devswitch.spec.bak

echo "✅ All package managers updated for $VERSION"
echo "📝 Next steps:"
echo "   1. Commit and push changes: git add . && git commit -m 'chore: update package managers for $VERSION'"
echo "   2. Submit to Homebrew: Create PR to homebrew-core"
echo "   3. Submit to AUR: Push to AUR repository"
echo "   4. Submit to Scoop: Create PR to scoop bucket"
echo "   5. Build and publish APT/RPM packages"