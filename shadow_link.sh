#!/bin/bash
# automation for nmcli tool easy to use and looks preety
download_tool() {
    local packages=("figlet" "nmcli")  # Add more tools here if needed

    local os="$(uname -s)"

    # Function to check if tool is installed
    is_installed() {
        command -v "$1" &>/dev/null
    }

    # Function to install packages using the given command
    install_packages() {
        for pkg in "${packages[@]}"; do
            if is_installed "$pkg"; then
                echo -e "\e[92m✔ $pkg is already installed\e[0m"
            else
                echo -e "\e[94m➤ Installing $pkg...\e[0m"
                eval "$1 $pkg"
            fi
        done
    }

    case "$os" in
        Linux*)
            if command -v apt-get &>/dev/null; then
                install_packages "sudo apt-get install -y"

            elif command -v pacman &>/dev/null; then
                install_packages "sudo pacman -S --noconfirm"

            elif command -v dnf &>/dev/null; then
                install_packages "sudo dnf install -y"

            elif command -v yum &>/dev/null; then
                install_packages "sudo yum install -y"

            elif command -v zypper &>/dev/null; then
                install_packages "sudo zypper install -y"

            elif command -v apk &>/dev/null; then
                install_packages "sudo apk add"

            elif command -v nix-env &>/dev/null; then
                install_packages "nix-env -iA nixpkgs"

            else
                echo -e "\e[91m✘ Unsupported Linux distro or missing package manager.\e[0m"
                exit 1
            fi
            ;;
        Darwin*)
            echo -e "\e[92mDetected macOS\e[0m"
            if command -v brew &>/dev/null; then
                install_packages "brew install"
            else
                echo -e "\e[91mHomebrew not found. Please install Homebrew.\e[0m"
            fi
            ;;
        *)
            echo -e "\e[91m✘ Unsupported operating system: $os\e[0m"
            exit 1
            ;;
    esac
}
banner() {
    clear
    local term_width
    term_width=$(tput cols)
    
    # Top border
       echo -e "\e[92m"
    printf '%*s\n' "$term_width" '' | tr ' ' '-'
       echo -e "\e[0m"
    # Fancy title using toilet (with fallback to echo)
    echo -e "\e[92m"
    #   if command -v toilet &>/dev/null; then
    #     output=$(toilet -f mono12 --filter border "ShadowLink")
    if command -v figlet &>/dev/null; then
        output=$(figlet "ShadowLink")
    else
        output="ShadowLink"
    fi

    # Center each line of output
    while IFS= read -r line; do
        padding=$(( (term_width - ${#line}) / 2 ))
        printf "%*s%s\n" "$padding" "" "$line"
    done <<< "$output"
    echo -e "\e[0m"
    
    # Subtitle centered
    subtitle="⚡ Welcome to shadow_link. A Powerful WIFI Automation Tool ⚡"
    padding=$(( (term_width - ${#subtitle}) / 2 ))
    printf "%${padding}s%s\n" "" "$subtitle"
    
    # Bottom border
       echo -e "\e[92m"
    printf '%*s\n' "$term_width" '' | tr ' ' '-'
       echo -e "\e[0m"


    echo -e "Author      : ${YELLOW}Gaurav Mahajan${RESET}"
    echo -e "GitHub Repo : ${YELLOW}https://github.com/gauravmahajan-dev/shadow-link${RESET}"
    # echo -e "License     : ${YELLOW}MIT (Open Source)${RESET}"
    echo -e "${RED}This tool only works in LINUX all distros"
    lines(){
        # tput sc
        echo
        echo -e "${GREEN}We are happy to have you using ${BLUE}shadow-link${GREEN}!${RESET}"
        echo -e "If you encounter bugs, have suggestions, or want to contribute,"
        echo -e "please open an issue or pull request on our GitHub repository."
        echo -e "You're part of the open-source movement — and we appreciate your support! 💚"
        echo
        sleep 1s
        # Move back to saved cursor position and clear down
        # tput rc
        # tput ed
    }
    lines
    

}
does_previous_alias_work(){
    if [[ $? -ne 0 ]]; then
        echo -e "$RED \tError something went wrong. Please try again later. $RESET"
        bye
    else 
        echo -e "\e[92mSuccessful $RESET"
    fi
}
bye(){
        term_width_last=$(tput cols)
        echo -e "$RED"
        #border
        printf '%*s\n' "$term_width_last" '' | tr ' ' '-'
        echo -e "\tBye... "
        printf '%*s\n' "$term_width_last" '' | tr ' ' '-'
        echo -e "\e[0m"
        exit 1
}

RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
BLUE="\e[94m"
PURPLE="\e[95m"
SKY="\e[96m"
RESET="\e[0m"



# start program
download_tool
banner
sleep 10;

echo -e "\e[92mPlease select an option given below:"
echo "1. Scan wifi networks"
echo "2. Connect wifi network"
echo "3. Disconnect wifi network"
echo "4. Wifi status"
echo "5. List all saved networks"
echo "6. Delete saved network"
echo "7. Connected device INFO"
echo "8. Up wifi-network"
echo "9. Down wifi-network"
echo "10. Start Monitor Mode"
echo "11. turn ON wifi"
echo "12. turn OFF wifi"
echo "13. Exit"
echo
read -p "Enter your option eg(1,2...) : " option

case "$option" in
    1)
        echo
        nmcli -f IN-USE,SSID,MODE,CHAN,RATE,SIGNAL device wifi list
        does_previous_alias_work
    ;;
    2)
       mapfile -t scanned_networks < <(nmcli -f IN-USE,SSID,BSSID,SIGNAL  device wifi list )
        echo -e "\e[92mScanning available wifi networks."
        echo
        echo "Please select a network given below."
        echo
        echo -e "IN-USE\t\tSSID\t\tBSSID\t\tSIGNAL(1-100)"
        select network in "${scanned_networks[@]:1}";
        do
        if [[ -n "$network" ]]; then
        echo -e "You selected: $network"
        ssid=$(echo "$network" | awk '{print $2}')
        bssid=$(echo "$network" | awk '{print $3}')
        if [[ $? -ne 0 ]]; then
            bssid=$(echo "$network" | awk '{print $3}')
        fi
        read -p "$ssid Password : " password
        echo -e "\e[0m\ntrying to connect $bssid"
        nmcli device wifi connect "$ssid" password "$password"
        if [[ $? -ne 0 ]]; then
            echo "something went wrong."
            echo "please re-enter your password."
            read -p "$ssid Password : " password
            nmcli device wifi connect "$ssid" password "$password"
             if [[ $? -ne 0 ]]; then
                echo "Error\nplease try again later."
                bye
            fi
        fi
        echo -e "\e[92mConnected successfully. $RESET"
        
        break
        else
        echo -e "\e[91m❌ Invalid choice. Please try again.\e[0m"
        exit 1;
        fi
        done
        
        
    ;;
    3)
        mapfile -t wifi_interface < <(nmcli device)
        echo "Please select your connected wifi interface."
        echo -e "\nDEVICE\t\t\tTYPE\tSTATE\t\t\tCONNECTION"
        select interface in "${wifi_interface[@]:1}";
        do
            if [[ -n "$interface"  ]]; then
                echo -e "\n✅ You selected interface:\n$interface"
                echo "trying to disconnect $interface"
                nmcli device disconnect "$interface"
                does_previous_alias_work
                break
            else
                echo -e "${RED} Invalid choice. Please enter a valid number.${RESET}"
                bye
            fi
        done

    ;;
    4)
        echo "checking wifi status"
        nmcli device status
        does_previous_alias_work
    ;;
    5)
        echo "Listing all saved networks"
        nmcli -f NAME,TYPE,DEVICE connection show 
        does_previous_alias_work
    ;;
    6)
        echo "Please select network you want to delete from saved networks"

        mapfile -t list_saved_networks < <(nmcli -f NAME,TYPE,DEVICE connection show)
        echo -e "\nNAME\t\t\t TYPE\t\t\t DEVICE"
        select delete_network in "${list_saved_networks[@]:1}"
        do
            if [[ -n "$delete_network" ]]; then
                echo "you selected : $delete_network"
                ssid=$(echo "$delete_network" | awk '{print $1}')
                nmcli connection delete "$ssid"
                does_previous_alias_work
                break
            fi

        done


    ;;
    7)  
        echo -e "$GREEN"
        echo  -e "gathering information of connected device. $RESET"
        echo
        nmcli device show
        does_previous_alias_work
        
    ;;
    8)
        echo "Please select your interface."

        mapfile -t list_all_interfaces < <(nmcli -f CONNECTION,DEVICE,TYPE,STATE device status )
        echo -e "\nNETWORKS\t\t\tDEVICE\t\t\tTYPE\t\t\tSTATE"
        select interface in "${list_all_interfaces[@]:1}"
        do
            if [[ -n "$interface" ]]; then
                echo "you selected : $interface"
                ssid=$(echo "$interface" | awk '{print $1}')
                nmcli device up "$ssid"
                does_previous_alias_work
                break
            fi

        done

    ;;
    9)
        echo "Please select your interface."

        mapfile -t list_all_interfaces < <(nmcli -f CONNECTION,DEVICE,TYPE,STATE device status )
        echo -e "\nNETWORKS\t\t\tDEVICE\t\t\tTYPE\t\t\tSTATE"
        select interface in "${list_all_interfaces[@]:1}"
        do
            if [[ -n "$interface" ]]; then
                echo "you selected : $interface"
                ssid=$(echo "$interface" | awk '{print $2}')
                interface_name=$(echo "$interface" | awk '{print $1}')
                nmcli device down "$ssid"
                if [[ $? -ne 0 ]]; then
                    echo -e "${RED}Error please try again later. $RESET"
                    bye
                else
                    echo -e "${GREEN}Successfully disconnect to $interface_name. $RESET"
                fi
                break
            fi

        done

    ;;
    10)
        read -p "Do you have ( wifi penetration testing tool || network analysis tool) say (yes or no) : " WIFI_MACHINE 
        if [[ "$WIFI_MACHINE" =~ ^[n]+$ ]]; then
            echo -e "wifi penetration testing tool || network analysis tool is required for this mode.\nPlease buy those tools from market."
            exit 1;
        fi
        echo -e "\nStarting monitor mode"
        echo -e "This process will take sometime please wait.\n"
        if timeout 120s nmcli device monitor; then
            echo "✅ Monitor mode successfully started."
        else
            echo -e "\e[91m❌ Error: Something went wrong. $RESET"
            
        fi
        does_previous_alias_work
    ;;
    11)
        echo "turning ON wifi"
        nmcli radio wifi on 
        echo "Please select your network interface"
        mapfile -t list_all_interfaces < <(nmcli -f CONNECTION,DEVICE,TYPE,STATE device status )
        echo -e "\nNETWORKS\t\t\tDEVICE\t\t\tTYPE\t\t\tSTATE"
        select interface in "${list_all_interfaces[@]:1}"
        do
            if [[ -n "$interface" ]]; then
                echo "you selected : $interface"
                current_interface=$(echo "$interface" | awk '{print $2}')
                nmcli device connect "$current_interface"
                does_previous_alias_work
                break
            fi

        done
    
    ;;
    12)
        echo "turning ON wifi"
        nmcli radio wifi off 
        does_previous_alias_work
    ;;
    13) 
       bye
    ;;
    *)
        echo -e "$RED Invalid option. Please enter  a number only. $RESET"
        bye
    ;;

esac








echo -e "\e[0m"
