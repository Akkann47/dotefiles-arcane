#!/bin/bash
# ============================================================
#  Dotfiles Install Script — Hyprland / Arch Linux
#  À lancer après une archinstall avec Hyprland de base.
# ============================================================
set -e

# --- Couleurs ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERR]${NC} $1"; exit 1; }

# --- Vérifications initiales ---
[[ $EUID -eq 0 ]] && error "Ne pas lancer en root. Lance le script en tant qu'utilisateur normal."
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Répertoire dotfiles : $DOTFILES_DIR"

# ============================================================
# 1. INSTALLATION DE YAY (helper AUR)
# ============================================================
install_yay() {
    if command -v yay &>/dev/null; then
        success "yay déjà installé"
        return
    fi
    info "Installation de yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    success "yay installé"
}

# ============================================================
# 2. PAQUETS OFFICIELS (pacman)
# ============================================================
install_pacman_packages() {
    info "Installation des paquets officiels..."

    local pkgs=(
        # Hyprland ecosystem
        hyprland hyprlock hyprpaper

        # Screenshots (requis par hyprshot)
        grim slurp

        # Barre / notifications
        waybar dunst

        # Terminal
        kitty

        # Fichiers
        thunar gvfs gvfs-mtp thunar-volman

        # Apparence
        nwg-look
        gtk3 gtk4
        qt5-wayland qt6-wayland

        # Polkit agent
        polkit polkit-gnome

        # Virtualisation
        virt-manager qemu-full libvirt
        edk2-ovmf dnsmasq bridge-utils iptables-nft swtpm

        # Bluetooth
        bluez bluez-utils blueman

        # Audio
        pipewire pipewire-pulse pipewire-alsa wireplumber
        pavucontrol

        # Réseau
        networkmanager network-manager-applet nm-connection-editor

        # Outils système
        brightnessctl playerctl
        fzf jq
        reflector

        # Clipboard
        wl-clipboard

        # Fonts
        ttf-jetbrains-mono-nerd
        noto-fonts noto-fonts-emoji

        # Portals Wayland
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

        # Python (scripts waybar)
        python python-requests

        # Xwayland (compatibilité apps X11)
        xorg-xwayland

    )

    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
    success "Paquets officiels installés"
}

# ============================================================
# 3. PAQUETS AUR (yay)
# ============================================================
install_aur_packages() {
    info "Installation des paquets AUR..."

    local aur_pkgs=(
        # Lanceur
        walker-bin
        elephant

        # Screenshots
        hyprshot

        # Éditeur
        vscodium-bin

        # Fonts
        ttf-arcadeclassic

        # Icons
        numix-circle-icon-theme-git

        # Python (script météo waybar)
        python-pyquery

        # Divers
        psensor
    )

    yay -S --needed --noconfirm "${aur_pkgs[@]}"
    success "Paquets AUR installés"
}

# ============================================================
# 4. THÈME GTK — Tokyonight-Dark
# ============================================================
install_gtk_theme() {
    if [[ -d "$HOME/.themes/Tokyonight-Dark" ]]; then
        success "Thème Tokyonight-Dark déjà présent"
        return
    fi
    info "Téléchargement du thème Tokyonight-Dark..."
    mkdir -p "$HOME/.themes"
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone --depth=1 https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git "$tmpdir/theme"
    cp -r "$tmpdir/theme/themes/Tokyonight-Dark" "$HOME/.themes/"
    rm -rf "$tmpdir"
    success "Thème Tokyonight-Dark installé"
}

