#!/bin/bash

# DevSwitch GitHub Release Creator
# Creates a GitHub release with built binaries

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VERSION=${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")}
DIST_DIR="dist"
PRERELEASE=${2:-false}

# Function to print colored output
print_status() {
    echo -e "${CYAN}[RELEASE]${NC} $1"
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

# Function to check prerequisites
check_prerequisites() {
    # Check if gh CLI is installed
    if ! command -v gh >/dev/null 2>&1; then
        print_error "GitHub CLI (gh) is not installed"
        print_status "Install with: brew install gh"
        print_status "Or visit: https://cli.github.com/"
        exit 1
    fi
    
    # Check if authenticated with GitHub
    if ! gh auth status >/dev/null 2>&1; then
        print_error "Not authenticated with GitHub"
        print_status "Run: gh auth login"
        exit 1
    fi
    
    # Check if binaries exist
    if [ ! -d "$DIST_DIR" ] || [ -z "$(ls -A $DIST_DIR/devswitch-* 2>/dev/null)" ]; then
        print_error "No built binaries found in $DIST_DIR/"
        print_status "Run: ./scripts/build-release.sh first"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to generate release notes
generate_release_notes() {
    local version=$1
    local previous_version
    
    # Get previous version
    previous_version=$(git tag --sort=-version:refname | grep -v "^$version$" | head -n1 2>/dev/null || echo "")
    
    local release_notes_file="release-notes-${version#v}.md"
    
    cat > "$release_notes_file" << EOF
# DevSwitch ${version}

## 🎉 What's New

### ✨ Features
- Instant profile switching for developer configurations
- Beautiful CLI with styled boxes and progress bars  
- Automatic backup and rollback system
- Profile comparison and selective apply
- Template system (corporate, personal, minimal)

### 🔧 Extended Configuration Support
- **Git configs** - Different identities for work/personal projects
- **SSH keys** - Manage SSH identities and configurations
- **Environment variables** - Switch API keys and environment settings
- **Docker configs** - Different registries and credentials per profile
- **NPM/Yarn configs** - Manage registries and auth tokens
- **AWS profiles** - Switch between AWS credentials and regions
- **VSCode settings** - Customized editor settings per profile
- **Shell configurations** - Different aliases and shell setups

## 📥 Installation

### Quick Install
\`\`\`bash
# Universal installer - detects your OS automatically
curl -fsSL https://raw.githubusercontent.com/GustyCube/devswitch/main/install.sh | bash
\`\`\`

### Package Managers
\`\`\`bash
# macOS
brew install devswitch

# Windows  
scoop install devswitch

# Arch Linux
yay -S devswitch

# Ubuntu/Debian
sudo apt install devswitch
\`\`\`

### Manual Installation
Download the appropriate binary for your platform below and add it to your PATH.

## 🚀 Quick Start
\`\`\`bash
# Create your first profile
devswitch create work

# Create from template
devswitch create personal --template personal

# Switch profiles
devswitch apply work

# Compare profiles
devswitch diff work personal
\`\`\`

## 📋 Full Changelog
EOF

    if [ -n "$previous_version" ]; then
        echo "" >> "$release_notes_file"
        git log --pretty=format:"- %s" "${previous_version}..HEAD" >> "$release_notes_file" 2>/dev/null || true
    fi
    
    cat >> "$release_notes_file" << EOF

## 🔐 Verification
Verify downloads with SHA256 checksums:
\`\`\`
$(cat ${DIST_DIR}/checksums.txt)
\`\`\`

---
**Full Changelog**: https://github.com/GustyCube/devswitch/compare/${previous_version}...${version}
EOF
    
    echo "$release_notes_file"
}

# Function to create the release
create_release() {
    local version=$1
    local prerelease_flag=""
    
    if [ "$PRERELEASE" = "true" ]; then
        prerelease_flag="--prerelease"
    fi
    
    print_status "Creating GitHub release $version..."
    
    # Generate release notes
    local release_notes_file
    release_notes_file=$(generate_release_notes "$version")
    
    print_status "Generated release notes: $release_notes_file"
    
    # Create release with binaries
    local release_files=()
    
    # Add all binaries
    while IFS= read -r -d '' file; do
        release_files+=("$file")
    done < <(find "$DIST_DIR" -name "devswitch-*" -not -name "*.txt" -print0)
    
    # Add checksums file
    if [ -f "${DIST_DIR}/checksums.txt" ]; then
        release_files+=("${DIST_DIR}/checksums.txt")
    fi
    
    print_status "Uploading ${#release_files[@]} files to release..."
    
    # Create the release
    if gh release create "$version" \
        "${release_files[@]}" \
        --title "DevSwitch $version" \
        --notes-file "$release_notes_file" \
        $prerelease_flag; then
        
        print_success "🎉 Release $version created successfully!"
        
        # Show release URL
        local release_url
        release_url=$(gh release view "$version" --json url --jq .url)
        print_status "Release URL: $release_url"
        
        # Cleanup
        rm -f "$release_notes_file"
        
    else
        print_error "Failed to create release"
        rm -f "$release_notes_file"
        exit 1
    fi
}

# Function to show release summary
show_release_summary() {
    local version=$1
    
    echo
    echo -e "${BLUE}╭─────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│         Release Summary             │${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────╯${NC}"
    echo
    
    print_status "Release: $version"
    print_status "Binaries uploaded: $(ls -1 $DIST_DIR/devswitch-* | wc -l | tr -d ' ')"
    
    # Show download commands
    echo
    print_status "Download examples:"
    echo "  # macOS (Apple Silicon)"
    echo "  curl -L https://github.com/GustyCube/devswitch/releases/download/$version/devswitch-darwin-arm64 -o devswitch"
    echo
    echo "  # Linux (x64)"
    echo "  curl -L https://github.com/GustyCube/devswitch/releases/download/$version/devswitch-linux-amd64 -o devswitch"
    echo
    echo "  # Windows (x64)" 
    echo "  curl -L https://github.com/GustyCube/devswitch/releases/download/$version/devswitch-windows-amd64.exe -o devswitch.exe"
    echo
    
    print_status "Next steps:"
    echo "  1. 🍺 Submit to Homebrew: Create PR to homebrew-core"
    echo "  2. 📦 Update package managers: ./scripts/update-package-managers.sh $version"
    echo "  3. 🪣 Submit to Scoop: Create bucket repository"
    echo "  4. 🏛️ Submit to AUR: Upload PKGBUILD"
}

# Main execution
main() {
    echo -e "${BLUE}╭─────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│    DevSwitch Release Creator        │${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────╯${NC}"
    echo
    
    check_prerequisites
    
    # Check if tag exists
    if git rev-parse "$VERSION" >/dev/null 2>&1; then
        print_warning "Tag $VERSION already exists"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "$VERSION"
            git push origin --delete "$VERSION" 2>/dev/null || true
        else
            print_error "Aborted"
            exit 1
        fi
    fi
    
    # Create and push tag
    print_status "Creating and pushing tag $VERSION..."
    git tag "$VERSION"
    git push origin "$VERSION"
    
    # Create release
    create_release "$VERSION"
    
    # Show summary
    show_release_summary "$VERSION"
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        echo "Usage: $0 [version] [prerelease]"
        echo ""
        echo "Create a GitHub release with built binaries"
        echo ""
        echo "Arguments:"
        echo "  version      Version tag (default: latest git tag or v1.0.0)"
        echo "  prerelease   Mark as prerelease: true/false (default: false)"
        echo ""
        echo "Options:"
        echo "  -h, --help   Show this help message"
        echo ""
        echo "Prerequisites:"
        echo "  - GitHub CLI (gh) installed and authenticated"
        echo "  - Built binaries in ./dist/ directory"
        echo ""
        echo "Examples:"
        echo "  $0                    # Create release with auto-detected version"
        echo "  $0 v1.2.0             # Create release v1.2.0"
        echo "  $0 v1.2.0-beta true   # Create prerelease v1.2.0-beta"
        exit 0
        ;;
esac

# Run main function
main "$@"