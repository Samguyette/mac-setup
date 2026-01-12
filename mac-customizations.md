# Mac Customizations Documentation

This document captures all custom configurations and settings for this macOS system.

---

## Table of Contents

1. [Shell Configuration (Zsh)](#shell-configuration-zsh)
2. [Powerlevel10k Theme](#powerlevel10k-theme)
3. [Cursor IDE Configuration](#cursor-ide-configuration)
4. [iTerm2 Configuration](#iterm2-configuration)
5. [Installed Fonts](#installed-fonts)
6. [Git Configuration](#git-configuration)
7. [Homebrew Packages](#homebrew-packages)
8. [Python Environment (pyenv)](#python-environment-pyenv)
9. [Additional Tools](#additional-tools)

---

## Shell Configuration (Zsh)

### ~/.zshrc

```zsh
# ------------------------------------------------------------------------------
# Powerlevel10k instant prompt
# ------------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# Powerlevel10k theme
# ------------------------------------------------------------------------------
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ------------------------------------------------------------------------------
# FZF
# ------------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ------------------------------------------------------------------------------
# Load Zsh completion system
# ------------------------------------------------------------------------------
autoload -Uz compinit
compinit

# ------------------------------------------------------------------------------
# SCM Breeze
# ------------------------------------------------------------------------------
[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"

# ------------------------------------------------------------------------------
# Environment and PATH
# ------------------------------------------------------------------------------
. "$HOME/.local/bin/env"

alias ls='eza --icons --oneline'

export PATH="$HOME/.cargo/bin:$PATH"
export AWS_PROFILE=openmail
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

### Key Shell Features

- **Powerlevel10k**: Modern zsh prompt theme with instant prompt support
- **FZF**: Fuzzy finder for command-line
- **SCM Breeze**: Git workflow shortcuts and enhancements
- **eza**: Modern `ls` replacement with icons (aliased to `ls`)
- **pyenv**: Python version management with virtualenv support

---

## Powerlevel10k Theme

### Installation Location
- Main theme: `~/powerlevel10k/`
- Configuration: `~/.p10k.zsh`

### Theme Style
- **Style**: Rainbow (colorful background segments)
- **Font**: Nerd Font v3 with Powerline glyphs
- **Icons**: Small icons enabled
- **Layout**: 2 lines, disconnected, left frame
- **Separators**: Angled with sharp heads, flat tails

### Prompt Elements

**Left Prompt (Line 1):**
- OS icon
- Current directory
- Git status (VCS)

**Right Prompt (Line 1):**
- Exit status
- Command execution time (shows if > 3 seconds)
- Background jobs
- Python environment (pyenv/virtualenv)
- Kubernetes context (on relevant commands)
- AWS profile (on relevant commands)
- Various other environment indicators

### Key Settings
- Transient prompt: **enabled** (cleans up old prompts)
- Instant prompt: **verbose mode**
- Directory max length: 80 characters
- Branch name truncation: 32 characters

### To Reconfigure
Run `p10k configure` to run the configuration wizard again.

---

## Cursor IDE Configuration

### Settings Location
- Settings: `~/Library/Application Support/Cursor/User/settings.json`
- Keybindings: `~/Library/Application Support/Cursor/User/keybindings.json`
- Extensions: `~/.cursor/extensions/`

### settings.json

```json
{
    "window.commandCenter": true,
    "workbench.colorTheme": "Cursor Dark Midnight",
    "problems.decorations.enabled": false,
    "problems.visibility": false,
    "makefile.configureOnOpen": true,
    "git.openRepositoryInParentFolders": "always",
    "workbench.editor.wrapTabs": true,
    "editor.fontFamily": "CaskaydiaMono Nerd Font",
    "editor.inlayHints.fontFamily": "ono",
    "files.autoSave": "onWindowChange",
    "mcpServers": {
        "github": {
            "command": "npx",
            "args": ["-y", "@missionsquad/mcp-github"],
            "env": {
                "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_GITHUB_TOKEN>"
            }
        }
    }
}
```

### Key Settings Explained

| Setting | Value | Description |
|---------|-------|-------------|
| `workbench.colorTheme` | Cursor Dark Midnight | Dark theme |
| `git.openRepositoryInParentFolders` | always | **Opens git repo when clicking files in explorer** |
| `workbench.editor.wrapTabs` | true | Tabs wrap to multiple lines instead of scrolling |
| `editor.fontFamily` | CaskaydiaMono Nerd Font | Nerd font with icons |
| `files.autoSave` | onWindowChange | Auto-saves when switching windows |
| `problems.visibility` | false | Hides problems panel |
| `window.commandCenter` | true | Shows command center in title bar |

### keybindings.json

```json
[
    {
        "key": "cmd+i",
        "command": "composerMode.agent"
    }
]
```

This binds **Cmd+I** to open the AI Composer in agent mode.

### MCP Servers Configuration

GitHub MCP server is configured for AI-assisted GitHub operations.

**Note:** You'll need to generate a new GitHub Personal Access Token on a new machine:
1. Go to GitHub Settings > Developer settings > Personal access tokens
2. Generate a new token with appropriate scopes
3. Update the `GITHUB_PERSONAL_ACCESS_TOKEN` in settings.json

### Installed Extensions

| Extension | Description |
|-----------|-------------|
| **anysphere.cursorpyright** | Python language support |
| **dbaeumer.vscode-eslint** | ESLint integration |
| **eamodio.gitlens** | Git supercharged - blame, history, etc. |
| **esbenp.prettier-vscode** | Code formatter |
| **firsttris.vscode-jest-runner** | Jest test runner |
| **github.vscode-github-actions** | GitHub Actions support |
| **k--kato.intellij-idea-keybindings** | IntelliJ/PyCharm keybindings |
| **mechatroner.rainbow-csv** | CSV/TSV colorization |
| **ms-azuretools.vscode-containers** | Docker containers support |
| **ms-azuretools.vscode-docker** | Docker extension |
| **ms-playwright.playwright** | Playwright testing |
| **ms-python.debugpy** | Python debugger |
| **ms-python.python** | Python extension |
| **ms-vscode.makefile-tools** | Makefile support |
| **nrwl.angular-console** | Nx Console for monorepos |

### Extension Installation Commands

To reinstall extensions on a new machine:
```bash
# Core extensions
cursor --install-extension dbaeumer.vscode-eslint
cursor --install-extension eamodio.gitlens
cursor --install-extension esbenp.prettier-vscode
cursor --install-extension ms-python.python
cursor --install-extension k--kato.intellij-idea-keybindings
cursor --install-extension mechatroner.rainbow-csv
cursor --install-extension ms-azuretools.vscode-docker
cursor --install-extension github.vscode-github-actions
cursor --install-extension nrwl.angular-console
cursor --install-extension ms-playwright.playwright
cursor --install-extension firsttris.vscode-jest-runner
```

### Backup/Restore Cursor Settings

**Export settings:**
```bash
cp ~/Library/Application\ Support/Cursor/User/settings.json ~/cursor-settings.json
cp ~/Library/Application\ Support/Cursor/User/keybindings.json ~/cursor-keybindings.json
```

**Import settings:**
```bash
cp ~/cursor-settings.json ~/Library/Application\ Support/Cursor/User/settings.json
cp ~/cursor-keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
```

---

## iTerm2 Configuration

### Profile Settings

**Font:**
- Primary Font: **CaskaydiaMonoNF-Regular 13pt**
- Non-ASCII Font: Monaco 12pt
- Anti-aliasing: Enabled

**Color Scheme:**
- Custom color preset: **"Cursor Dark"** (installed)
- Background color (dark mode): RGB approximately (0.078, 0.078, 0.078) - very dark gray

### Custom Color Preset: "Cursor Dark"

The "Cursor Dark" color scheme is installed with the following ANSI colors:

| Color | RGB Values |
|-------|------------|
| Black (Ansi 0) | 0.165, 0.165, 0.165 |
| Red (Ansi 1) | 0.749, 0.380, 0.416 |
| Green (Ansi 2) | 0.639, 0.745, 0.549 |
| Yellow (Ansi 3) | 0.922, 0.796, 0.545 |
| Blue (Ansi 4) | 0.506, 0.631, 0.757 |
| Magenta (Ansi 5) | 0.706, 0.557, 0.678 |
| Cyan (Ansi 6) | 0.533, 0.753, 0.816 |
| White (Ansi 15) | 1.0, 1.0, 1.0 |

### AI Features Enabled
- AI Model: gpt-4.1
- AI Terminal features enabled (Function calling, web search, code interpreter)
- Max tokens: 1,000,000

### Exporting iTerm2 Settings
To export your complete iTerm2 preferences:
```bash
defaults export com.googlecode.iterm2 ~/iterm2-preferences.plist
```

To import on a new machine:
```bash
defaults import com.googlecode.iterm2 ~/iterm2-preferences.plist
```

---

## Installed Fonts

Located in `~/Library/Fonts/`:

| Font | Description |
|------|-------------|
| **CaskaydiaMonoNerdFont-Regular.ttf** | Primary terminal font (Cascadia Code + Nerd Font icons) |
| **MesloLGS NF Regular.ttf** | Recommended Powerlevel10k font |
| **MesloLGS NF Bold.ttf** | Bold variant |
| **MesloLGS NF Italic.ttf** | Italic variant |
| **MesloLGS NF Bold Italic.ttf** | Bold italic variant |

### Font Installation
Download links:
- [Caskaydia Cove Nerd Font](https://www.nerdfonts.com/font-downloads) - Search for "CaskaydiaCove"
- MesloLGS NF - Typically installed via `p10k configure` wizard

---

## Git Configuration

### ~/.gitconfig

```ini
[filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true

[user]
    name = samguyette-s1
    email = sam.guyette@system1.com

[core]
    excludesFile = /Users/sam.guyette/.gitignore_global
```

### ~/.gitignore_global

```
**/.cursor
**/thoughts
**/.vscode
```

---

## Homebrew Packages

### Core CLI Tools
```bash
brew install coreutils eza fzf gh htop jq ncdu neovim tmux tree watch
```

### Development Tools
```bash
brew install black cmake gcc pyenv pyenv-virtualenv pipx node yarn
```

### Database Tools
```bash
brew install duckdb mysql postgresql@14 postgresql@16 redis sqlite
```

### Kubernetes/DevOps
```bash
brew install argocd helm k9s kustomize
```

### Other Tools
```bash
brew install archey4 mosh protobuf
```

### Complete Package List
```
abseil          gcc             libmpc          ncdu            python@3.12
alembic         gettext         libnghttp2      ncurses         python@3.13
archey4         gh              libomp          neovim          python@3.14
argocd          gmp             libssh2         netron          readline
astro           hdf5            libunistring    node            redis
autoconf        helm            libuv           oniguruma       sqlite
black           htop            lpeg            openssl@3       tmux
brotli          icu4c@76        luajit          pipx            tree
c-ares          icu4c@77        luv             pkgconf         tree-sitter
ca-certificates imath           lz4             postgresql@14   unibilium
cmake           isl             m4              postgresql@16   utf8proc
coreutils       jq              mosh            protobuf        watch
duckdb          jsoncpp         mpdecimal       pyenv           xz
eza             k9s             mpfr            pyenv-virtualenv yarn
fzf             krb5            mysql           python@3.12     zlib
                kustomize                                       zstd
```

---

## Python Environment (pyenv)

### Installed Versions
```
* system (default)
  3.12.11
  3.12.11/envs/pub-activation-3.12.11
  pub-activation-3.12.11 -> ~/.pyenv/versions/3.12.11/envs/pub-activation-3.12.11
```

### Key Configuration (in .zshrc)
```bash
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

### Creating New Environments
```bash
# Install a new Python version
pyenv install 3.12.11

# Create a virtualenv
pyenv virtualenv 3.12.11 my-project-env

# Activate in a directory
pyenv local my-project-env
```

---

## Additional Tools

### SCM Breeze
Git workflow enhancement tool with shortcuts.

**Installation:**
```bash
git clone https://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze
~/.scm_breeze/install.sh
```

**Key Features:**
- Numbered file shortcuts in git status
- Quick staging with numbers: `ga 1 2 3`
- Repository index for quick navigation

### FZF (Fuzzy Finder)

**Configuration (~/.fzf.zsh):**
```bash
# Setup fzf
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

source <(fzf --zsh)
```

### Local Bin Path

**~/.local/bin/env:**
```bash
#!/bin/sh
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac
```

---

## Restoration Checklist

### Automated Setup Script

Run the setup script to install everything automatically:

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/YOUR_REPO/mac-setup.sh -o mac-setup.sh
bash mac-setup.sh
```

Or if you have the script locally:

```bash
bash mac-setup.sh
```

The script (`mac-setup.sh`) handles all of the following automatically.

### Manual Steps (if not using the script)

To set up a new Mac with these customizations:

1. **Install Homebrew:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install packages:**
   ```bash
   brew install coreutils eza fzf gh htop jq neovim pyenv pyenv-virtualenv tmux tree
   brew install argocd helm k9s kustomize
   brew install postgresql@14 redis sqlite duckdb
   ```

3. **Install Powerlevel10k:**
   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
   ```

4. **Install SCM Breeze:**
   ```bash
   git clone https://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze
   ~/.scm_breeze/install.sh
   ```

5. **Install fonts:**
   - Download from Nerd Fonts and place in `~/Library/Fonts/`

6. **Copy configuration files:**
   - `~/.zshrc`
   - `~/.p10k.zsh`
   - `~/.gitconfig`
   - `~/.gitignore_global`
   - Cursor settings (see step 9)

7. **Import iTerm2 preferences:**
   ```bash
   defaults import com.googlecode.iterm2 ~/iterm2-preferences.plist
   ```

8. **Configure Powerlevel10k:**
   ```bash
   p10k configure
   ```

9. **Install Cursor and restore settings:**
   - Download Cursor from https://cursor.sh
   - Copy settings files:
     ```bash
     cp ~/cursor-settings.json ~/Library/Application\ Support/Cursor/User/settings.json
     cp ~/cursor-keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
     ```
   - Install extensions (see Cursor section above)
   - Generate new GitHub token and update settings

---

## File Locations Summary

| File | Purpose |
|------|---------|
| `~/.zshrc` | Main shell configuration |
| `~/.p10k.zsh` | Powerlevel10k theme configuration |
| `~/.gitconfig` | Git global configuration |
| `~/.gitignore_global` | Global git ignore patterns |
| `~/.fzf.zsh` | FZF configuration |
| `~/.local/bin/env` | Local bin PATH setup |
| `~/.scm_breeze/` | SCM Breeze installation |
| `~/powerlevel10k/` | Powerlevel10k theme |
| `~/Library/Fonts/` | Custom terminal fonts |
| `~/Library/Application Support/Cursor/User/settings.json` | Cursor IDE settings |
| `~/Library/Application Support/Cursor/User/keybindings.json` | Cursor keybindings |
| `~/.cursor/extensions/` | Cursor extensions |

---

*Document generated: December 2024*

