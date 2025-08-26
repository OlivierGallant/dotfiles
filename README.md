# packages required:


# core
pacman -S --needed base git unzip curl wget networkmanager wl-clipboard

# hyprland
pacman -S --needed hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    polkit-gnome hyprpaper waybar wlogout rofi-lbonn-wayland

# fonts
pacman -S --needed noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono ttf-jetbrains-mono-nerd

# terminal + shell
pacman -S --needed kitty zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions bash-completion

# nvim + tooling
pacman -S --needed neovim ripgrep fd nodejs npm go python python-pipx
