#!/bin/bash

# =============================================================================
# Mac Setup Script
# =============================================================================
# This script sets up a new Mac with all customizations.
# Run with: bash mac-setup.sh
#
# Note: You may be prompted for your password for certain operations.
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}=================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}=================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is intended for macOS only."
    exit 1
fi

print_header "Starting Mac Setup"

# =============================================================================
# 1. Install Xcode Command Line Tools
# =============================================================================
print_header "Installing Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
    print_success "Xcode Command Line Tools already installed"
else
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode installation popup, then press Enter to continue..."
    read -r
fi

# =============================================================================
# 2. Install Homebrew
# =============================================================================
print_header "Installing Homebrew"

if command -v brew &>/dev/null; then
    print_success "Homebrew already installed"
else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    print_success "Homebrew installed"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update

# =============================================================================
# 3. Install Homebrew Packages
# =============================================================================
print_header "Installing Homebrew Packages"

# Core CLI Tools
CORE_PACKAGES=(
    coreutils
    eza
    fzf
    gh
    htop
    jq
    ncdu
    neovim
    tmux
    tree
    watch
)

# Development Tools
DEV_PACKAGES=(
    black
    cmake
    gcc
    pyenv
    pyenv-virtualenv
    pipx
    node
    yarn
)

# Database Tools
DB_PACKAGES=(
    duckdb
    mysql
    postgresql@14
    postgresql@16
    redis
    sqlite
)

# Kubernetes/DevOps
DEVOPS_PACKAGES=(
    argocd
    helm
    k9s
    kustomize
)

# Other Tools
OTHER_PACKAGES=(
    archey4
    mosh
    protobuf
)

# Combine all packages
ALL_PACKAGES=(
    "${CORE_PACKAGES[@]}"
    "${DEV_PACKAGES[@]}"
    "${DB_PACKAGES[@]}"
    "${DEVOPS_PACKAGES[@]}"
    "${OTHER_PACKAGES[@]}"
)

for package in "${ALL_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
        print_success "$package already installed"
    else
        print_info "Installing $package..."
        brew install "$package" || print_warning "Failed to install $package"
    fi
done

# =============================================================================
# 4. Install Fonts
# =============================================================================
print_header "Installing Fonts"

FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

# Caskaydia Cove Nerd Font
if [[ -f "$FONT_DIR/CaskaydiaMonoNerdFont-Regular.ttf" ]]; then
    print_success "Caskaydia Mono Nerd Font already installed"
else
    print_info "Downloading Caskaydia Cove Nerd Font..."
    TEMP_DIR=$(mktemp -d)
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaMono.zip" -o "$TEMP_DIR/CascadiaMono.zip"
    unzip -q "$TEMP_DIR/CascadiaMono.zip" -d "$TEMP_DIR/CascadiaMono"
    cp "$TEMP_DIR/CascadiaMono/"*.ttf "$FONT_DIR/" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
    print_success "Caskaydia Cove Nerd Font installed"
fi

# MesloLGS NF (for Powerlevel10k)
MESLO_FONTS=(
    "MesloLGS%20NF%20Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf"
)

for font in "${MESLO_FONTS[@]}"; do
    decoded_font=$(echo "$font" | sed 's/%20/ /g')
    if [[ -f "$FONT_DIR/$decoded_font" ]]; then
        print_success "$decoded_font already installed"
    else
        print_info "Downloading $decoded_font..."
        curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/$font" -o "$FONT_DIR/$decoded_font"
        print_success "$decoded_font installed"
    fi
done

# =============================================================================
# 5. Install Powerlevel10k
# =============================================================================
print_header "Installing Powerlevel10k"

if [[ -d "$HOME/powerlevel10k" ]]; then
    print_success "Powerlevel10k already installed"
else
    print_info "Cloning Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    print_success "Powerlevel10k installed"
fi

# =============================================================================
# 6. Install SCM Breeze
# =============================================================================
print_header "Installing SCM Breeze"

if [[ -d "$HOME/.scm_breeze" ]]; then
    print_success "SCM Breeze already installed"
else
    print_info "Cloning SCM Breeze..."
    git clone https://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze
    ~/.scm_breeze/install.sh
    print_success "SCM Breeze installed"
fi

# =============================================================================
# 7. Setup FZF
# =============================================================================
print_header "Setting up FZF"

if [[ -f "$HOME/.fzf.zsh" ]]; then
    print_success "FZF already configured"
