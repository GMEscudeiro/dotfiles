#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — Ubuntu fresh install setup
# Tools: alacritty · atuin · i3 · nvim · picom · polybar · rofi · tmux · zsh
#        p10k · tmux-sessionizer · chezmoi
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
log()     { echo -e "${BLUE}${BOLD}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}${BOLD}[ OK ]${NC}  $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}${BOLD}[ERR ]${NC}  $*" >&2; }
section() { echo -e "\n${CYAN}${BOLD}══════════════════════════════════════${NC}"; \
            echo -e "${CYAN}${BOLD}  $*${NC}"; \
            echo -e "${CYAN}${BOLD}══════════════════════════════════════${NC}\n"; }

confirm() {
  local msg="$1"
  read -rp "$(echo -e "${YELLOW}${BOLD}[?]${NC} ${msg} [y/N] ")" ans
  [[ "${ans,,}" == "y" ]]
}

require_non_root() {
  if [[ "$EUID" -eq 0 ]]; then
    error "Não rode este script como root. Use seu usuário normal."
    error "O sudo será solicitado quando necessário."
    exit 1
  fi
}

check_ubuntu() {
  if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
    warn "Sistema não detectado como Ubuntu. Continuando mesmo assim..."
  fi
}

# ── Variáveis configuráveis ───────────────────────────────────────────────────
CHEZMOI_REPO="${CHEZMOI_REPO:-}"           # ex: https://github.com/user/dotfiles
NVIM_VERSION="${NVIM_VERSION:-v0.11.0}"    # versão do Neovim (AppImage)
GO_VERSION="${GO_VERSION:-1.22.4}"         # versão do Go (para atuin se necessário)

LOG_FILE="$HOME/bootstrap_$(date +%Y%m%d_%H%M%S).log"

# Redireciona stderr para log mas mantém stdout no terminal
exec 2> >(tee -a "$LOG_FILE" >&2)

# =============================================================================
# INÍCIO
# =============================================================================

require_non_root
check_ubuntu

section "Bootstrap — Ubuntu Fresh Install"
log "Log salvo em: $LOG_FILE"
echo ""

# Pede repo do chezmoi se não foi setado como env var
if [[ -z "$CHEZMOI_REPO" ]]; then
  read -rp "$(echo -e "${YELLOW}${BOLD}[?]${NC} URL do seu repositório chezmoi (Enter para pular): ")" CHEZMOI_REPO
fi

# =============================================================================
# 1. ATUALIZAÇÃO DO SISTEMA
# =============================================================================
section "1/10 · Atualização do sistema"

log "Atualizando apt..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
ok "Sistema atualizado."

# =============================================================================
# 2. DEPENDÊNCIAS BASE
# =============================================================================
section "2/10 · Dependências base"

BASE_DEPS=(
  # build / utilitários
  build-essential git curl wget unzip tar xz-utils file
  ca-certificates gnupg lsb-release software-properties-common apt-transport-https

  # X11 / desktop
  xorg xinit x11-xserver-utils xclip xdotool
  libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev

  # fontes e ícones
  fonts-font-awesome fonts-noto-color-emoji

  # misc
  fd-find ripgrep fzf bat jq htop tree stow
)

log "Instalando dependências base (${#BASE_DEPS[@]} pacotes)..."
sudo apt-get install -y -qq "${BASE_DEPS[@]}"
ok "Dependências base instaladas."

# fd-find tem binário como fdfind no Ubuntu
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
  ok "Symlink fd → fdfind criado."
fi

# =============================================================================
# 3. i3 + PICOM + POLYBAR + ROFI + ALACRITTY
# =============================================================================
section "3/10 · i3wm · Picom · Polybar · Rofi · Alacritty"

# ── i3 ────────────────────────────────────────────────────────────────────────
log "Instalando i3..."
sudo apt-get install -y -qq \
  i3 i3status i3lock xss-lock \
  dunst libnotify-bin \
  arandr autorandr \
  lxpolkit \
  network-manager-gnome \
  pavucontrol pulseaudio-utils
ok "i3 instalado."

