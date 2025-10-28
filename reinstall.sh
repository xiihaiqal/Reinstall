#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo -e "\e[1;31mError: This script must be run as root!\e[0m" 1>&2
    exit 1
fi

function show_header() {
  clear
  echo -e "\e[1;36m
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║                  \e[1;33mKINGKONGVPN VPS INSTALLER\e[1;36m                   ║
  ║                                                              ║
  ║                  Fast • Secure • Reliable                    ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
  \e[0m"
  echo -e "  \e[1;34mSupport:\e[0m \e[1;32mTelegram\e[0m: @xiihaiqal"
  echo -e "  \e[1;34mCopyright \e[0m© \e[1;35mKingKongVPN™\e[0m 2025 \e[1;31m®\e[0m"
  echo -e "\e[1;36m  ────────────────────────────────────────────────────────────\e[0m"
  echo
}

function isValidIp() {
  local ip=$1
  local ret=1
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    ip=(${ip//\./ })
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    ret=$?
  fi
  return $ret
}

function ipCheck() {
  isLegal=0
  for add in $MAINIP $GATEWAYIP $NETMASK; do
    isValidIp $add
    if [ $? -eq 1 ]; then
      isLegal=1
    fi
  done
  return $isLegal
}

function GetIp() {
  MAINIP=$(ip route get 1 | awk -F 'src ' '{print $2}' | awk '{print $1}')
  GATEWAYIP=$(ip route | grep default | awk '{print $3}')
  SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')
  value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
  NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"
}

function UpdateIp() {
  read -r -p "Your IP: " MAINIP
  read -r -p "Your Gateway: " GATEWAYIP
  read -r -p "Your Netmask: " NETMASK
}

function SetNetwork() {
  isAuto='0'
  if [[ -f '/etc/network/interfaces' ]];then
    [[ ! -z "$(sed -n '/iface.*inet static/p' /etc/network/interfaces)" ]] && isAuto='1'
    [[ -d /etc/network/interfaces.d ]] && {
      cfgNum="$(find /etc/network/interfaces.d -name '*.cfg' |wc -l)" || cfgNum='0'
      [[ "$cfgNum" -ne '0' ]] && {
        for netConfig in `ls -1 /etc/network/interfaces.d/*.cfg`
        do 
          [[ ! -z "$(cat $netConfig | sed -n '/iface.*inet static/p')" ]] && isAuto='1'
        done
      }
    }
  fi
  
  if [[ -d '/etc/sysconfig/network-scripts' ]];then
    cfgNum="$(find /etc/network/interfaces.d -name '*.cfg' |wc -l)" || cfgNum='0'
    [[ "$cfgNum" -ne '0' ]] && {
      for netConfig in `ls -1 /etc/sysconfig/network-scripts/ifcfg-* | grep -v 'lo$' | grep -v ':[0-9]\{1,\}'`
      do 
        [[ ! -z "$(cat $netConfig | sed -n '/BOOTPROTO.*[sS][tT][aA][tT][iI][cC]/p')" ]] && isAuto='1'
      done
    }
  fi
}

function NetMode() {
  show_header

  if [ "$isAuto" == '0' ]; then
    read -r -p "Using DHCP to configure network automatically? [Y/n]:" input
	input=${input:-Y}
    case $input in
      [yY][eE][sS]|[yY]) NETSTR='' ;;
      [nN][oO]|[nN]) isAuto='1' ;;
      *) clear; echo "Canceled by user!"; exit 1;;
    esac
  fi

  if [ "$isAuto" == '1' ]; then
    GetIp
    ipCheck
    if [ $? -ne 0 ]; then
      echo -e "Error occurred when detecting ip. Please input manually.\n"
      UpdateIp
    else
      show_header
      echo "IP: $MAINIP"
      echo "Gateway: $GATEWAYIP"
      echo "Netmask: $NETMASK"
      echo -e "\n"
      read -r -p "Confirm? [Y/n]:" input
      case $input in
        [yY][eE][sS]|[yY]) ;;
        [nN][oO]|[nN])
          echo -e "\n"
          UpdateIp
          ipCheck
          [[ $? -ne 0 ]] && {
            clear
            echo -e "Input error!\n"
            exit 1
          }
        ;;
        *) clear; echo "Canceled by user!"; exit 1;;
      esac
    fi
    NETSTR="--ip-addr ${MAINIP} --ip-gate ${GATEWAYIP} --ip-mask ${NETMASK}"
  fi
}