else
    print_info "Configuring FZF..."
    # Run FZF install script if available
    if [[ -f "/opt/homebrew/opt/fzf/install" ]]; then
        /opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    elif [[ -f "/usr/local/opt/fzf/install" ]]; then
        /usr/local/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    fi
    print_success "FZF configured"
fi

# =============================================================================
# 8. Create Configuration Files
# =============================================================================
print_header "Creating Configuration Files"

# Create ~/.local/bin/env
print_info "Creating ~/.local/bin/env..."
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/env" << 'EOF'
#!/bin/sh
# add binaries to PATH if they aren't added yet
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed binary needs to be overridden
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac
EOF
chmod +x "$HOME/.local/bin/env"
print_success "Created ~/.local/bin/env"

# Create ~/.fzf.zsh
print_info "Creating ~/.fzf.zsh..."
cat > "$HOME/.fzf.zsh" << 'EOF'
# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

source <(fzf --zsh)
EOF
print_success "Created ~/.fzf.zsh"

# Create ~/.gitconfig
print_info "Creating ~/.gitconfig..."
cat > "$HOME/.gitconfig" << 'EOF'
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
[user]
	name = samguyette-s1
	email = sam.guyette@system1.com
[core]
	excludesFile = ~/.gitignore_global
EOF
print_success "Created ~/.gitconfig"
print_warning "Remember to update git user.name and user.email if needed!"

# Create ~/.gitignore_global
print_info "Creating ~/.gitignore_global..."
cat > "$HOME/.gitignore_global" << 'EOF'
**/.cursor
**/thoughts
**/.vscode
EOF
print_success "Created ~/.gitignore_global"

# Create ~/.zshrc
print_info "Creating ~/.zshrc..."
cat > "$HOME/.zshrc" << 'EOF'
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
EOF
print_success "Created ~/.zshrc"

# =============================================================================
# 9. Create Powerlevel10k Configuration
# =============================================================================
print_header "Creating Powerlevel10k Configuration"

print_info "Creating ~/.p10k.zsh..."
cat > "$HOME/.p10k.zsh" << 'P10KEOF'
# Generated by Powerlevel10k configuration wizard on 2025-10-17 at 11:05 PDT.
# Based on romkatv/powerlevel10k/config/p10k-rainbow.zsh, checksum 49619.
# Wizard options: nerdfont-v3 + powerline, small icons, rainbow, unicode,
# angled separators, sharp heads, flat tails, 2 lines, disconnected, left frame,
# dark-ornaments, sparse, many icons, concise, transient_prompt, instant_prompt=verbose.
# Type `p10k configure` to generate another config.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
    newline
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    direnv
    asdf
    virtualenv
    anaconda
    pyenv
    goenv
    nodenv
    nvm
    nodeenv
    rbenv
    rvm
    fvm
    luaenv
    jenv
    plenv
    perlbrew
    phpenv
    scalaenv
    haskell_stack
    kubecontext
    terraform
    aws
    aws_eb_env
    azure
    gcloud
    google_app_cred
    toolbox
    context
    nordvpn
    ranger
    yazi
    nnn
    lf
    xplr
    vim_shell
    midnight_commander
    nix_shell
    chezmoi_shell
    vi_mode
    todo
    timewarrior
    taskwarrior
    per_directory_history
    newline
  )

  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%240F╭─'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%240F├─'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%240F╰─'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_BACKGROUND=
  if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=240
    typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  fi

  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B1'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B3'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B2'

  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B2'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7

  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=250
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .bzr .citc .git .hg .node-version .python-version .go-version .ruby-version
    .lua-version .java-version .perl-version .php-version .tool-versions .mise.toml
    .shorten_folder_marker .svn .terraform CVS Cargo.toml composer.json go.mod
    package.json stack.yaml
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=8
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi
    local       meta='%7F'
    local      clean='%0F'
    local   modified='%0F'
    local  untracked='%0F'
    local conflicted='%1F'
    local res
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi
    if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"
      res+="${meta}#${clean}${tag//\%/%%}"
    fi
    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"
    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi
    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+=" ${modified}wip"
    fi
    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    fi
    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"
    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=2
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=0
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=2
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND=0
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=3
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=3
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=3
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_BACKGROUND=1

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=6
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=0
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false

  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=0
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=4
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=0
  typeset -g POWERLEVEL9K_PYENV_BACKGROUND=4
  typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION='${P9K_CONTENT}${${P9K_CONTENT:#$P9K_PYENV_PYTHON_VERSION(|/*)}:+ $P9K_PYENV_PYTHON_VERSION}'

  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold|kubent|kubecolor|cmctl|sparkctl'
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=('*' DEFAULT)
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=7
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_BACKGROUND=5
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION=
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'

  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|cdk|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AWS_CLASSES=('*' DEFAULT)
  typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=7
  typeset -g POWERLEVEL9K_AWS_DEFAULT_BACKGROUND=1
  typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'

  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=1
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=0
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=3
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_BACKGROUND=0
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=0
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
P10KEOF
print_success "Created ~/.p10k.zsh"