# ── Picom ─────────────────────────────────────────────────────────────────────
log "Instalando Picom..."
sudo apt-get install -y -qq picom || {
  warn "picom não disponível via apt, compilando do fonte..."
  sudo apt-get install -y -qq \
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev \
    libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev \
    libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev \
    libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev \
    libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev \
    libxcb-xfixes0-dev meson ninja-build uthash-dev
  tmp=$(mktemp -d)
  git clone --depth=1 https://github.com/yshui/picom "$tmp/picom"
  cd "$tmp/picom"
  meson setup --buildtype=release build
  ninja -C build
  sudo ninja -C build install
  cd - > /dev/null
  ok "Picom compilado e instalado."
}

# ── Polybar ───────────────────────────────────────────────────────────────────
log "Instalando Polybar..."
sudo apt-get install -y -qq polybar || {
  warn "polybar não disponível via apt, compilando do fonte..."
  sudo apt-get install -y -qq \
    cmake cmake-data pkg-config python3-sphinx python3-packaging \
    libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev \
    libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev \
    libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev \
    libxcb-cursor-dev libasound2-dev libpulse-dev libnl-genl-3-dev \
    libmpdclient-dev libuv1-dev libjsoncpp-dev
  tmp=$(mktemp -d)
  git clone --recursive --depth=1 https://github.com/polybar/polybar "$tmp/polybar"
  mkdir "$tmp/polybar/build"
  cmake -S "$tmp/polybar" -B "$tmp/polybar/build" -DCMAKE_BUILD_TYPE=Release
  make -C "$tmp/polybar/build" -j"$(nproc)"
  sudo make -C "$tmp/polybar/build" install
  ok "Polybar compilado e instalado."
}

# ── Rofi ──────────────────────────────────────────────────────────────────────
log "Instalando Rofi..."
sudo apt-get install -y -qq rofi
ok "Rofi instalado."

# ── Alacritty ─────────────────────────────────────────────────────────────────
log "Instalando Alacritty..."
if command -v alacritty &>/dev/null; then
  ok "Alacritty já instalado ($(alacritty --version | head -1))."
else
  # Tenta via snap primeiro (mais simples)
  if command -v snap &>/dev/null; then
    sudo snap install alacritty --classic && ok "Alacritty instalado via snap." || true
  fi

  # Fallback: compilar via cargo
  if ! command -v alacritty &>/dev/null; then
    warn "Compilando Alacritty via cargo..."
    sudo apt-get install -y -qq \
      cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev \
      libxcb-xfixes0-dev libxkbcommon-dev python3

    # Garante que cargo está disponível (ver seção ZSH/Rust)
    if ! command -v cargo &>/dev/null; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
      source "$HOME/.cargo/env"
    fi

    cargo install alacritty
    ok "Alacritty compilado e instalado."
  fi
fi

# =============================================================================
# 4. ZSH + POWERLEVEL10K
# =============================================================================
section "4/10 · Zsh · Oh-My-Zsh · Powerlevel10k"

log "Instalando Zsh..."
sudo apt-get install -y -qq zsh
ok "Zsh instalado."

# Muda shell padrão
if [[ "$SHELL" != "$(which zsh)" ]]; then
  log "Alterando shell padrão para zsh..."
  chsh -s "$(which zsh)"
  ok "Shell padrão alterado (efetivo após logout)."
fi

# Oh-My-Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Instalando Oh-My-Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh-My-Zsh instalado."
else
  ok "Oh-My-Zsh já instalado."
fi

# Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  log "Instalando Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  ok "Powerlevel10k instalado."
else
  ok "Powerlevel10k já instalado."
fi

# Plugins zsh úteis
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_PLUGINS=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
)
for plugin_repo in "${ZSH_PLUGINS[@]}"; do
  plugin_name="${plugin_repo##*/}"
  plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
  if [[ ! -d "$plugin_dir" ]]; then
    log "Instalando plugin zsh: $plugin_name..."
    git clone --depth=1 "https://github.com/$plugin_repo" "$plugin_dir"
    ok "$plugin_name instalado."
  else
    ok "$plugin_name já instalado."
  fi
done

# Fontes MesloLGS (necessárias para p10k)
log "Instalando fontes MesloLGS NF para Powerlevel10k..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
MESLO_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"
for font in \
  "MesloLGS NF Regular.ttf" \
  "MesloLGS NF Bold.ttf" \
  "MesloLGS NF Italic.ttf" \
  "MesloLGS NF Bold Italic.ttf"; do
  font_file="$FONT_DIR/$font"
  if [[ ! -f "$font_file" ]]; then
    wget -q -O "$font_file" "$MESLO_BASE/${font// /%20}"
  fi
