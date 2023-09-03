#!/bin/bash
# Configure system
echo "Configuring bash, dnf, and git."

## Configure git
git config --global user.name "Luke Oldenburg"
git config --global user.email "87272260+Luke-Oldenburg@users.noreply.github.com"

## Autocomplete ignore case
echo "bind 'set completion-ignore-case on'" | sudo tee -a /etc/bashrc
echo "alias dcd='dconf dump / > ~/.config/dconf/user.conf'" | sudo tee -a /etc/bashrc
echo "alias dcl='dconf load / < ~/.config/dconf/user.conf'" | sudo tee -a /etc/bashrc
echo "alias httpserver='python3 -m http.server'" | sudo tee -a /etc/bashrc
echo "alias rpi='ssh luke@pi.lukeoldenburg.com'" | sudo tee -a /etc/bashrc
echo "alias dnfup='sudo dnf upgrade && sudo dnf autoremove'" | sudo tee -a /etc/bashrc

## Configure dnf
echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=20" | sudo tee -a /etc/dnf/dnf.conf
echo "deltarpm=True" | sudo tee -a /etc/dnf/dnf.conf

## Configure swap
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl --load

# Install shortcuts
echo "Installing shortcuts."
sudo cp -r ../shortcuts/* /usr/share/applications/ -v

# Remove unwanted 3rd party repositories
echo "Removing unwanted 3rd party repositories."
sudo rm -f /etc/yum.repos.d/google-chrome.repo -v
sudo rm -f /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:phracek\:PyCharm.repo -v
sudo flatpak remote-delete flathub -v

# Install dnf packages
echo "Installing dnf packages."
dnf check-update -v
sudo dnf install 2048-cli alien apostrophe audacity dconf-editor deja-dup ffmpeg-free gcc gcc-c++ ghex gimp gnome-extensions-app gnome-tweaks golang htop java-17-openjdk-* mpv ncdu neofetch nmap nodejs nvtop obs-studio seahorse steam xkill yt-dlp -y -v

## NVIDIA Drivers
echo "Installing NVIDIA drivers."
sudo dnf install akmod-nvidia libva-utils libva-vdpau-driver vdpauinfo vulkan xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs -y -v

## Multimedia codecs
echo "Installing multimedia codecs."
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel -y -v
sudo dnf install lame\* --exclude=lame-devel -y -v
sudo dnf group upgrade --with-optional Multimedia -y -v

# VSCode
echo "Installing VSCode."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc -v
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update -v
sudo dnf install code -y -v

# Rust
echo "Installing Rust."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

cd ~/Downloads

# RPMs
echo "Installing RPMs."
## Bitwarden
echo "Installing Bitwarden."
wget -O bitwarden.rpm "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=rpm"
sudo rpm -i bitwarden.rpm -v

## OnlyOffice
echo "Installing OnlyOffice."
sudo dnf remove libreoffice* -y -v
wget -O onlyoffice.rpm https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors.x86_64.rpm
sudo rpm -i onlyoffice.rpm -v

## ProtonVPN
echo "Installing ProtonVPN."
wget -O protonvpn.rpm https://repo.protonvpn.com/fedora-38-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm
sudo rpm -i protonvpn.rpm -v
dnf check-update -v
sudo dnf install libappindicator-gtk3 protonvpn python3-pip -y -v
pip3 install --user 'dnspython>=1.16.0' -v

# Tarballs
echo "Installing tarballs."
## Install Discord
echo "Installing Discord."
wget -O discord.tar.gz "https://discord.com/api/download?platform=linux&format=tar.gz"
tar -xvf discord.tar.gz
sudo mv Discord /opt/ -v
sudo ln -svf /opt/Discord/Discord /usr/bin/discord

## Install Flutter
echo "Installing Flutter."
sudo dnf install clang cmake ninja-build pkg-config gtk3* -y -v
wget -O flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.6-stable.tar.xz
tar -xvf flutter.tar.xz
sudo mv flutter /opt/ -v
echo "export PATH=\"$PATH:/opt/flutter/bin\"" | sudo tee -a /etc/bashrc
source /etc/bashrc
flutter upgrade --force
flutter precache
dart --disable-analytics
flutter config --no-analytics
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop

## Install IntelliJ IDEA Ultimate
echo "Installing IntelliJ IDEA Ultimate."
wget -O idea.tar.gz https://download.jetbrains.com/idea/ideaIU-2023.2.tar.gz
tar -xvf idea.tar.gz
sudo mkdir /opt/idea/ -v
sudo mv idea-*/* /opt/idea/ -v
sudo ln -svf /opt/idea/bin/idea.sh /usr/bin/intellij-idea-ultimate

## Install Minecraft
echo "Installing Minecraft."
wget -O minecraft.tar.gz https://launcher.mojang.com/download/Minecraft.tar.gz
tar -xvf minecraft.tar.gz
sudo mv minecraft-launcher /opt/ -v
sudo ln -svf /opt/minecraft-launcher/minecraft-launcher /usr/bin/minecraft-launcher

## Install Postman
echo "Installing Postman."
wget -O postman.tar.gz https://dl.pstmn.io/download/latest/linux_64
tar -xvf postman.tar.gz
sudo mv Postman /opt/ -v
sudo ln -svf /opt/Postman/Postman /usr/bin/postman

## Links
echo "Creating links."
sudo ln -sv /usr/bin/firefox /usr/bin/ff
sudo ln -sv /usr/bin/dconf-editor /usr/bin/dce

sudo dnf upgrade -y -v && sudo dnf autoremove -y -v

# GNOME Extensions
echo "Install these GNOME Extensions manually:"
echo "Alphabetical App Grid:    https://extensions.gnome.org/extension/4269/alphabetical-app-grid/"
echo "AppIndicator:             https://extensions.gnome.org/extension/615/appindicator-support/"
echo "Dash to Dock:             https://extensions.gnome.org/extension/307/dash-to-dock/"
echo "Extension List:           https://extensions.gnome.org/extension/3088/extension-list/"
echo "OpenWeather:              https://extensions.gnome.org/extension/750/openweather/"
echo "Vitals:                   https://extensions.gnome.org/extension/1460/vitals/"

read -rsp $'Press any key to continue...\n' -n 1 key

# Reboot
for i in {5..1}
do
  echo -e "\e[41mWARNING: Rebooting in $i seconds! Press CTRL + C to cancel.\e[0m"
  sleep 1s
done
reboot