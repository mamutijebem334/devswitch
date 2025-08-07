    package main

    import (
        "crypto/md5"
        "fmt"
        "io"
        "os"
        "path/filepath"
        "runtime"
        "strings"
        "time"

        "github.com/Delta456/box-cli-maker/v2"
        "github.com/fatih/color"
        "github.com/schollz/progressbar/v3"
        "github.com/urfave/cli/v2"
    )

    // List of config files we manage
    type configFile struct {
        Name string
        Src  func() string // returns absolute path in real home
    }

    func main() {
        app := &cli.App{
            Name:  "devswitch",
            Usage: "Instantly switch developer profiles (.gitconfig, shell rc, VSCode settings) across work/school/personal setups",
            Version: "1.0.0",
            Commands: []*cli.Command{
                {
                    Name:   "list",
                    Usage:  "List available profiles",
                    Action: cmdList,
                },
                {
                    Name:   "current",
                    Usage:  "Show the currently active profile",
                    Action: cmdCurrent,
                },
                {
                    Name:   "apply",
                    Usage:  "Apply a profile (backup current files, then swap)",
                    Action: cmdApply,
                    Flags: []cli.Flag{
                        &cli.StringFlag{
                            Name:  "only",
                            Usage: "Apply only specific config files (comma-separated): gitconfig,zshrc,settings.json",
                        },
                    },
                },
                {
                    Name:   "create",
                    Usage:  "Create a new profile from current configs",
                    Action: cmdCreate,
                    Flags: []cli.Flag{
                        &cli.StringFlag{
                            Name:  "template",
                            Usage: "Create profile from template: corporate, personal, minimal",
                        },
                    },
                },
                {
                    Name:   "backup",
                    Usage:  "Backup current configs without switching",
                    Action: cmdBackup,
                },
                {
                    Name:   "diff",
                    Usage:  "Compare two profiles or compare profile to current config",
                    Action: cmdDiff,
                    ArgsUsage: "[profile1] [profile2]",
                },
                {
                    Name:   "rollback",
                    Usage:  "Rollback to a previous backup",
                    Action: cmdRollback,
                    ArgsUsage: "[backup-timestamp]",
                },
            },
        }

        if err := app.Run(os.Args); err != nil {
            fmt.Println(err)
        }
    }

    // ---------- Helpers ----------

    func homeDir() string {
        h, _ := os.UserHomeDir()
        return h
    }

    func devDir() string {
        return filepath.Join(homeDir(), ".devswitch")
    }

    func profilesDir() string {
        return filepath.Join(devDir(), "profiles")
    }

    func backupsDir() string {
        return filepath.Join(devDir(), "backups")
    }

    func ensureDirs() error {
        paths := []string{devDir(), profilesDir(), backupsDir()}
        for _, p := range paths {
            if err := os.MkdirAll(p, 0o755); err != nil {
                return err
            }
        }
        return nil
    }

    func detectConfigFiles() []configFile {
        cfgs := []configFile{
            {
                Name: ".gitconfig",
                Src: func() string {
                    return filepath.Join(homeDir(), ".gitconfig")
                },
            },
        }

        // Shell rc
        shellRc := ".zshrc"
        if runtime.GOOS == "windows" {
            shellRc = ".bashrc" // fallback for Git Bash
        }
        cfgs = append(cfgs, configFile{
            Name: shellRc,
            Src: func() string {
                return filepath.Join(homeDir(), shellRc)
            },
        })

        // VSCode settings
        cfgs = append(cfgs, configFile{
            Name: "settings.json",
            Src: func() string {
                switch runtime.GOOS {
                case "darwin":
                    return filepath.Join(homeDir(), "Library", "Application Support", "Code", "User", "settings.json")
                case "windows":
                    appData := os.Getenv("APPDATA")
                    return filepath.Join(appData, "Code", "User", "settings.json")
                default:
                    return filepath.Join(homeDir(), ".config", "Code", "User", "settings.json")
                }
            },
        })

        // SSH Config
        cfgs = append(cfgs, configFile{
            Name: "ssh_config",
            Src: func() string {
                return filepath.Join(homeDir(), ".ssh", "config")
            },
        })

        // SSH Keys (id_rsa, id_ed25519)
        sshKeys := []string{"id_rsa", "id_rsa.pub", "id_ed25519", "id_ed25519.pub"}
        for _, key := range sshKeys {
            cfgs = append(cfgs, configFile{
                Name: "ssh_" + key,
                Src: func() string {
                    return filepath.Join(homeDir(), ".ssh", key)
                },
            })
        }

        // Environment variables (.env, .profile)
        cfgs = append(cfgs, configFile{
            Name: ".env",
            Src: func() string {
                return filepath.Join(homeDir(), ".env")
            },
        })

        cfgs = append(cfgs, configFile{
            Name: ".profile",
            Src: func() string {
                return filepath.Join(homeDir(), ".profile")
            },
        })

        // Docker config
        cfgs = append(cfgs, configFile{
            Name: "docker_config.json",
            Src: func() string {
                return filepath.Join(homeDir(), ".docker", "config.json")
            },
        })

        // NPM config
        cfgs = append(cfgs, configFile{
            Name: ".npmrc",
            Src: func() string {
                return filepath.Join(homeDir(), ".npmrc")
            },
        })

        // Yarn config
        cfgs = append(cfgs, configFile{
            Name: ".yarnrc",
            Src: func() string {
                return filepath.Join(homeDir(), ".yarnrc")
            },
        })

        // AWS config
        cfgs = append(cfgs, configFile{
            Name: "aws_config",
            Src: func() string {
                return filepath.Join(homeDir(), ".aws", "config")
            },
        })

        cfgs = append(cfgs, configFile{
            Name: "aws_credentials",
            Src: func() string {
                return filepath.Join(homeDir(), ".aws", "credentials")
            },
        })

        return cfgs
    }

    func copyFile(src, dst string) error {
        in, err := os.Open(src)
        if err != nil {
            return err
        }
        defer in.Close()

        if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
            return err
        }

        out, err := os.Create(dst)
        if err != nil {
            return err
        }
        defer out.Close()

        bar := progressbar.DefaultBytes(
            -1,
            fmt.Sprintf("Copying %s", filepath.Base(src)),
        )

        buf := make([]byte, 32*1024)
        for {
            n, err := in.Read(buf)
            if n > 0 {
                if _, errW := out.Write(buf[:n]); errW != nil {
                    return errW
                }
                bar.Add(n)
            }
            if err == io.EOF {
                break
            }
            if err != nil {
                return err
            }
        }
        bar.Finish()
        return out.Sync()
    }

    func writeCurrentProfile(name string) error {
        return os.WriteFile(filepath.Join(devDir(), "current_profile.txt"), []byte(name), 0o644)
    }

    func readCurrentProfile() (string, error) {
        b, err := os.ReadFile(filepath.Join(devDir(), "current_profile.txt"))
        if err != nil {
            return "", err
        }
        return string(b), nil
    }

    func boxInfo(title, body string) {
        // Use higher padding to prevent negative repeat count
        Box := box.New(box.Config{
            Px: 4,           // Increased horizontal padding
            Py: 1,           // Vertical padding
            Type: "Round",   // Box style
            Color: "Cyan",   // Box color
            TitlePos: "Top", // Title position
        })
        Box.Println(title, body)
    }

    // ---------- Commands ----------

    func cmdList(c *cli.Context) error {
        if err := ensureDirs(); err != nil {
            return err
        }
        entries, err := os.ReadDir(profilesDir())
        if err != nil {
            return err
        }
        if len(entries) == 0 {
            boxInfo("No Profiles Found", "Create your first profile with 'devswitch create <name>'")
            return nil
        }
        
        profileList := "\n"
        for _, e := range entries {
            if e.IsDir() {
                profileList += fmt.Sprintf("  • %s\n", e.Name())
            }
        }
        boxInfo("Available Profiles", profileList)
        return nil
    }

    func cmdCurrent(c *cli.Context) error {
        if err := ensureDirs(); err != nil {
            return err
        }
        prof, err := readCurrentProfile()
        if err != nil {
            boxInfo("No Active Profile", "Use 'devswitch apply <name>' to activate a profile")
            return nil
        }
        boxInfo("Current Profile", prof)
        return nil
    }

    func cmdApply(c *cli.Context) error {
        if c.Args().Len() == 0 {
            return fmt.Errorf("profile name required")
        }
        profile := c.Args().First()
        profPath := filepath.Join(profilesDir(), profile)
        if _, err := os.Stat(profPath); err != nil {
            return fmt.Errorf("profile %s does not exist", profile)
        }

        if err := ensureDirs(); err != nil {
            return err
        }

        // backup current configs
        fmt.Printf("%s Creating backup...\n", color.YellowString("⚠️ "))
        if err := cmdBackup(c); err != nil {
            color.Red("❌ Backup failed: %v", err)
        } else {
            color.Green("✅ Backup created successfully")
        }

        configs := detectConfigFiles()
        
        // Parse --only flag if provided
        onlyFlag := c.String("only")
        var allowedFiles map[string]bool
        if onlyFlag != "" {
            allowedFiles = make(map[string]bool)
            parts := strings.Split(onlyFlag, ",")
            for _, part := range parts {
                part = strings.TrimSpace(part)
                // Map common names to actual filenames
                switch part {
                case "gitconfig":
                    allowedFiles[".gitconfig"] = true
                case "zshrc":
                    allowedFiles[".zshrc"] = true
                case "settings.json":
                    allowedFiles["settings.json"] = true
                default:
                    allowedFiles[part] = true
                }
            }
            color.Blue("🎯 Selective apply: only %s", onlyFlag)
        }

        for _, cfg := range configs {
            // Skip if --only flag is used and this file is not included
            if allowedFiles != nil && !allowedFiles[cfg.Name] {
                color.Yellow("⏭️  Skipping %s (not in --only list)", cfg.Name)
                continue
            }

            src := filepath.Join(profPath, cfg.Name)
            if _, err := os.Stat(src); err != nil {
                color.Yellow("⚠️  Skipping %s (not found in profile)", cfg.Name)
                continue
            }
            color.Blue("📋 Applying %s...", cfg.Name)
            if err := copyFile(src, cfg.Src()); err != nil {
                return err
            }
        }

        if err := writeCurrentProfile(profile); err != nil {
            return err
        }

        boxInfo("Profile Applied", fmt.Sprintf("%s\n\n%s", profile, "✅ Done! Please restart your terminal or reload your shell."))
        return nil
    }

    func cmdCreate(c *cli.Context) error {
        if c.Args().Len() == 0 {
            return fmt.Errorf("profile name required")
        }
        profile := c.Args().First()
        profPath := filepath.Join(profilesDir(), profile)
        if _, err := os.Stat(profPath); err == nil {
            return fmt.Errorf("profile %s already exists", profile)
        }
        if err := os.MkdirAll(profPath, 0o755); err != nil {
            return err
        }

        template := c.String("template")
        if template != "" {
            // Create profile from template
            color.Blue("📋 Creating profile from template: %s", template)
            if err := createFromTemplate(profPath, template); err != nil {
                return fmt.Errorf("failed to create from template: %v", err)
            }
            boxInfo("Profile Created", fmt.Sprintf("%s (from %s template)", profile, template))
        } else {
            // Create profile from current configs
            configs := detectConfigFiles()
            for _, cfg := range configs {
                if _, err := os.Stat(cfg.Src()); err == nil {
                    dst := filepath.Join(profPath, cfg.Name)
                    if err := copyFile(cfg.Src(), dst); err != nil {
                        return err
                    }
                }
            }
            boxInfo("Profile Created", profile)
        }
        return nil
    }

    func createFromTemplate(profPath, template string) error {
        templates := map[string]map[string]string{
            "corporate": {
                ".gitconfig": `[user]
    name = Corporate User
    email = user@company.com
[init]
    defaultBranch = main
[pull]
    rebase = false
[core]
    autocrlf = input
    editor = code --wait`,
                ".zshrc": `# Corporate shell configuration
export PATH="/usr/local/bin:$PATH"
export EDITOR="code"

# Company aliases
alias deploy="kubectl apply -f"
alias logs="kubectl logs -f"
alias status="git status"

# Load company-specific configurations
[ -f ~/.company_profile ] && source ~/.company_profile`,
                "settings.json": `{
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "git.confirmSync": false,
    "workbench.colorTheme": "Visual Studio Dark",
    "terminal.integrated.shell.osx": "/bin/zsh"
}`,
                ".npmrc": `registry=https://registry.company.com/
//registry.company.com/:_authToken=your-company-token
save-exact=true`,
                ".env": `NODE_ENV=production
API_URL=https://api.company.com
LOG_LEVEL=info`,
            },
            "personal": {
                ".gitconfig": `[user]
    name = Your Name
    email = your.personal@email.com
[init]
    defaultBranch = main
[pull]
    rebase = true
[core]
    editor = vim`,
                ".zshrc": `# Personal shell configuration
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export EDITOR="vim"

# Personal aliases
alias ll="ls -la"
alias ..="cd .."
alias ...="cd ../.."
alias gs="git status"
alias gp="git pull"

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git docker kubectl)
source $ZSH/oh-my-zsh.sh`,
                "settings.json": `{
    "editor.fontSize": 14,
    "editor.tabSize": 2,
    "workbench.colorTheme": "One Dark Pro",
    "terminal.integrated.fontSize": 12,
    "git.autofetch": true
}`,
                ".npmrc": `registry=https://registry.npmjs.org/
save-exact=false
fund=false`,
                ".env": `NODE_ENV=development
DEBUG=true`,
            },
            "minimal": {
                ".gitconfig": `[user]
    name = User
    email = user@example.com
[init]
    defaultBranch = main`,
                ".zshrc": `# Minimal shell configuration
export PATH="/usr/local/bin:$PATH"
alias ls="ls -G"
alias ll="ls -la"`,
                "settings.json": `{
    "editor.formatOnSave": true,
    "workbench.colorTheme": "Default Dark+"
}`,
            },
        }

        templateData, exists := templates[template]
        if !exists {
            return fmt.Errorf("template '%s' not found. Available templates: corporate, personal, minimal", template)
        }

        for filename, content := range templateData {
            filepath := filepath.Join(profPath, filename)
            if err := os.WriteFile(filepath, []byte(content), 0o644); err != nil {
                return fmt.Errorf("failed to write %s: %v", filename, err)
            }
            color.Green("✅ Created %s", filename)
        }

        return nil
    }

    func cmdBackup(c *cli.Context) error {
        if err := ensureDirs(); err != nil {
            return err
        }
        ts := time.Now().Format("20060102-150405")
        backupDir := filepath.Join(backupsDir(), ts)
        if err := os.MkdirAll(backupDir, 0o755); err != nil {
            return err
        }

        configs := detectConfigFiles()
        for _, cfg := range configs {
            if _, err := os.Stat(cfg.Src()); err == nil {
                dst := filepath.Join(backupDir, cfg.Name)
                if err := copyFile(cfg.Src(), dst); err != nil {
                    return err
                }
            }
        }

        boxInfo("Backup Complete", backupDir)
        return nil
    }

    func getFileHash(filePath string) (string, error) {
        data, err := os.ReadFile(filePath)
        if err != nil {
            return "", err
        }
        hash := md5.Sum(data)
        return fmt.Sprintf("%x", hash), nil
    }

    func cmdDiff(c *cli.Context) error {
        if err := ensureDirs(); err != nil {
            return err
        }

        args := c.Args().Slice()
        if len(args) == 0 {
            return fmt.Errorf("need at least one profile name to compare")
        }

        profile1 := args[0]
        var profile2 string
        var isCurrentConfig bool

        if len(args) == 1 {
            // Compare profile to current config
            isCurrentConfig = true
            profile2 = "current config"
        } else {
            // Compare two profiles
            profile2 = args[1]
        }

        prof1Path := filepath.Join(profilesDir(), profile1)
        if _, err := os.Stat(prof1Path); err != nil {
            return fmt.Errorf("profile %s does not exist", profile1)
        }

        if !isCurrentConfig {
            prof2Path := filepath.Join(profilesDir(), profile2)
            if _, err := os.Stat(prof2Path); err != nil {
                return fmt.Errorf("profile %s does not exist", profile2)
            }
        }

        configs := detectConfigFiles()
        differences := []string{}
        identical := []string{}

        for _, cfg := range configs {
            file1 := filepath.Join(prof1Path, cfg.Name)
            var file2 string
            
            if isCurrentConfig {
                file2 = cfg.Src()
            } else {
                file2 = filepath.Join(profilesDir(), profile2, cfg.Name)
            }

            // Check if files exist
            _, err1 := os.Stat(file1)
            _, err2 := os.Stat(file2)

            if err1 != nil && err2 != nil {
                // Both files don't exist
                identical = append(identical, cfg.Name+" (both missing)")
                continue
            }

            if err1 != nil || err2 != nil {
                // One file exists, other doesn't
                if err1 != nil {
                    differences = append(differences, cfg.Name+" (missing in "+profile1+")")
                } else {
                    differences = append(differences, cfg.Name+" (missing in "+profile2+")")
                }
                continue
            }

            // Both files exist, compare content
            hash1, err := getFileHash(file1)
            if err != nil {
                differences = append(differences, cfg.Name+" (error reading from "+profile1+")")
                continue
            }

            hash2, err := getFileHash(file2)
            if err != nil {
                differences = append(differences, cfg.Name+" (error reading from "+profile2+")")
                continue
            }

            if hash1 == hash2 {
                identical = append(identical, cfg.Name)
            } else {
                differences = append(differences, cfg.Name+" (content differs)")
            }
        }

        // Display results
        diffInfo := fmt.Sprintf("Comparing: %s vs %s\n\n", profile1, profile2)
        
        if len(identical) > 0 {
            diffInfo += color.GreenString("✅ Identical files:\n")
            for _, file := range identical {
                diffInfo += fmt.Sprintf("  • %s\n", file)
            }
            diffInfo += "\n"
        }

        if len(differences) > 0 {
            diffInfo += color.YellowString("⚠️  Different files:\n")
            for _, file := range differences {
                diffInfo += fmt.Sprintf("  • %s\n", file)
            }
        }

        if len(differences) == 0 {
            diffInfo += color.GreenString("🎉 All files are identical!")
        }

        boxInfo("Profile Diff", diffInfo)
        return nil
    }

    func cmdRollback(c *cli.Context) error {
        if err := ensureDirs(); err != nil {
            return err
        }

        backupPath := ""
        if c.Args().Len() > 0 {
            // Specific backup timestamp provided
            timestamp := c.Args().First()
            backupPath = filepath.Join(backupsDir(), timestamp)
            if _, err := os.Stat(backupPath); err != nil {
                return fmt.Errorf("backup %s does not exist", timestamp)
            }
        } else {
            // Find the most recent backup
            entries, err := os.ReadDir(backupsDir())
            if err != nil {
                return fmt.Errorf("error reading backups: %v", err)
            }
            
            if len(entries) == 0 {
                boxInfo("No Backups Found", "No backups available to rollback to")
                return nil
            }

            // Sort entries by name (which are timestamps) to get the latest
            var latestBackup string
            for _, entry := range entries {
                if entry.IsDir() && entry.Name() > latestBackup {
                    latestBackup = entry.Name()
                }
            }
            
            if latestBackup == "" {
                boxInfo("No Valid Backups", "No valid backup directories found")
                return nil
            }

            backupPath = filepath.Join(backupsDir(), latestBackup)
            color.Blue("🔄 Using latest backup: %s", latestBackup)
        }

        // Restore files from backup
        configs := detectConfigFiles()
        restoredCount := 0
        
        for _, cfg := range configs {
            backupFile := filepath.Join(backupPath, cfg.Name)
            if _, err := os.Stat(backupFile); err != nil {
                color.Yellow("⚠️  Skipping %s (not found in backup)", cfg.Name)
                continue
            }
            
            color.Blue("📋 Restoring %s...", cfg.Name)
            if err := copyFile(backupFile, cfg.Src()); err != nil {
                return fmt.Errorf("failed to restore %s: %v", cfg.Name, err)
            }
            restoredCount++
        }

        // Clear current profile since we rolled back
        profileFile := filepath.Join(devDir(), "current_profile.txt")
        if err := os.Remove(profileFile); err != nil && !os.IsNotExist(err) {
            color.Yellow("⚠️  Could not clear current profile: %v", err)
        }

        successMsg := fmt.Sprintf("Restored %d config files from backup\n\n✅ Rollback complete! Please restart your terminal.", restoredCount)
        boxInfo("Rollback Complete", successMsg)
        return nil
    }