done
fc-cache -f "$FONT_DIR"
ok "Fontes MesloLGS instaladas."

# =============================================================================
# 5. TMUX + TMUX PLUGIN MANAGER + SESSIONIZER
# =============================================================================
section "5/10 · Tmux · TPM · Tmux-Sessionizer"

log "Instalando Tmux..."
sudo apt-get install -y -qq tmux
ok "Tmux $(tmux -V) instalado."

# TPM
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  log "Instalando Tmux Plugin Manager (TPM)..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "TPM instalado."
else
  ok "TPM já instalado."
fi

# tmux-sessionizer (ThePrimeagen)
SESSIONIZER_BIN="$HOME/.local/bin/tmux-sessionizer"
if [[ ! -f "$SESSIONIZER_BIN" ]]; then
  log "Instalando tmux-sessionizer..."
  mkdir -p "$HOME/.local/bin"
  curl -fsSL \
    "https://raw.githubusercontent.com/ThePrimeagen/tmux-sessionizer/master/tmux-sessionizer" \
    -o "$SESSIONIZER_BIN"
  chmod +x "$SESSIONIZER_BIN"
  ok "tmux-sessionizer instalado em $SESSIONIZER_BIN."
else
  ok "tmux-sessionizer já instalado."
fi

# =============================================================================
# 6. NEOVIM
# =============================================================================
section "6/10 · Neovim ${NVIM_VERSION}"

if command -v nvim &>/dev/null; then
  INSTALLED_VER="$(nvim --version | head -1 | awk '{print $2}')"
  ok "Neovim já instalado: $INSTALLED_VER"
  if [[ "$INSTALLED_VER" != "$NVIM_VERSION" ]]; then
    warn "Versão instalada ($INSTALLED_VER) ≠ desejada ($NVIM_VERSION)."
    if confirm "Reinstalar Neovim $NVIM_VERSION?"; then
      sudo rm -f /usr/local/bin/nvim
    else
      NVIM_VERSION="$INSTALLED_VER"
    fi
  fi
fi

if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -1 | awk '{print $2}')" != "$NVIM_VERSION" ]]; then
  log "Baixando Neovim $NVIM_VERSION (AppImage)..."
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
  curl -fsSL "$NVIM_URL" -o /tmp/nvim.appimage
  chmod +x /tmp/nvim.appimage

  # Extrai AppImage (evita problemas com FUSE em containers/VMs)
  /tmp/nvim.appimage --appimage-extract &>/dev/null
  sudo mv squashfs-root /opt/nvim
  sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim
  rm -f /tmp/nvim.appimage
  ok "Neovim $(nvim --version | head -1) instalado."
fi

# Dependências do Neovim / LSPs / formatters
log "Instalando dependências para Neovim (Node, Python, Lua)..."
sudo apt-get install -y -qq python3-pip python3-venv luarocks

# Node.js via nvm
if ! command -v node &>/dev/null; then
  log "Instalando Node.js via nvm..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
  nvm install --lts
  ok "Node.js $(node --version) instalado via nvm."
else
  ok "Node.js já instalado: $(node --version)."
fi

# npm globals úteis para LSPs
if command -v npm &>/dev/null; then
  log "Instalando LSP servers via npm..."
  npm install -g \
    neovim \
    pyright \
    typescript typescript-language-server \
    bash-language-server \
    prettier \
    @fsouza/prettierd \
    2>/dev/null || warn "Alguns pacotes npm falharam (não crítico)."
fi

# pip para neovim
pip3 install --user --quiet neovim pynvim 2>/dev/null || true

# =============================================================================
# 7. RUST + CARGO (necessário para atuin e alacritty)
# =============================================================================
section "7/10 · Rust · Cargo"

if command -v cargo &>/dev/null; then
  ok "Rust já instalado: $(rustc --version)."
else
  log "Instalando Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path --default-toolchain stable
  ok "Rust instalado."
fi

# Carrega cargo no PATH desta sessão
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# =============================================================================
# 8. ATUIN
# =============================================================================
section "8/10 · Atuin (shell history)"

