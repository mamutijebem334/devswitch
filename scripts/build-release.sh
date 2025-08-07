#!/bin/bash

# DevSwitch Release Binary Builder
# Builds cross-platform binaries for GitHub releases

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BINARY_NAME="devswitch"
VERSION=${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")}
OUTPUT_DIR="dist"
BUILD_TIME=$(date -u '+%Y-%m-%d_%H:%M:%S')
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Function to print colored output
print_status() {
    echo -e "${CYAN}[BUILD]${NC} $1"
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

# Build targets (OS/ARCH combinations)
declare -a TARGETS=(
    "linux/amd64"
    "linux/arm64"
    "darwin/amd64"
    "darwin/arm64"
    "windows/amd64"
    "windows/arm64"
)

# Function to build binary for specific target
build_binary() {
    local target=$1
    local os=${target%/*}
    local arch=${target#*/}
    local extension=""
    
    if [ "$os" = "windows" ]; then
        extension=".exe"
    fi
    
    local output_name="${BINARY_NAME}-${os}-${arch}${extension}"
    local output_path="${OUTPUT_DIR}/${output_name}"
    
    print_status "Building ${os}/${arch}..."
    
    # Build flags for optimization and version info
    local ldflags="-s -w"
    ldflags="${ldflags} -X main.version=${VERSION#v}"
    ldflags="${ldflags} -X main.buildTime=${BUILD_TIME}"
    ldflags="${ldflags} -X main.gitCommit=${GIT_COMMIT}"
    
    # Set environment variables and build
    GOOS=$os GOARCH=$arch CGO_ENABLED=0 go build \
        -ldflags "$ldflags" \
        -o "$output_path" \
        .
    
    if [ $? -eq 0 ]; then
        # Calculate file size
        local size=$(ls -lh "$output_path" | awk '{print $5}')
        print_success "✅ ${output_name} (${size})"
        
        # Calculate SHA256 hash
        if command -v sha256sum >/dev/null 2>&1; then
            local hash=$(sha256sum "$output_path" | cut -d' ' -f1)
        elif command -v shasum >/dev/null 2>&1; then
            local hash=$(shasum -a 256 "$output_path" | cut -d' ' -f1)
        else
            local hash="unavailable"
        fi
        
        echo "$hash  $output_name" >> "${OUTPUT_DIR}/checksums.txt"
    else
        print_error "❌ Failed to build ${output_name}"
        return 1
    fi
}

# Function to create release archives
create_archives() {
    print_status "Creating release archives..."
    
    cd "$OUTPUT_DIR"
    
    for file in ${BINARY_NAME}-*; do
        if [[ "$file" == *".exe" ]]; then
            # Windows: create ZIP archive
            local archive_name="${file%.exe}.zip"
            zip -q "$archive_name" "$file"
            print_success "📦 Created $archive_name"
        else
            # Unix: create tar.gz archive
            local archive_name="${file}.tar.gz"
            tar -czf "$archive_name" "$file"
            print_success "📦 Created $archive_name"
        fi
    done
    
    cd ..
}

# Function to verify Go installation
verify_go() {
    if ! command -v go >/dev/null 2>&1; then
        print_error "Go is not installed or not in PATH"
        exit 1
    fi
    
    local go_version=$(go version | cut -d' ' -f3)
    print_status "Using Go version: $go_version"
}

# Function to clean previous builds
clean_dist() {
    if [ -d "$OUTPUT_DIR" ]; then
        print_status "Cleaning previous build artifacts..."
        rm -rf "$OUTPUT_DIR"
    fi
    mkdir -p "$OUTPUT_DIR"
}

# Function to display build summary
show_summary() {
    echo
    echo -e "${BLUE}╭─────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│           Build Summary             │${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────╯${NC}"
    echo
    print_status "Version: $VERSION"
    print_status "Build time: $BUILD_TIME"
    print_status "Git commit: $GIT_COMMIT"
    print_status "Output directory: $OUTPUT_DIR"
    echo
    
    print_status "Built binaries:"
    ls -la "$OUTPUT_DIR"/${BINARY_NAME}-* 2>/dev/null | while read -r line; do
        echo "  $line"
    done
    
    echo
    print_status "SHA256 Checksums:"
    if [ -f "${OUTPUT_DIR}/checksums.txt" ]; then
        cat "${OUTPUT_DIR}/checksums.txt" | while read -r line; do
            echo "  $line"
        done
    fi
    
    echo
    print_success "🎉 Release build completed successfully!"
    echo
    print_status "Next steps:"
    echo "  1. Test binaries: ./dist/devswitch-<os>-<arch> --version"
    echo "  2. Create GitHub release: gh release create $VERSION ./dist/devswitch-*"
    echo "  3. Or upload manually to GitHub releases page"
}

# Function to test built binaries
test_binaries() {
    print_status "Testing built binaries..."
    
    local native_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local native_arch=$(uname -m)
    
    # Convert arch names to Go format
    case $native_arch in
        x86_64) native_arch="amd64" ;;
        aarch64|arm64) native_arch="arm64" ;;
    esac
    
    local native_binary="${OUTPUT_DIR}/${BINARY_NAME}-${native_os}-${native_arch}"
    
    if [ -f "$native_binary" ]; then
        print_status "Testing native binary: $native_binary"
        if $native_binary --version >/dev/null 2>&1; then
            print_success "✅ Native binary test passed"
        else
            print_warning "⚠️ Native binary test failed (but build succeeded)"
        fi
    else
        print_warning "⚠️ Native binary not found for testing"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}╭─────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│      DevSwitch Release Builder      │${NC}"
    echo -e "${BLUE}╰─────────────────────────────────────╯${NC}"
    echo
    
    # Verify prerequisites
    verify_go
    
    # Clean and prepare
    clean_dist
    
    print_status "Building DevSwitch $VERSION..."
    print_status "Targets: ${#TARGETS[@]} platforms"
    echo
    
    # Build all targets
    local build_count=0
    local failed_count=0
    
    for target in "${TARGETS[@]}"; do
        if build_binary "$target"; then
            ((build_count++))
        else
            ((failed_count++))
        fi
    done
    
    echo
    print_status "Build completed: $build_count successful, $failed_count failed"
    
    # Test binaries if possible
    test_binaries
    
    # Create archives
    create_archives
    
    # Show summary
    show_summary
    
    # Exit with error if any builds failed
    if [ $failed_count -gt 0 ]; then
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        echo "Usage: $0 [version]"
        echo ""
        echo "Build cross-platform binaries for DevSwitch release"
        echo ""
        echo "Arguments:"
        echo "  version    Version tag (default: latest git tag or v1.0.0)"
        echo ""
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0              # Build with auto-detected version"
        echo "  $0 v1.2.0       # Build with specific version"
        echo ""
        echo "Output:"
        echo "  Binaries will be created in ./dist/ directory"
        echo "  SHA256 checksums in ./dist/checksums.txt"
        exit 0
        ;;
    -*)
        print_error "Unknown option: $1"
        echo "Use '$0 --help' for usage information"
        exit 1
        ;;
esac

# Run main function
main "$@"