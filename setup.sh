#!/usr/bin/env bash
make_tmp_dir() {
    local tmp_dir="/tmp/$1"
    mkdir -p "$tmp_dir"
    echo "$tmp_dir"
}
download_to_tmp_dir() {
    local tmp_dir
    tmp_dir="$(make_tmp_dir "$1")"
    # shift
    curl -fLOJ --output-dir "$tmp_dir" "$2"
    echo "$tmp_dir"
}
install_base_packages() {
    echo
    echo "Installing Base Packages..."
    sudo apt install git curl wget vim unzip -y
    # nodejs and npm ?
}

setup_megasync() {
    echo
    echo "Installing MegaSync..."
    local tmp_dir
    download_to_tmp_dir vs_code "https://mega.nz/linux/repo/xUbuntu_23.10/amd64/megasync-xUbuntu_23.10_amd64.deb"
    tmp_dir="$(download_to_tmp_dir vs_code "https://mega.nz/linux/repo/xUbuntu_23.10/amd64/dolphin-megasync-xUbuntu_23.10_amd64.deb")"
    # curl -fLOJ --output-dir /tmp/mega https://mega.nz/linux/repo/xUbuntu_23.10/amd64/megasync-xUbuntu_23.10_amd64.deb https://mega.nz/linux/repo/xUbuntu_23.10/amd64/dolphin-megasync-xUbuntu_23.10_amd64.deb
    sudo dpkg -i "$tmp_dir"/*.deb
}

setup_brave_browser() {
    echo
    echo "Installing Brave Browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update && sudo apt install brave-browser -y
}

# Requires $HOME
setup_zsh() {
    echo
    echo "Installing ZSH..."
    sudo apt install zsh -y
    # oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    # powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
    # copy dot files
    cp -r .* "$HOME/"
    source .bashrc
}

setup_fonts() {
    echo
    echo "Installing Fonts..."
    local tmp_dir
    download_to_tmp_dir fonts "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
    tmp_dir="$(download_to_tmp_dir fonts "https://github.com/kencrocken/FiraCodeiScript/archive/refs/heads/master.zip")"
    unzip -o "$tmp_dir/*.zip" -d "$tmp_dir"
    mkdir -p "$HOME/.local/share/fonts"
    zsh -c "cp -r ""$tmp_dir/**/*.ttf"" ""$HOME/.local/share/fonts/"""
    fc-cache -f -v
}

setup_python() {
    echo
    echo "Installing Python Packages..."
    sudo apt install ipython3 python3-pip pipx -y
    # PYODBC
    sudo apt install unixodbc-dev mdbtools -y
    # Poetry
    pipx install poetry
    pipx install black
    pipx install jupyterlab
    # poetry completions
    mkdir "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/poetry
    poetry completions zsh >"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/poetry/_poetry
}

setup_kde() {
    echo
    echo "Importing KDE Settings..."
    pipx install konsave
    #     konsave -i muse.knsv
    #     konsave -a muse
    # Set up force-blur (https://github.com/esjeon/kwin-forceblur)
    # install esjeon/kwin-forceblur through KWin Scripts in Settings > Get New Scripts... (Force Blur) version .5.1
    mkdir -p ~/.local/share/kservices5/
    cp ~/.local/share/kwin/scripts/forceblur/metadata.desktop ~/.local/share/kservices5/forceblur.desktop
    # configure force blur settings > add 'dolphin' to list
    # create new window rule match window class 'dolphin' + active and inactive opacity to 90%
    kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.kglobalaccel,/component/kwin,,invokeShortcut,Overview"
}

setup_neovim() {
    echo
    echo "Installing NeoVim..."
    sudo apt install ninja-build gettext cmake unzip curl -y
    git clone https://github.com/neovim/neovim /tmp/neovim
    (cd /tmp/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install)

    git clone https://github.com/kjmcnamara1/nvim.git "$HOME/.config/nvim"
}

setup_vs_code() {
    echo
    echo "Installing VS Code..."
    local tmp_dir
    tmp_dir="$(download_to_tmp_dir vs_code "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64")"
    dpkg -i "$tmp_dir"/*.deb
}

setup_onedrive() {
    echo
    echo "Installing OneDrive..."
    wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_23.10/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_23.10/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
    sudo apt update
    sudo apt install --no-install-recommends --no-install-suggests onedrive -y
    onedrive

    mkdir -p ~/SharePoint/CI_Sandbox
    mkdir -p ~/.config/SharePoint/CI_Sandbox
    cp CI_Sandbox_config ~/.config/SharePoint/CI_Sandbox/config
    onedrive --confdir="~/.config/SharePoint/CI_Sandbox"

    sudo cp onedrive-SharePoint_CI_Sandbox.service /usr/lib/systemd/user/
    sudo chmod 644 /usr/lib/systemd/user/onedrive-SharePoint_CI_Sandbox.service
    systemctl --user enable onedrive
    systemctl --user start onedrive
    systemctl --user enable onedrive-SharePoint_CI_Sandbox
    systemctl --user start onedrive-SharePoint_CI_Sandbox
}

setup_i_drive() {
    # []: Need to add prompt whether to set up I drive or not (so fstab doesn't continuously get appended)
    echo
    echo "Installing iDrive..."
    sudo apt install cifs-utils
    sudo mkdir -p /mnt/I

    local username="mcnamarak"
    read -s -r -p "password for $username:" password
    echo
    echo "username=$username" | sudo tee /etc/fsp_cred >/dev/null
    echo "password=$password" | sudo tee -a /etc/fsp_cred >/dev/null
    sudo chown 0:0 /etc/fsp_cred
    sudo chmod 600 /etc/fsp_cred
    echo | sudo tee -a /etc/fstab
    echo '# Mounting Five Star Data I Drive' | sudo tee -a /etc/fstab
    echo '//192.168.1.44/Five\040Star\040Data /mnt/I cifs auto,uid=1000,gid=1000,dir_mode=0755,file_mode=0644,cred=/etc/fsp_cred 0 0' | sudo tee -a /etc/fstab
}

setup_logitech_options() {
    echo
    echo "Installing Logitech Options..."
    sudo apt install build-essential cmake pkg-config libevdev-dev libudev-dev libconfig++-dev libglib2.0-dev -y
    (mkdir -p /tmp/logitech && cd /tmp/logitech && git clone https://github.com/PixlOne/logiops.git && mkdir logiops/build && cd logiops/build && cmake -DCMAKE_BUILD_TYPE=Release .. && make && sudo make install)
    sudo cp logid.cfg /etc/ # [x]: Need to edit logid.cfg
    systemctl enable --now logid
    logid &
}

setup_keys() {
    echo
    echo "Configuring Keys..."
    # []: Install logkeys
    # []: Install dual key map for capslock xcape

    echo
    echo "Installing logkeys..."
    sudo apt install build-essential autotools-dev autoconf kbd
    git clone https://github.com/kernc/logkeys.git /tmp/logkeys
    (cd /tmp/logkeys && ./autogen.sh && cd build && ../configure && make && sudo make install)
    # log file located at /var/log/logkeys.log
}

setup_chrome_remote_desktop() {
    echo
    echo "Installing Chrome Remote Desktop..."
}

setup_displaylink() {
    echo
    echo "Installing DisplayLink Drivers..."
    # sudo ./displaylink-driver-5.8.0-63.33.run
    local tmp_dir
    tmp_dir="$(download_to_tmp_dir displaylink "https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb")"
    # curl -fsSLOJ --output-dir /tmp https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb
    sudo dpkg -i "$tmp_dir"/*.deb
    sudo apt update
    sudo apt install displaylink-driver
}

main() {
    # read -s -r -p "[sudo] password for $USER:" PW
    echo
    sudo apt update -y
    # install_base_packages
    # setup_megasync
    # setup_brave_browser
    # setup_zsh
    # setup_fonts
    # setup_python
    # setup_kde
    # setup_neovim
    # setup_vs_code
    # setup_onedrive
    # setup_i_drive
    # setup_logitech_options
    setup_keys
    # setup_displaylink
}

main