if command -v atuin &>/dev/null; then
  ok "Atuin já instalado: $(atuin --version)."
else
  log "Instalando Atuin..."
  # Instalador oficial
  curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | bash || {
    warn "Instalador oficial falhou, tentando via cargo..."
    cargo install atuin
  }
  ok "Atuin instalado."
fi

# =============================================================================
# 9. FERRAMENTAS EXTRAS
# =============================================================================
section "9/10 · Ferramentas extras"

EXTRA_TOOLS=(
  # sistema
  brightnessctl playerctl
  # utilitários TUI
  lazygit
  # clipboard
  xdotool xclip
  # imagens / wallpaper
  feh imagemagick
  # misc
  ranger trash-cli
)

log "Instalando ferramentas extras..."
# Algumas podem não estar no apt de versões mais antigas
for tool in "${EXTRA_TOOLS[@]}"; do
  sudo apt-get install -y -qq "$tool" 2>/dev/null \
    && ok "$tool instalado." \
    || warn "$tool não encontrado no apt, pulando."
done

# lazygit via release binário se não veio pelo apt
if ! command -v lazygit &>/dev/null; then
  log "Instalando lazygit manualmente..."
  LG_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
  curl -fsSLo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VERSION}_Linux_x86_64.tar.gz"
  tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
  ok "lazygit $LG_VERSION instalado."
fi

# =============================================================================
# 10. CHEZMOI + DOTFILES
# =============================================================================
section "10/10 · Chezmoi + Dotfiles"

if command -v chezmoi &>/dev/null; then
  ok "Chezmoi já instalado: $(chezmoi --version)."
else
  log "Instalando chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  ok "Chezmoi instalado."
fi

# Garante ~/.local/bin no PATH desta sessão
export PATH="$HOME/.local/bin:$PATH"

# Aplica dotfiles
if [[ -n "$CHEZMOI_REPO" ]]; then
  if [[ -d "$HOME/.local/share/chezmoi/.git" ]]; then
    log "Repositório chezmoi já inicializado. Atualizando..."
    chezmoi update
    ok "Dotfiles atualizados."
  else
    log "Inicializando chezmoi com $CHEZMOI_REPO..."
    chezmoi init --apply "$CHEZMOI_REPO"
    ok "Dotfiles aplicados."
  fi
else
  warn "Nenhum repositório chezmoi informado. Rode manualmente:"
  warn "  chezmoi init --apply <seu-repo>"
fi

# =============================================================================
# RESUMO FINAL
# =============================================================================
section "✅ Bootstrap concluído!"

echo -e "${BOLD}Ferramentas instaladas:${NC}"
declare -A TOOLS=(
  ["alacritty"]="alacritty --version"
  ["atuin"]="atuin --version"
  ["i3"]="i3 --version"
  ["nvim"]="nvim --version"
  ["picom"]="picom --version"
  ["polybar"]="polybar --version"
  ["rofi"]="rofi -version"
  ["tmux"]="tmux -V"
  ["zsh"]="zsh --version"
  ["chezmoi"]="chezmoi --version"
  ["cargo"]="cargo --version"
  ["node"]="node --version"
)

for tool in "${!TOOLS[@]}"; do
  if command -v "$tool" &>/dev/null; then
    ver=$(${TOOLS[$tool]} 2>/dev/null | head -1)
    echo -e "  ${GREEN}✓${NC} ${BOLD}$tool${NC} — $ver"
  else
    echo -e "  ${RED}✗${NC} ${BOLD}$tool${NC} — não encontrado"
  fi
done

echo ""
echo -e "${YELLOW}${BOLD}Próximos passos:${NC}"
echo -e "  1. Faça logout e login para o shell mudar para zsh"
echo -e "  2. Abra o tmux e pressione ${BOLD}prefix + I${NC} para instalar plugins (TPM)"
echo -e "  3. Abra o nvim — os plugins serão instalados automaticamente"
echo -e "  4. Configure o Atuin: ${BOLD}atuin login${NC} (se usar sync)"
echo -e "  5. Revise o i3 config e ajuste monitores com ${BOLD}arandr${NC}"
echo ""
echo -e "${CYAN}Log completo em: $LOG_FILE${NC}"
echo ""
