#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误：${plain} 必须使用root用户运行此脚本！\n" && exit 1

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
    echo -e "${red}未检测到系统版本，请联系脚本作者！${plain}\n" && exit 1
fi

arch=$(arch)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "s390x" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
else
    arch="amd64"
    echo -e "${red}检测架构失败，使用默认架构: ${arch}${plain}"
fi

echo "架构: ${arch}"

if [ $(getconf WORD_BIT) != '32' ] && [ $(getconf LONG_BIT) != '64' ]; then
    echo "本软件不支持 32 位系统(x86)，请使用 64 位系统(x86_64)，如果检测有误，请联系作者"
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
        echo -e "${red}请使用 CentOS 7 或更高版本的系统！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}请使用 Ubuntu 16 或更高版本的系统！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}请使用 Debian 8 或更高版本的系统！${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install wget curl tar jq -y
    else
        apt install wget curl tar jq -y
    fi
}

#This function will be called when user installed my-xui out of sercurity
config_after_install() {
    echo -e "${yellow}出于安全考虑，安装/更新完成后需要强制修改端口与账户密码${plain}"
    read -p "确认是否继续,如选择n则跳过本次端口与账户密码设定[y/n]": config_confirm
    if [[ x"${config_confirm}" == x"y" || x"${config_confirm}" == x"Y" ]]; then
        read -p "请设置您的账户名:" config_account
        echo -e "${yellow}您的账户名将设定为:${config_account}${plain}"
        read -p "请设置您的账户密码:" config_password
        echo -e "${yellow}您的账户密码将设定为:${config_password}${plain}"
        read -p "请设置面板访问端口:" config_port
        echo -e "${yellow}您的面板访问端口将设定为:${config_port}${plain}"
        echo -e "${yellow}确认设定,设定中${plain}"
        /usr/local/my-xui/my-xui setting -username ${config_account} -password ${config_password}
        echo -e "${yellow}账户密码设定完成${plain}"
        /usr/local/my-xui/my-xui setting -port ${config_port}
        echo -e "${yellow}面板端口设定完成${plain}"
    else
        echo -e "${red}已取消设定...${plain}"
        if [[ ! -f "/etc/my-xui/my-xui.db" ]]; then
            local usernameTemp=$(head -c 6 /dev/urandom | base64)
            local passwordTemp=$(head -c 6 /dev/urandom | base64)
            local portTemp=$(echo $RANDOM)
            /usr/local/my-xui/my-xui setting -username ${usernameTemp} -password ${passwordTemp}
            /usr/local/my-xui/my-xui setting -port ${portTemp}
            echo -e "检测到您属于全新安装,出于安全考虑已自动为您生成随机用户与端口:"
            echo -e "###############################################"
            echo -e "${green}面板登录用户名:${usernameTemp}${plain}"
            echo -e "${green}面板登录用户密码:${passwordTemp}${plain}"
            echo -e "${red}面板登录端口:${portTemp}${plain}"
            echo -e "###############################################"
            echo -e "${red}如您遗忘了面板登录相关信息,可在安装完成后输入my-xui,输入选项7查看面板登录信息${plain}"
        else
            echo -e "${red}当前属于版本升级,保留之前设置项,登录方式保持不变,可输入my-xui后键入数字7查看面板登录信息${plain}"
        fi
    fi
}

install_my-xui() {
    systemctl stop my-xui
    cd /usr/local/

    if [ $# == 0 ]; then
        last_version=$(curl -Lsk "https://api.github.com/repos/uszhen/my-xui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}检测 my-xui 版本失败，可能是超出 Github API 限制，请稍后再试，或手动指定 my-xui 版本安装${plain}"
            exit 1
        fi
        echo -e "检测到 my-xui 最新版本：${last_version}，开始安装"
        wget -N --no-check-certificate -O /usr/local/my-xui-linux-${arch}.tar.gz https://github.com/uszhen/my-xui/releases/download/${last_version}/my-xui-linux-${arch}.tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red}下载 my-xui 失败，请确保你的服务器能够下载 Github 的文件${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/uszhen/my-xui/releases/download/${last_version}/my-xui-linux-${arch}.tar.gz"
        echo -e "开始安装 my-xui v$1"
        wget -N --no-check-certificate -O /usr/local/my-xui-linux-${arch}.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}下载 my-xui v$1 失败，请确保此版本存在${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/my-xui/ ]]; then
        rm /usr/local/my-xui/ -rf
    fi

    tar zxvf my-xui-linux-${arch}.tar.gz
    rm my-xui-linux-${arch}.tar.gz -f
    cd my-xui
    chmod +x my-xui bin/xray-linux-${arch}
    cp -f my-xui.service /etc/systemd/system/
    wget --no-check-certificate -O /usr/bin/my-xui https://raw.githubusercontent.com/uszhen/my-xui/main/my-xui.sh
    chmod +x /usr/local/my-xui/my-xui.sh
    chmod +x /usr/bin/my-xui
    config_after_install
    #echo -e "如果是全新安装，默认网页端口为 ${green}54321${plain}，用户名和密码默认都是 ${green}admin${plain}"
    #echo -e "请自行确保此端口没有被其他程序占用，${yellow}并且确保 54321 端口已放行${plain}"
    #    echo -e "若想将 54321 修改为其它端口，输入 my-xui 命令进行修改，同样也要确保你修改的端口也是放行的"
    #echo -e ""
    #echo -e "如果是更新面板，则按你之前的方式访问面板"
    #echo -e ""
    systemctl daemon-reload
    systemctl enable my-xui
    systemctl start my-xui
    echo -e "${green}my-xui v${last_version}${plain} 安装完成，面板已启动，"
    echo -e ""
    echo -e "my-xui 管理脚本使用方法: "
    echo -e "----------------------------------------------"
    echo -e "my-xui              - 显示管理菜单 (功能更多)"
    echo -e "my-xui start        - 启动 my-xui 面板"
    echo -e "my-xui stop         - 停止 my-xui 面板"
    echo -e "my-xui restart      - 重启 my-xui 面板"
    echo -e "my-xui status       - 查看 my-xui 状态"
    echo -e "my-xui enable       - 设置 my-xui 开机自启"
    echo -e "my-xui disable      - 取消 my-xui 开机自启"
    echo -e "my-xui log          - 查看 my-xui 日志"
    echo -e "my-xui v2-ui        - 迁移本机器的 v2-ui 账号数据至 my-xui"
    echo -e "my-xui update       - 更新 my-xui 面板"
    echo -e "my-xui install      - 安装 my-xui 面板"
    echo -e "my-xui uninstall    - 卸载 my-xui 面板"
    echo -e "my-xui geo          - 更新 geo  数据"
    echo -e "----------------------------------------------"
}

echo -e "${green}开始安装${plain}"
install_base
install_my-xui $1
