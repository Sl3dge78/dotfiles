#! bin/bash

# yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
rm -rf yay/

sudo pacman -S wget\
    firefox \
    alacritty \
    nvim \
    lazygit \
    waybar \
    hyprpaper \
    rofi \
    hyprcursor \
    ttf-gohu-nerd \
    pavucontrol \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland \
    qt6ct \
    wl-clipboard \
    qt5-wayland \
    qt6-wayland \
    bash-completion \
    nemo \
    ranger 

yay -S gohufont \
    darkly \
    catppuccin-cursors-macchiato \
    catppuccin-gtk-theme-macchiato \
    catppuccin-sddm-theme-macchiato \
    hyprshot

echo "[Theme]
Current=catppuccin-macchiato" | sudo tee /etc/sddm.conf

mkdir ~/.config/qt6ct/colors
wget https://raw.githubusercontent.com/catppuccin/qt5ct/refs/heads/main/themes/catppuccin-frappe-lavender.conf -O ~/.config/qt6ct/colors/catppuccin-frappe-lavender.conf

