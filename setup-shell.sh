#!/usr/bin/env zsh
# Shell environment setup: Powerlevel10k, FZF, SCM Breeze, eza, pyenv
set -e

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo "${GREEN}==>${NC} $*"; }
warn()    { echo "${YELLOW}==> WARN:${NC} $*"; }
success() { echo "${GREEN}==> DONE:${NC} $*"; }

# ── 1. Homebrew ────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for this session (Apple Silicon)
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed — skipping"
fi
success "Homebrew ready"

# ── 2. Core packages ───────────────────────────────────────────────────────────
info "Installing packages: fzf, eza, pyenv, pyenv-virtualenv..."
brew install fzf eza pyenv pyenv-virtualenv
# Install fzf shell keybindings & completions (non-interactive)
"$(brew --prefix fzf)/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
success "Packages installed"

# ── 3. Powerlevel10k ──────────────────────────────────────────────────────────
P10K_DIR="$HOME/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
  info "Powerlevel10k already present — pulling latest..."
  git -C "$P10K_DIR" pull --ff-only
else
  info "Cloning Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi
success "Powerlevel10k ready"

# ── 4. SCM Breeze ─────────────────────────────────────────────────────────────
SCM_DIR="$HOME/.scm_breeze"
if [[ -d "$SCM_DIR" ]]; then
  info "SCM Breeze already present — pulling latest..."
  git -C "$SCM_DIR" pull --ff-only
else
  info "Cloning SCM Breeze..."
  git clone --depth=1 https://github.com/scmbreeze/scm_breeze.git "$SCM_DIR"
fi
# Install creates ~/.scmbrc if missing
"$SCM_DIR/install.sh"
success "SCM Breeze ready"

# ── 5. Write .zshrc ───────────────────────────────────────────────────────────
info "Writing ~/.zshrc..."
cat > "$HOME/.zshrc" << 'ZSHRC'
# ── Powerlevel10k instant prompt ───────────────────────────────────────────────
# Must be near the top, before any output.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── PATH ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# Apple Silicon Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── pyenv ──────────────────────────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# ── FZF ────────────────────────────────────────────────────────────────────────
# Key bindings: Ctrl-R (history), Ctrl-T (files), Alt-C (cd)
if [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
fi
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
# Use fd for FZF file listings if available
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ── eza (modern ls) ────────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --group-directories-first -l --git'
  alias la='eza --icons --group-directories-first -la --git'
  alias lt='eza --icons --tree --level=2'
  alias lta='eza --icons --tree --level=2 -a'
fi

# ── SCM Breeze (git shortcuts) ─────────────────────────────────────────────────
[[ -s "$HOME/.scm_breeze/scm_breeze.sh" ]] && source "$HOME/.scm_breeze/scm_breeze.sh"

# ── Powerlevel10k theme ────────────────────────────────────────────────────────
[[ -f "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]] && \
  source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"

# Load p10k config (run `p10k configure` to create/update it)
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
ZSHRC
success "~/.zshrc written"

echo ""
echo "${GREEN}✓ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart iTerm2 (or run: source ~/.zshrc)"
echo "  2. Run 'p10k configure' to set up your prompt style"
echo "  3. Install a Nerd Font for icons — recommended: MesloLGS NF"
echo "     → iTerm2 Preferences → Profiles → Text → Font"
echo "  4. Download from: https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
