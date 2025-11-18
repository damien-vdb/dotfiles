# Dotfiles

Modular dotfiles management using shell scripts and GNU Stow.

## Structure

```
dotfiles/
├── install.sh              # Main orchestrator
├── base/                   # Core shell configuration
├── git/                    # Git configuration
├── docker/                 # Docker setup
├── go/                     # Go language setup
├── systemd/                # System-level systemd configs
└── [module]/
    ├── install.sh          # Install packages and stow dotfiles
    └── dotfiles/           # Files to be stowed
        ├── .config/
        ├── .bashrc.d/      # Bash-specific configs
        ├── .profile.d/     # Login shell PATH/env vars
        └── etc/            # For system modules
```

## Quick Start

### Install all modules for your hostname

```bash
./install.sh host
```

### Install specific modules

```bash
./install.sh install base git docker
```

### Install on non-apt systems (Fedora, Arch, etc.)

```bash
./install.sh --pm dnf install base git docker
# or
PACKAGE_MANAGER=dnf ./install.sh install base git
```

### List available modules

```bash
./install.sh list
```

## Requirements

- Bash
- sudo access (for system modules and package installation)
- GNU Stow (auto-installed if not present)

## Modules

### base
Core shell configuration with .bashrc and modular .bashrc.d/.profile.d pattern.
- Installs essential packages (curl, vim, jq, yq, glances, htop, btop, gh, stow)
- Sets up .bashrc.d/ for bash-specific configs (aliases, functions)
- Sets up .profile.d/ for login shell PATH and environment variables
- Provides .profile that sources .profile.d/*.sh

### git
Git configuration and aliases.
- Dotfiles: .gitconfig, .bashrc.d/git.sh
- Remember to update .gitconfig with your name and email

### docker
Docker installation and configuration.
- Installs Docker via official script
- Sets up daemon.json with log rotation
- Adds user to docker group
- Dotfiles: .config/docker/, .bashrc.d/docker.sh

### go
Go language installation from official tarball.
- Downloads and installs Go to /usr/local
- Creates Go workspace at ~/go
- Dotfiles: .profile.d/go.sh (sets GOPATH and PATH)

### systemd
System-level systemd configurations (requires sudo).
- Disables NetworkManager-wait-online.service
- Configures apt-daily.timer with custom schedule
- Stows to root (/)

## Host-specific Configuration

Edit `install.sh` to customize which modules are installed per hostname:

```bash
case "$hostname" in
    workstation)
        modules=(base git docker go systemd)
        ;;
    laptop)
        modules=(base git docker go systemd)
        ;;
    homelab)
        modules=(base git docker systemd)
        ;;
esac
```

## Creating a New Module

1. Create module directory:
   ```bash
   mkdir -p mymodule/dotfiles
   ```

2. Create `mymodule/install.sh`:
   ```bash
   #!/bin/bash
   set -e

   MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   PACKAGE_MANAGER="${PACKAGE_MANAGER:-apt}"

   # Install packages
   case "$PACKAGE_MANAGER" in
       apt)
           sudo apt install -y package1 package2
           ;;
       dnf)
           sudo dnf install -y package1 package2
           ;;
   esac

   # Stow dotfiles
   cd "$MODULE_DIR"
   stow --target="$HOME" --dir=. dotfiles

   echo "My module installed!"
   ```

3. Make script executable:
   ```bash
   chmod +x mymodule/install.sh
   ```

4. Add dotfiles to `mymodule/dotfiles/`:
   ```
   mymodule/dotfiles/
   ├── .config/myapp/
   │   └── config.yaml
   ├── .bashrc.d/
   │   └── myapp.sh      # Bash aliases/functions
   └── .profile.d/
       └── myapp.sh      # PATH/environment variables
   ```

## Shell Configuration Pattern

### .bashrc.d/ - Interactive Bash Configuration
For bash-specific aliases, functions, and interactive shell settings:
```bash
mymodule/dotfiles/.bashrc.d/myapp.sh
```

Files here are sourced by `.bashrc` on every interactive bash session.

### .profile.d/ - Login Shell Environment
For PATH modifications and environment variables that should work in all shells:
```bash
mymodule/dotfiles/.profile.d/myapp.sh
```

Files here are sourced by `.profile` on login. Use this pattern for PATH:
```bash
# set PATH so it includes myapp binaries if they exist
if [ -d "/opt/myapp/bin" ] ; then
    PATH="/opt/myapp/bin:$PATH"
fi
```

This ensures PATH is set once at login and inherited by all processes.

## System Modules (Stowing to /)

For system-level configs, use `sudo stow --target=/`:

```bash
mymodule/dotfiles/
└── etc/
    └── myapp/
        └── config.conf
```

When stowed, creates: `/etc/myapp/config.conf -> /home/user/dotfiles/mymodule/dotfiles/etc/myapp/config.conf`

## Package Manager Support

The main script auto-detects and supports:
- **apt** (Debian, Ubuntu) - default
- **dnf** (Fedora, RHEL)
- **pacman** (Arch Linux)

Specify via:
```bash
./install.sh --pm dnf install base
# or
PACKAGE_MANAGER=dnf ./install.sh install base
```

Each module's `install.sh` receives `$PACKAGE_MANAGER` environment variable.

## Tips

- Always run `./install.sh list` to see available modules
- Use `./install.sh host` on new machines for quick setup
- Keep sensitive data (API keys, passwords) out of dotfiles
- Use `git status` to check which files are tracked
- Stow will be auto-installed if missing

## Troubleshooting

### Stow conflicts

If stow reports conflicts, the target file already exists. Either:
- Back up and remove the existing file
- Use `stow --adopt` to adopt existing files (careful!)

### Permission errors

System modules (like systemd) require sudo. Make sure you have sudo access.

### Docker group not taking effect

After docker install, log out and back in, or run:
```bash
newgrp docker
```

### PATH not updated

PATH modifications go in `.profile.d/*.sh`, not `.bashrc.d/*.sh`. Log out and back in for changes to take effect, or run:
```bash
source ~/.profile
```

## License

Your choice of license here.