# =============================================================================
# 10. Setup Cursor IDE
# =============================================================================
print_header "Setting up Cursor IDE"

CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

if [[ -d "$CURSOR_USER_DIR" ]]; then
    print_info "Creating Cursor settings..."
    
    # Create settings.json
    cat > "$CURSOR_USER_DIR/settings.json" << 'EOF'
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
                "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
            }
        }
    }
}
EOF
    print_success "Created Cursor settings.json"
    print_warning "Remember to update GITHUB_PERSONAL_ACCESS_TOKEN in Cursor settings!"

    # Create keybindings.json
    cat > "$CURSOR_USER_DIR/keybindings.json" << 'EOF'
[
    {
        "key": "cmd+i",
        "command": "composerMode.agent"
    }
]
EOF
    print_success "Created Cursor keybindings.json"
else
    print_warning "Cursor not installed yet. Install Cursor from https://cursor.sh"
    print_info "After installing Cursor, run this script again or manually copy settings."
    
    # Create a backup location for settings
    mkdir -p "$HOME/.cursor-settings-backup"
    
    cat > "$HOME/.cursor-settings-backup/settings.json" << 'EOF'
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
                "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
            }
        }
    }
}
EOF

    cat > "$HOME/.cursor-settings-backup/keybindings.json" << 'EOF'
[
    {
        "key": "cmd+i",
        "command": "composerMode.agent"
    }
]
EOF
    print_info "Cursor settings saved to ~/.cursor-settings-backup/"
    print_info "Copy them to ~/Library/Application Support/Cursor/User/ after installing Cursor"
fi

# =============================================================================
# 11. Install Python with pyenv
# =============================================================================
print_header "Setting up Python with pyenv"

# Initialize pyenv for this script
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

PYTHON_VERSION="3.12.11"

if pyenv versions | grep -q "$PYTHON_VERSION"; then
    print_success "Python $PYTHON_VERSION already installed"
else
    print_info "Installing Python $PYTHON_VERSION (this may take a while)..."
    pyenv install "$PYTHON_VERSION" || print_warning "Failed to install Python $PYTHON_VERSION"
fi

# =============================================================================
# 12. Final Steps
# =============================================================================
print_header "Final Steps"

print_success "Setup complete!"
echo ""
echo -e "${YELLOW}Manual steps required:${NC}"
echo ""
echo "1. Restart your terminal or run: source ~/.zshrc"
echo ""
echo "2. Configure Powerlevel10k (optional - settings already applied):"
echo "   Run: p10k configure"
echo ""
echo "3. Install Cursor IDE from https://cursor.sh"
echo "   Then copy settings from ~/.cursor-settings-backup/ if needed"
echo ""
echo "4. Update git config with your name/email if different:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your.email@example.com\""
echo ""
echo "5. Generate a GitHub Personal Access Token and update Cursor settings:"
echo "   GitHub Settings > Developer settings > Personal access tokens"
echo ""
echo "6. Import iTerm2 preferences (if you have the backup):"
echo "   defaults import com.googlecode.iterm2 ~/iterm2-preferences.plist"
echo ""
echo "7. Set iTerm2 font to 'CaskaydiaMono Nerd Font' or 'MesloLGS NF'"
echo "   iTerm2 > Preferences > Profiles > Text > Font"
echo ""
echo "8. Install Cursor extensions:"
echo "   cursor --install-extension eamodio.gitlens"
echo "   cursor --install-extension esbenp.prettier-vscode"
echo "   cursor --install-extension ms-python.python"
echo "   cursor --install-extension k--kato.intellij-idea-keybindings"
echo "   cursor --install-extension dbaeumer.vscode-eslint"
echo "   cursor --install-extension mechatroner.rainbow-csv"
echo "   cursor --install-extension ms-azuretools.vscode-docker"
echo "   cursor --install-extension github.vscode-github-actions"
echo "   cursor --install-extension nrwl.angular-console"
echo ""
print_success "Happy coding!"

