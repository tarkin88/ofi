#!/bin/bash

if [[ -f `pwd`/variables ]]; then
  source variables
else
  echo "missing file: variables"
  exit 1
fi

print_title "Welcome to OFI [On Fresh Install] script by Tarkin88 V0.1"
print_warning "ALERT! \n This script just run on Manjaro, ArchLinux and Antergos" 
print_line
print_info "Your Architecture is $ARCHI."

check_root

check_connection

check_pacman_blocked

echo "Do you want to add powerpill repo?"
read -p "Press y for accept [y/n] " OPTION_XYNE
if [[ $OPTION_XYNE == y ]]; then

	print_info "Adding Xyne Repo (For Powerpill)"
	echo  "" >> /etc/pacman.conf
	echo  "[xyne-$ARCHI]" >> /etc/pacman.conf
	echo  "SigLevel = Required" >> /etc/pacman.conf
	echo  "Server = http://xyne.archlinux.ca/repos/xyne" >> /etc/pacman.conf
	pacman -Syy powerpill
fi
#system_update
print_info "Let's start!"
print_line
package_install "base-devel ccache"

select_user
git clone https://github.com/helmuthdu/dotfiles
cp dotfiles/.bashrc dotfiles/.dircolors dotfiles/.dircolors_256 dotfiles/.nanorc dotfiles/.yaourtrc ~/
cp dotfiles/.bashrc dotfiles/.dircolors dotfiles/.dircolors_256 dotfiles/.nanorc dotfiles/.yaourtrc /home/${username}/
rm -fr dotfiles
echo "Do you want to Reconfigure the system?"
read -p "Press y for accept [y/n]"  OPTION_RECONF
if [[ $OPTION_RECONF == y ]]; then
	reconfigure_system
fi
chown -R ${username}:users /home/${username}
print_title "Installing all packages for a awesome Openbox"
package_install "bc rsync mlocate bash-completion pkgstats ntp"
is_package_installed "ntp" && ntpd -u ntp:ntp
package_install "zip unzip unrar p7zip lzop cpio"
package_install "avahi nss-mdns"
is_package_installed "avahi" && system_ctl enable avahi-daemon
package_install "alsa-utils alsa-plugins"
[[ ${ARCHI} == x86_64 ]] && package_install "lib32-alsa-plugins"
package_install "pulseaudio pulseaudio-alsa pavucontrol"
[[ ${ARCHI} == x86_64 ]] && package_install "lib32-libpulse"
package_install "ntfs-3g dosfstools exfat-utils f2fs-tools fuse fuse-exfat autofs"
is_package_installed "fuse" && add_module "fuse"
package_install "nfs-utils"
system_ctl enable rpcbind
system_ctl enable nfs-client.target
system_ctl enable remote-fs.target
system_ctl enable systemd-readahead-collect
system_ctl enable systemd-readahead-replay
package_install "tlp"
system_ctl enable tlp
system_ctl enable tlp-sleep
system_ctl mask systemd-rfkill
tlp start
package_install "yaourt terminus-font lxappearance clipit networkmanager dnsmasq"
package_install "pcmanfm gvfs gvfs-mtp android-udev arandr mpd mpc ncmpcpp dunst libmtp xfce4-whiskermenu-plugin rofi-git"
package_install "slim scrot htop gparted ranger xarchiver-gtk2 termite"
package_install "xdg-user-dirs wxgtk2.8 viewnior galculator firefox firefox-i18n-es-mx flashplugin gksu polkit-gnome"
package_install "ttf-bitstream-vera ttf-dejavu youtube-dl compton"
package_install "gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav"
package_install "gstreamer0.10 gstreamer0.10-plugins"
package_install "mplayer libbluray libquicktime libdvdread libdvdnav libdvdcss cdrdao feh imagemagick udevil"
install_xorg

install_video_cards

system_ctl enable slim 
system_ctl enable accounts-daemon
system_ctl enable NetworkManager

mkdir -p /home/${username}/.config/openbox/
mkdir -p ~/.compose-cache
# Improvements
touch /etc/sysctl.d/99-sysctl.conf
add_line "fs.inotify.max_user_watches = 524288" "/etc/sysctl.d/99-sysctl.conf"
cp /etc/xdg/openbox/{menu.xml,rc.xml,autostart} /home/${username}/.config/openbox/
chown -R ${username}:users /home/${username}/.config
#config xinitrc

touch /home/${username}/.xinitrc
echo "exec dbus-launch" > /home/${username}/.xinitrc
aur_package_install "sublime-text-dev google-chrome"
aur_package_install "ttf-monaco"
is_package_installed "fontconfig" && pacman -Rdds freetype2 fontconfig cairo
aur_package_install "freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu"
xdg-user-dirs-update
clean_orphan_packages
print_title "And that's all folks!"
finish
