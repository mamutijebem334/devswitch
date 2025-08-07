# DevSwitch 🔄

> Instantly switch developer profiles (.gitconfig, shell rc, VSCode settings) across work/school/personal setups

[![Go Report Card](https://goreportcard.com/badge/github.com/yourusername/devswitch)](https://goreportcard.com/report/github.com/yourusername/devswitch)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Release](https://img.shields.io/github/release/yourusername/devswitch.svg)](https://github.com/yourusername/devswitch/releases/latest)

## Features ✨

### Core Functionality
- 🔄 **Instant Profile Switching** - Switch between work, personal, and school configurations in seconds
- 📦 **Beautiful CLI Interface** - Styled boxes, progress bars, and colored output
- 🛡️ **Automatic Backups** - Never lose your configurations with automatic backup system
- 🔍 **Profile Comparison** - Compare profiles or check differences against current config
- 🎯 **Selective Apply** - Apply only specific config files with `--only` flag
- ⏪ **Rollback System** - Easily revert to previous configurations

### Extended Configuration Support
- 🔑 **SSH Keys & Config** - Manage SSH identities and configurations
- 🌍 **Environment Variables** - Switch API keys, paths, and environment settings
- 🐳 **Docker Configs** - Different registries and credentials per profile
- 📦 **NPM/Yarn Configs** - Manage different registries and auth tokens
- ☁️ **AWS Profiles** - Switch between different AWS credentials and regions
- ⚙️ **Git Configs** - Different git identities for work/personal projects
- 🖥️ **VSCode Settings** - Customized editor settings per profile
- 🐚 **Shell Configurations** - Different aliases and shell setups

### Profile Templates
- 🏢 **Corporate Template** - Company-focused setup with corporate npm registry
- 👤 **Personal Template** - Personal development with Oh My Zsh and custom configs  
- 🎯 **Minimal Template** - Clean, basic configuration setup

## Installation 📥

### Homebrew (Recommended)
```bash
# Coming soon
brew install devswitch
```

### Direct Download
```bash
# Download latest release for your platform
curl -L https://github.com/yourusername/devswitch/releases/latest/download/devswitch-$(uname -s)-$(uname -m) -o devswitch
chmod +x devswitch
sudo mv devswitch /usr/local/bin/
```

### Build from Source
```bash
git clone https://github.com/yourusername/devswitch.git
cd devswitch
go build -o devswitch .
sudo cp devswitch /usr/local/bin/
```

## Quick Start 🚀

```bash
# Create your first profile from current configs
devswitch create work

# Create a profile from a template
devswitch create personal --template personal

# List all profiles
devswitch list

# Switch to a profile
devswitch apply work

# Compare profiles
devswitch diff work personal

# Apply only specific configs
devswitch apply work --only gitconfig,zshrc

# Rollback to previous state
devswitch rollback
```

## Usage Examples 📖

### Basic Profile Management
```bash
# Create profile from current configuration
devswitch create work

# Create profile from template
devswitch create startup --template corporate

# List available profiles  
devswitch list
# Output: Available profiles:
#   • work
#   • personal
#   • startup

# Check current active profile
devswitch current

# Switch profiles
devswitch apply personal
```

### Advanced Features
```bash
# Compare two profiles
devswitch diff work personal

# Compare profile to current config
devswitch diff work

# Apply only specific configs
devswitch apply work --only gitconfig,npmrc,env

# Backup current configs without switching
devswitch backup

# Rollback to latest backup
devswitch rollback

# Rollback to specific backup
devswitch rollback 20231201-143052
```

### Profile Templates
```bash
# Corporate template - includes company npm registry, production env vars
devswitch create work --template corporate

# Personal template - includes Oh My Zsh, personal git settings
devswitch create home --template personal  

# Minimal template - basic, clean configuration
devswitch create simple --template minimal
```

## Managed Configuration Files 📁

DevSwitch automatically manages these configuration files:

| Category | Files | Description |
|----------|-------|-------------|
| **Git** | `.gitconfig` | Git user settings, aliases, and preferences |
| **Shell** | `.zshrc`, `.bashrc` | Shell configuration, aliases, and environment |
| **Editor** | `settings.json` | VSCode user settings and preferences |
| **SSH** | `.ssh/config`, SSH keys | SSH configuration and identity files |
| **Environment** | `.env`, `.profile` | Environment variables and system paths |
| **Docker** | `.docker/config.json` | Docker registry and authentication |
| **Package Managers** | `.npmrc`, `.yarnrc` | NPM/Yarn registries and tokens |
| **Cloud** | `.aws/config`, `.aws/credentials` | AWS profiles and credentials |

## File Structure 📂

```
~/.devswitch/
├── profiles/           # Stored profiles
│   ├── work/          # Work profile configs
│   ├── personal/      # Personal profile configs
│   └── school/        # School profile configs
├── backups/           # Automatic backups
│   ├── 20231201-143052/
│   └── 20231201-150234/
└── current_profile.txt # Currently active profile
```

## Templates 📋

### Corporate Template
Perfect for company work with:
- Corporate git identity
- Company npm registry configuration
- Production environment variables
- Professional VS Code settings
- Company-specific shell aliases

### Personal Template  
Ideal for personal development:
- Personal git identity with preferred settings
- Oh My Zsh configuration with themes
- Development environment variables
- Customized editor preferences
- Personal productivity aliases

### Minimal Template
Clean, basic setup with:
- Simple git configuration
- Essential shell aliases
- Basic editor settings
- Minimal environment setup

## Contributing 🤝

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)  
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- [box-cli-maker](https://github.com/Delta456/box-cli-maker) - Beautiful terminal boxes
- [color](https://github.com/fatih/color) - Colorful terminal output
- [progressbar](https://github.com/schollz/progressbar) - Terminal progress bars
- [cli](https://github.com/urfave/cli) - CLI application framework

---

**DevSwitch** - Made with ❤️ for developers who juggle multiple environments