#!/bin/bash

TITLE="Batch install software"

##Firts we need root permissions to work 
if [ "$EUID" -ne 0 ]
  then 
    whiptail --title "$TITLE" --msgbox "Run this script as root" 8 78
    exit
fi

##Array of programs to be installed with description
declare -a arrayOptions=("Anydesk" ".remote access tool" OFF 
    "Barrier" ".share mouse and keyboard across computers" OFF 
    "Blender" ".3d modeling suite" OFF 
    "Chrome" ".web browser" OFF 
    "Discord" ".gaming community software. Calls and more" OFF 
    "Flameshot" ".capture tool" OFF 
    "Gimp" ".image editor open source" OFF 
    "Git" ".software version control" OFF 
    "Inkscape" ".open source vector graphics editor " OFF 
    "Oh-my-bash" ". framework for bash" OFF 
    "Openvpn" ".a VPN " OFF 
    "Qbittorrent" ".P2P Multiplattform client" OFF 
    "Slack" ".messaging app for busisness" OFF 
    "Steam" ".gamming platform" OFF 
    "Telegram" ".messaging app" OFF 
    "VsCode" ".visual studio code - code editor" OFF 
    "Zoom" ".video conferences app" OFF 
)


##Function to check if pkg are installed
#currently are not used because cannot trully detect when a package are installed
function installed() {
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$1" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
      true
  else
      false
  fi
}

#print software options formates like whiptail textbox needed
function printOptions(){
    for i in "${arrayOptions[@]}"
    do
        if [[ $i  == "OFF" ]];then
            printf "\n"
        else
            printf "%s " $i
        fi
    done
}

#store on array var only the keys of software list
function getOnlyKeys(){
    bAction=true
    for i in "${arrayOptions[@]}"
    do
        if [[ $bAction == true ]]; then
            pkgs+=("$i")
            bAction=false
        elif [[ $i  == "OFF" ]];then
            bAction=true
        fi
    done
}

#Run the proper instalation of the software
function runInstalation(){
  
  bOhMyBash=false

  for pkg in ${pkgs[@]}; do
        printf "[Info] Installing %s \n" $pkg
        case $pkg in
          *"Anydesk"*)
            wget -nc -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
            echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk.list
            apt update
            apt install -y anydesk
          ;;
          (*"Barrier"*)
            apt-get install -y barrier
          ;;
          (*"Blender"*)
            apt-get install -y blender
          ;;
          (*"Chrome"*)
            wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chromepkg.deb
            apt-get install -y ./chromepkg.deb
            rm chromepkg.deb
          ;;
          (*"Discord"*)
            wget -nc -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
            apt install -y ./discord.deb
            rm discord.deb
          ;;
          (*"Flameshot"*)
            apt-get install -y flameshot
          ;;
          (*"Gimp"*)
            apt-get install -y gimp
          ;;
          (*"Git"*)
            apt-get install -y git-all
          ;;
          (*"Inkscape"*)
            apt-get install -y inkscape
          ;;
          (*"Oh-my-bash"*)
            #Because oh my bash installation kill the session and restart him i moved to the end of procedure
            $bOhMyBash=true
            ;;
          (*"Openvpn"*)
            apt-get -y install openvpn
          ;;
          (*"Slack"*)
            wget -nc https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb
            apt install -y ./slack-desktop-*.deb
            rm ./slack-desktop-*
          ;;
          (*"Steam"*)
            wget -nc https://steamcdn-a.akamaihd.net/client/installer/steam.deb
            apt install -y ./steam.deb
            rm ./steam.deb
          ;;
          (*"Telegram"*)
            snap install telegram-desktop
          ;;
          (*"Qbittorrent"*)
            apt-get install -y qbittorrent
          ;;
          (*"VsCode"*)
            apt-get install -y software-properties-common apt-transport-https
            wget -qO- -nc https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
            sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
            apt update 
            apt-get install -y code
            rm packages.microsoft.gpg
          ;;
          (*"Zoom"*)
            wget -nc https://zoom.us/client/latest/zoom_amd64.deb
            apt install -y ./zoom_amd64.deb
            rm ./zoom_amd64.deb
          ;;
          (*)
            printf "[Warning] Option not reconigzed %s \n" $pkg
          ;;
        esac
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  done

  if [[ $bOhMyBash ]]; then
    bash -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)"
  fi

}

####---------------------------------------SCREENS-----------------------------------------------------

##Screen showing all software and confirm instalation
function screenInstalation(){
    whiptail --title "$TITLE" --textbox /dev/stdin 25 80 <<<"$(printf "The following software will be installed: \n\n$(printOptions)" )"
    getOnlyKeys
    #echo ${pkgs[@]}
}

##Screen for select software
function screenSelectSoft(){
  ##Select a packages to install via check list
  pkgs=$(whiptail --title "Batch install software" \
    --checklist "Check software to install" 22 80 15 \
    "${arrayOptions[@]}" \
    3>&1 1<&2 2>&3)
}

#-----------------------------------------MAIN-----------------------------------------------------#
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
