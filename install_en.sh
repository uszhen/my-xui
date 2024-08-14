#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error:${plain}please run this script with root privilege\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}check system os failed,please contact with author!${plain}\n" && exit 1
fi

arch=$(arch)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
else
    arch="amd64"
    echo -e "${red}fail to check system arch,will use default arch here: ${arch}${plain}"
fi

echo "架构: ${arch}"

if [ $(getconf WORD_BIT) != '32' ] && [ $(getconf LONG_BIT) != '64' ]; then
    echo "my-xui dosen't support 32bit(x86) system,please use 64 bit operating system(x86_64) instead,if there is something wrong,plz let me know"
    exit -1
fi

os_version=""

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}please use CentOS 7 or higher version${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}please use Ubuntu 16 or higher version${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}please use Debian 8 or higher version${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install wget curl tar -y
    else
        apt install wget curl tar -y
    fi
}

#This function will be called when user installed my-xui out of sercurity
config_after_install() {
    echo -e "${yellow}Install/update finished need to modify panel settings out of security${plain}"
    read -p "are you continue,if you type n will skip this at this time[y/n]": config_confirm
    if [[ x"${config_confirm}" == x"y" || x"${config_confirm}" == x"Y" ]]; then
        read -p "please set up your username:" config_account
        echo -e "${yellow}your username will be:${config_account}${plain}"
        read -p "please set up your password:" config_password
        echo -e "${yellow}your password will be:${config_password}${plain}"
        read -p "please set up the panel port:" config_port
        echo -e "${yellow}your panel port is:${config_port}${plain}"
        echo -e "${yellow}initializing,wait some time here...${plain}"
        /usr/local/my-xui/my-xui setting -username ${config_account} -password ${config_password}
        echo -e "${yellow}account name and password set down!${plain}"
        /usr/local/my-xui/my-xui setting -port ${config_port}
        echo -e "${yellow}panel port set down!${plain}"
    else
        echo -e "${red}cancel...${plain}"
        if [[ ! -f "/etc/my-xui/my-xui.db" ]]; then
            local usernameTemp=$(head -c 6 /dev/urandom | base64)
            local passwordTemp=$(head -c 6 /dev/urandom | base64)
            local portTemp=$(echo $RANDOM)
            /usr/local/my-xui/my-xui setting -username ${usernameTemp} -password ${passwordTemp}
            /usr/local/my-xui/my-xui setting -port ${portTemp}
            echo -e "this is a fresh installation,will generate random login info for security concerns:"
            echo -e "###############################################"
            echo -e "${green}user name:${usernameTemp}${plain}"
            echo -e "${green}user password:${passwordTemp}${plain}"
            echo -e "${red}web port:${portTemp}${plain}"
            echo -e "###############################################"
            echo -e "${red}if you forgot your login info,you can type my-xui and then type 7 to check after installation${plain}"
        else
            echo -e "${red} this is your upgrade,will keep old settings,if you forgot your login info,you can type my-xui and then type 7 to check${plain}"
        fi
    fi
}

install_my-xui() {
    systemctl stop my-xui
    cd /usr/local/

    if [ $# == 0 ]; then
        last_version=$(curl -Ls "https://api.github.com/repos/uszhen/my-xui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}refresh my-xui version failed,it may due to Github API restriction,please try it later${plain}"
            exit 1
        fi
        echo -e "get my-xui latest version succeed:${last_version},begin to install..."
        wget -N --no-check-certificate -O /usr/local/my-xui-linux-${arch}-english.tar.gz https://github.com/uszhen/my-xui/releases/download/${last_version}/my-xui-linux-${arch}-english.tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red}dowanload my-xui failed,please be sure that your server can access Github{plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/uszhen/my-xui/releases/download/${last_version}/my-xui-linux-${arch}-english.tar.gz"
        echo -e "begin to install my-xui v$1 ..."
        wget -N --no-check-certificate -O /usr/local/my-xui-linux-${arch}-english.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}dowanload my-xui v$1 failed,please check the verison exists${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/my-xui/ ]]; then
        rm /usr/local/my-xui/ -rf
    fi

    tar zxvf my-xui-linux-${arch}-english.tar.gz
    rm my-xui-linux-${arch}-english.tar.gz -f
    cd my-xui
    chmod +x my-xui bin/xray-linux-${arch}
    cp -f my-xui.service /etc/systemd/system/
    wget --no-check-certificate -O /usr/bin/my-xui https://raw.githubusercontent.com/uszhen/my-xui/main/my-xui_en.sh
    chmod +x /usr/local/my-xui/my-xui_en.sh
    chmod +x /usr/bin/my-xui
    config_after_install
    systemctl daemon-reload
    systemctl enable my-xui
    systemctl start my-xui
    echo -e "${green}my-xui v${last_version}${plain} install finished,it is working now..."
    echo -e ""
    echo -e "my-xui control menu usages: "
    echo -e "----------------------------------------------"
    echo -e "my-xui              - Enter     control menu"
    echo -e "my-xui start        - Start     my-xui "
    echo -e "my-xui stop         - Stop      my-xui "
    echo -e "my-xui restart      - Restart   my-xui "
    echo -e "my-xui status       - Show      my-xui status"
    echo -e "my-xui enable       - Enable    my-xui on system startup"
    echo -e "my-xui disable      - Disable   my-xui on system startup"
    echo -e "my-xui log          - Check     my-xui logs"
    echo -e "my-xui update       - Update    my-xui "
    echo -e "my-xui install      - Install   my-xui "
    echo -e "my-xui uninstall    - Uninstall my-xui "
    echo -e "my-xui geo          - Update    geo  data"
    echo -e "----------------------------------------------"
}

echo -e "${green}excuting...${plain}"
install_base
install_my-xui $1