function Start() {
  show_header
  
  isCN='0'
  geoip=$(wget --no-check-certificate -qO- https://api.myip.com | grep "\"country\":\"China\"")
  if [[ "$geoip" != "" ]];then
    isCN='1'
  fi

  if [ "$isAuto" == '0' ]; then
    echo "Using DHCP mode."
  else
    echo "IP: $MAINIP"
    echo "Gateway: $GATEWAYIP"
    echo "Netmask: $NETMASK"
  fi

  [[ "$isCN" == '1' ]] && echo "Using domestic mode."

  if [ -f "/tmp/Core_Install.sh" ]; then
    rm -f /tmp/Core_Install.sh
  fi

  if [[ "$isCN" == '1' ]]; then
   wget --no-check-certificate -qO /tmp/Core_Install.sh 'https://raw.githubusercontent.com/xiihaiqal/Reinstall/refs/heads/master/Core_Install.sh' && chmod a+x /tmp/Core_Install.sh
  else 
   wget --no-check-certificate -qO /tmp/Core_Install.sh 'https://raw.githubusercontent.com/xiihaiqal/Reinstall/refs/heads/master/Core_Install.sh' && chmod a+x /tmp/Core_Install.sh
  fi

  DMIRROR=''
  UMIRROR=''

  if [[ "$isCN" == '1' ]];then
    DMIRROR="--mirror http://mirrors.aliyun.com/debian/"
    UMIRROR="--mirror http://mirrors.aliyun.com/ubuntu/"
  fi

  echo -e "\e[1;33m
  ╔══════════════════════════════════════════════════════════════╗
  ║                   SELECT AN OPERATING SYSTEM                 ║
  ╠═══════════════════════════════╦══════════════════════════════╣
  ║          \e[1;32mUBUNTU\e[1;33m               ║           \e[1;34mDEBIAN\e[1;33m             ║
  ╠═══════════════════════════════╬══════════════════════════════╣
  ║  1) Ubuntu 25.04 LTS          ║  7) Debian 13                ║
  ║  2) Ubuntu 24.04 LTS          ║  8) Debian 12                ║
  ║  3) Ubuntu 22.04 LTS          ║  9) Debian 11                ║
  ║  4) Ubuntu 20.04 LTS          ║ 10) Debian 10                ║
  ║  5) Ubuntu 18.04 LTS          ║ 11) Debian 9                 ║
  ║  6) Ubuntu 16.04 LTS          ║ 12) Debian 8                 ║
  ╠═══════════════════════════════╩══════════════════════════════╣
  ║                                                              ║
  ║  99) Custom image URL                                        ║
  ║   0) Exit                                                    ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
  \e[0m"

  echo -ne "\n\e[1;36mYour choice: \e[0m"
  read N
  case $N in
	1) echo -e "\n\e[1;32mInstalling Ubuntu 24.04 LTS...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 25.04 -v 64 -a $NETSTR $UMIRROR ;;
    2) echo -e "\n\e[1;32mInstalling Ubuntu 24.04 LTS...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 24.04 -v 64 -a $NETSTR $UMIRROR ;;
    3) echo -e "\n\e[1;32mInstalling Ubuntu 22.04 LTS...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 22.04 -v 64 -a $NETSTR $UMIRROR ;;
    4) echo -e "\n\e[1;32mInstalling Ubuntu 20.04 LTS...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 20.04 -v 64 -a $NETSTR $UMIRROR ;;
    5) echo -e "\n\e[1;32mInstalling Ubuntu 18.04 LTS...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 18.04 -v 64 -a $NETSTR $UMIRROR ;;
    6) echo -e "\n\e[1;32mInstalling Ubuntu 16.04 LTS...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 16.04 -v 64 -a $NETSTR $UMIRROR ;;
    7) echo -e "\n\e[1;32mInstalling Debian 13...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 13 -v 64 -a $NETSTR $DMIRROR ;;
    8) echo -e "\n\e[1;32mInstalling Debian 12...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 12 -v 64 -a $NETSTR $DMIRROR ;;
    9) echo -e "\n\e[1;32mInstalling Debian 11...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 11 -v 64 -a $NETSTR $DMIRROR ;;
    10) echo -e "\n\e[1;32mInstalling Debian 10...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 10 -v 64 -a $NETSTR $DMIRROR ;;
    11) echo -e "\n\e[1;32mInstalling Debian 9...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 9 -v 64 -a $NETSTR $DMIRROR ;;
    12) echo -e "\n\e[1;32mInstalling Debian 8...\nPassword: xiihaiqal\e[0m\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 8 -v 64 -a $NETSTR $DMIRROR ;;
    99)
      echo -e "\n"
      read -r -p "Custom image URL: " imgURL
      echo -e "\n"
      read -r -p "Are you sure start reinstall? [Y/n]: " input
      case $input in
        [yY][eE][sS]|[yY]) bash /tmp/Core_Install.sh $NETSTR -dd $imgURL $DMIRROR ;;
        *) clear; echo "Canceled by user!"; exit 1;;
      esac
      ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
  esac
}

SetNetwork
NetMode
Start
