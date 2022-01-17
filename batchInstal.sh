#!/bin/bash

TITLE="Batch install software"

##Firts we need root permissions to work 
if [ "$EUID" -ne 0 ]
  then 
    whiptail --title "$TITLE" --msgbox "Run this script as root" 8 78
    exit
fi

##Array of programs to be installed with description
declare -a arrayOptions=("anydesk" "remote access tool" OFF 
    "blender" "3d modeling suite" OFF 
    "code" "visual studio code - code editor" OFF 
    "discord" "gaming community software. Calls and more" OFF 
    "flameshot" "capture tool" OFF 
    "gimp" "image editor open source" OFF 
    "git-all" "software version control" OFF 
    "google-chrome-stable" "web browser" OFF 
    "inkscape" "open source vector graphics editor " OFF 
    "openvpn" "a VPN " OFF 
    "qbittorrent" "P2P Multiplattform client" OFF 
    "slack" "messaging app for busisness" OFF 
    "steam" "gamming platform" OFF 
    "synergy" "share mouse and keyboard across computers" OFF 
    "telegram-desktop" "messaging app" OFF 
    "zoom" "video conferences app" OFF 
)

##Function to check if pkg are installed
function installed() {
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$1" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
      false
  else
      true
  fi
}

#Run the proper instalation of the software
function runInstalation(){
  for pkg in ${pkgs[@]}; do
      if $(installed $pkg) ; then
          printf "[Info] Installing %s \n" $pkg
          case $pkg in
            *"anydesk"*)
              wget -nc -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
              echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk.list
              apt update
              apt install -y anydesk
            ;;
            *"blender"*)
              apt-get install -y blender
            ;;
            (*"code"*)
              apt-get install -y software-properties-common apt-transport-https
              wget -qO- -nc https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
              install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
              sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
              apt update 
              apt-get install -y code          
            ;;
            (*"discord"*)
              wget -ncO discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
              apt install -y discord.deb
              rm discord.deb
            ;;
            (*"flameshot"*)
              apt-get install -y flameshot
            ;;
            (*"gimp"*)
              apt-get install -y gimp
            ;;
            (*"git-all"*)
              apt-get install -y git-all
            ;;
            (*"google-chrome-stable"*)
              wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chromepkg
              apt-get install -y chromepkg
              rm chromepkg
            ;;
            (*"inkscape"*)
              apt-get install -y inskcape
            ;;
            (*"openvpn"*)
              apt-get -y install openvpn
            ;;
            (*"slack"*)
              wget -nc https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb
              apt install -y slack-desktop-*.deb
              rm slack-desktop-*
            ;;
            (*"steam"*)
              wget -nc https://steamcdn-a.akamaihd.net/client/installer/steam.deb
              apt install -y steam.deb
            ;;
            (*"synergy"*)
              wget -nc https://github.com/brahma-dev/synergy-stable-builds/releases/download/v1.8.8-stable/synergy-v1.8.8-stable-Linux-x86_64.deb -o synergygraty
              apt install -y synergygraty 
              rm synergygraty
            ;;
            (*"telegram-desktop"*)
              apt-get install -y telegram-desktop
            ;;
            (*"qbittorrent"*)
              apt-get install -y qbittorrent
            ;;
            (*"zoom"*)
              wget -nc https://zoom.us/client/latest/zoom_amd64.deb
              apt install -y zoom_amd64.deb
              rm zoom_amd64.deb
            ;;
            (*)
              printf "[Warning] Option not reconigzed %s \n" $pkg
            ;;
          esac
      else
        printf "[Info] Skipping %s. Already installed \n" $pkg
      fi
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  done
}

##Screen showing all software and confirm instalation
function screenInstalation(){
  whiptail --scrolltext "The following software will be installed ${arrayOptions[@]}" 50 80
  pkgs=""
}

##Screen for select software
function screenSelectSoft(){
  ##Select a packages to install via check list
  pkgs=$(whiptail --title "Batch install software" \
    --checklist "Check software to install" 22 80 15 \
    "${arrayOptions[@]}" \
    3>&1 1<&2 2>&3)
}

#-----------------------------------------------------------------------------------------------#
##Main structure
ADVSEL=$(whiptail --title "$TITLE" --menu "Choose an option" 15 60 4 \
    "1" "Install all software" \
    "2" "Select software" \
    "3" "Exit" 3>&1 1>&2 2>&3)
case "$ADVSEL" in
1)
    screenInstalation
    runInstalation
    ;;
2)
    screenSelectSoft
    runInstalation
    ;;
3)
    exit
    ;;
esac

#Finish after execution
exit