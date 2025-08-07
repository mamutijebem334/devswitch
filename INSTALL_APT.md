# Install DevSwitch via APT

## Quick Install

```bash
# Add the repository
curl -fsSL https://gustycube.github.io/devswitch/install-apt.sh | sudo bash

# Install DevSwitch
sudo apt update
sudo apt install devswitch
```

## Manual Setup

```bash
# Add repository to sources
echo "deb https://gustycube.github.io/devswitch/repository/apt stable main" | sudo tee /etc/apt/sources.list.d/devswitch.list

# Update package list
sudo apt update

# Install DevSwitch
sudo apt install devswitch
```

## Verify Installation

```bash
devswitch --version
devswitch --help
```

## Quick Start

```bash
devswitch create work --template corporate
devswitch list
devswitch apply work
```

## Remove Repository

```bash
sudo rm /etc/apt/sources.list.d/devswitch.list
sudo apt update
```