# DevSwitch Makefile

.PHONY: build clean test release help install dev

# Default target
help: ## Show this help message
	@echo "DevSwitch - Developer Profile Switcher"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build for current platform
	@echo "🔨 Building DevSwitch for current platform..."
	go build -o devswitch .

build-all: ## Build binaries for all platforms
	@echo "🔨 Building DevSwitch for all platforms..."
	./scripts/build-release.sh

clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	rm -rf dist/
	rm -f devswitch

test: ## Run tests
	@echo "🧪 Running tests..."
	go test -v ./...

lint: ## Run linter
	@echo "🔍 Running linter..."
	go vet ./...
	@if command -v staticcheck >/dev/null 2>&1; then \
		staticcheck ./...; \
	else \
		echo "⚠️  staticcheck not installed, skipping..."; \
	fi

install: build ## Install to /usr/local/bin
	@echo "📦 Installing DevSwitch to /usr/local/bin..."
	sudo cp devswitch /usr/local/bin/devswitch
	@echo "✅ DevSwitch installed successfully!"

dev: ## Build and install for development
	@echo "🛠️  Building and installing for development..."
	go build -o devswitch .
	sudo cp devswitch /usr/local/bin/devswitch
	@echo "✅ Development build installed!"

release: ## Build and create GitHub release
	@echo "🚀 Creating complete release..."
	./scripts/release.sh

release-build: ## Build release binaries only
	@echo "🔨 Building release binaries..."
	./scripts/build-release.sh

release-create: ## Create GitHub release (requires built binaries)
	@echo "📤 Creating GitHub release..."
	./scripts/create-release.sh

deps: ## Download dependencies
	@echo "📦 Downloading dependencies..."
	go mod download
	go mod verify

format: ## Format code
	@echo "✨ Formatting code..."
	go fmt ./...

check: lint test ## Run all checks (lint + test)

# Version info
version: ## Show version information
	@if [ -f devswitch ]; then \
		./devswitch --version; \
	else \
		echo "Binary not built. Run 'make build' first."; \
	fi

# Development workflow
dev-setup: deps ## Set up development environment
	@echo "🔧 Setting up development environment..."
	@if ! command -v staticcheck >/dev/null 2>&1; then \
		echo "📦 Installing staticcheck..."; \
		go install honnef.co/go/tools/cmd/staticcheck@latest; \
	fi
	@echo "✅ Development environment ready!"

# Quick development cycle
quick: clean build install ## Quick build and install cycle