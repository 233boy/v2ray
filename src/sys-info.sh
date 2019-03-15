#!/bin/bash
_sys_timezone() {
    IS_OPENVZ=
    if hostnamectl status | grep -q openvz; then
        IS_OPENVZ=1
    fi

    echo
    timedatectl set-timezone Asia/Shanghai
    timedatectl set-ntp true
    echo "已将你的主机设置为Asia/Shanghai时区并通过systemd-timesyncd自动同步时间。"
    echo

    if [[ $IS_OPENVZ ]]; then
        echo
        echo -e "你的主机环境为 ${yellow}Openvz${none} ，建议使用${yellow}v2ray mkcp${none}系列协议。"
        echo -e "注意：${yellow}Openvz${none} 系统时间无法由虚拟机内程序控制同步。"
        echo -e "如果主机时间跟实际相差${yellow}超过90秒${none}，v2ray将无法正常通信，请发ticket联系vps主机商调整。"
    fi
}

_sys_time() {
    echo -e "主机时间：${yellow}"
    timedatectl status | sed -n '1p;4p'
	echo -e "${none}"
}