# ============================================================
# 5. COPIE DES DOTFILES
# ============================================================
deploy_dotfiles() {
    info "Déploiement des dotfiles..."

    # Créer les dossiers cibles
    mkdir -p \
        "$HOME/.config/hypr/conf.d" \
        "$HOME/.config/hypr/scripts" \
        "$HOME/.config/waybar/scripts" \
        "$HOME/.config/kitty" \
        "$HOME/.config/walker/themes/mywalkertheme" \
        "$HOME/.config/elephant/menus" \
        "$HOME/.config/Thunar" \
        "$HOME/.config/dunst" \
        "$HOME/Images/Wallpapers" \
        "$HOME/Images/Screenshots"

    # Hyprland
    cp -f "$DOTFILES_DIR/.config/hypr/hyprland.conf"    "$HOME/.config/hypr/"
    cp -f "$DOTFILES_DIR/.config/hypr/hyprlock.conf"    "$HOME/.config/hypr/"
    cp -f "$DOTFILES_DIR/.config/hypr/hyprpaper.conf"   "$HOME/.config/hypr/"
    cp -rf "$DOTFILES_DIR/.config/hypr/conf.d/"         "$HOME/.config/hypr/"
    cp -rf "$DOTFILES_DIR/.config/hypr/scripts/"        "$HOME/.config/hypr/"
    chmod +x "$HOME/.config/hypr/scripts/"*.sh

    # Waybar
    cp -f "$DOTFILES_DIR/.config/waybar/config.jsonc"        "$HOME/.config/waybar/"
    cp -f "$DOTFILES_DIR/.config/waybar/style.css"           "$HOME/.config/waybar/"
    cp -f "$DOTFILES_DIR/.config/waybar/power_menu.xml"      "$HOME/.config/waybar/"
    cp -f "$DOTFILES_DIR/.config/waybar/options_menu.xml"    "$HOME/.config/waybar/"
    cp -f "$DOTFILES_DIR/.config/waybar/brightness_menu.xml" "$HOME/.config/waybar/"
    cp -rf "$DOTFILES_DIR/.config/waybar/scripts/"           "$HOME/.config/waybar/"
    chmod +x "$HOME/.config/waybar/scripts/"*.sh

    # Kitty
    cp -f "$DOTFILES_DIR/.config/kitty/kitty.conf"          "$HOME/.config/kitty/"
    cp -f "$DOTFILES_DIR/.config/kitty/current-theme.conf"  "$HOME/.config/kitty/"

    # Walker
    cp -f "$DOTFILES_DIR/.config/walker/config.toml" "$HOME/.config/walker/"
    cp -f "$DOTFILES_DIR/.config/walker/themes/mywalkertheme/style.css" \
          "$HOME/.config/walker/themes/mywalkertheme/"

    # Elephant
    cp -f "$DOTFILES_DIR/.config/elephant/menus/favoris.toml" "$HOME/.config/elephant/menus/"

    # Thunar
    cp -f "$DOTFILES_DIR/.config/Thunar/uca.xml" "$HOME/.config/Thunar/"

    # Dunst
    cp -f "$DOTFILES_DIR/.config/dunst/dunstrc" "$HOME/.config/dunst/"

    # mimeapps (simplifié — chemins codium.desktop génériques)
    cp -f "$DOTFILES_DIR/.config/mimeapps.list" "$HOME/.config/"

    # Shell (scané depuis le système)
    cp -f "$DOTFILES_DIR/.bashrc" "$HOME/"

    # Wallpaper
    cp -f "$DOTFILES_DIR/wallpapers/Ekko_Powder.jpg" "$HOME/Images/Wallpapers/"

    success "Dotfiles déployés"
}

# ============================================================
# 6. SERVICES SYSTÈME
# ============================================================
enable_services() {
    info "Activation des services..."

    sudo systemctl enable --now bluetooth.service
    sudo systemctl enable --now libvirtd.service
    sudo systemctl enable --now virtlogd.service
    sudo systemctl enable --now NetworkManager.service

    success "Services activés"
}

# ============================================================
# 7. GROUPES UTILISATEUR
# ============================================================
setup_user_groups() {
    info "Ajout de l'utilisateur aux groupes nécessaires..."
    local user
    user=$(whoami)
    sudo usermod -aG libvirt "$user"
    sudo usermod -aG kvm "$user"
    sudo usermod -aG video "$user"
    sudo usermod -aG input "$user"
    warn "Groupes mis à jour — un redémarrage est nécessaire pour qu'ils soient actifs"
    success "Groupes configurés"
}

# ============================================================
# 8. RÉSEAU LIBVIRT (NAT par défaut)
# ============================================================
setup_libvirt_network() {
    info "Configuration du réseau libvirt (virbr0)..."
    if sudo virsh net-list --all 2>/dev/null | grep -q "default"; then
        sudo virsh net-autostart default 2>/dev/null || true
        sudo virsh net-start default 2>/dev/null || true
        success "Réseau libvirt 'default' activé"
    else
        warn "Réseau libvirt 'default' non trouvé — à configurer manuellement si besoin"
    fi
}

# ============================================================
# 9. PARAMÈTRES GTK
# ============================================================
apply_gtk_settings() {
    info "Application des paramètres GTK..."
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-Dark" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "Numix-Circle" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
        success "Paramètres GTK appliqués"
    else
        warn "gsettings non disponible — utilise nwg-look après le premier démarrage"
    fi
}

# ============================================================
# MAIN
# ============================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Dotfiles Hyprland — Script d'install   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

install_yay
install_pacman_packages
install_aur_packages
install_gtk_theme
deploy_dotfiles
enable_services
setup_user_groups
setup_libvirt_network
apply_gtk_settings

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Installation terminée !           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Étapes suivantes :${NC}"
echo "  1. Redémarre ta session (groupes libvirt/kvm)"
echo "  2. Lance 'nwg-look' pour peaufiner thème / icônes / curseur"
echo "  3. Relance Hyprland si tu es déjà dans une session"
echo ""
