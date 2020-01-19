#!/bin/bash

# support ipv6-only VPS 
# no longer support update new version filebrowser
# filebrowser version 2.0.12
# port 9184
# edit by scaleya 
# author by 233blog

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
none='\e[0m'

[[ $(id -u) != 0 ]] && echo -e " \n哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

# 笨笨的检测方法
if [[ -f /usr/bin/apt-get || -f /usr/bin/yum ]] && [[ -f /bin/systemctl ]]; then

	if [[ -f /usr/bin/yum ]]; then

		cmd="yum"

	fi

else

	echo -e " \n哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}\n" && exit 1

fi

if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
	filebrowser="linux-386-filebrowser.tar.gz"
elif [[ $sys_bit == "x86_64" ]]; then
	filebrowser="linux-386-filebrowser.tar.gz"
elif [[ $sys_bit == "aarch64" ]]; then
	filebrowser="linux-arm64-filebrowser.tar.gz"
else
	echo -e " \n$red毛支持你的系统....$none\n" && exit 1
fi

install() {
	$cmd install wget -y
	ver=$(curl -s https://scaleya.netlify.com/share/v2ray_6/filebrowser_latest | grep 'tag_name' | cut -d\" -f4)
	Filebrowser_download_link="https://scaleya.netlify.com/share/v2ray_6/filebrowser/download/$filebrowser"
	mkdir -p /tmp/Filebrowser
	if ! wget --no-check-certificate --no-cache -O "/tmp/Filebrowser.tar.gz" $Filebrowser_download_link; then
		echo -e "$red 下载 Filebrowser 失败！$none" && exit 1
	fi
	tar zxf /tmp/Filebrowser.tar.gz -C /tmp/Filebrowser
	cp -f /tmp/Filebrowser/filebrowser /usr/bin/filebrowser
	chmod +x /usr/bin/filebrowser
	if [[ -f /usr/bin/filebrowser ]]; then
		cat >/lib/systemd/system/filebrowser.service <<-EOF
[Unit]
Description=Filebrowser Service
After=network.target
Wants=network.target

[Service]
Type=simple
PIDFile=/var/run/filebrowser.pid
ExecStart=/usr/bin/filebrowser -c /etc/filebrowser/filebrowser.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
		EOF

		mkdir -p /etc/filebrowser
		cat >/etc/filebrowser/filebrowser.json <<-EOF
{
    "port": 9184,
    "baseURL": "",
    "address": "",
    "log": "stdout",
    "database": "/etc/filebrowser/database.db",
    "root": "/etc/filebrowser/"
}
		EOF

		get_ip
		systemctl enable filebrowser
		systemctl start filebrowser

		clear
		echo -e "
		Filebrowser 安装完成啦！

		预览地址: ${yellow}http://${ip}:9184/$none

		用户名: ${green}admin$none

		密码: ${green}admin$none

		$red重要提示，大佬赶紧的打开预览地址登录 并修改密码啊啊啊啊啊$none

		脚本帮助说明: https://233blog.com/post/26/
		"
	else
		echo -e " \n$red安装失败...$none\n"
	fi
	rm -rf /tmp/Filebrowser
	rm -rf /tmp/Filebrowser.tar.gz
}
uninstall() {
	if [[ -f /usr/bin/filebrowser && -f /etc/filebrowser/filebrowser.json ]]; then
		Filebrowser_pid=$(pgrep "filebrowser")
		[ $Filebrowser_pid ] && systemctl stop filebrowser
		systemctl disable filebrowser >/dev/null 2>&1
		rm -rf /usr/bin/filebrowser
		rm -rf /etc/filebrowser
		rm -rf /lib/systemd/system/filebrowser.service
		echo -e " \n$green卸载完成...$none\n" && exit 1
	else
		echo -e " \n$red大胸弟...你貌似毛有安装 Filebrowser ....卸载个鸡鸡哦...$none\n" && exit 1
	fi
}
get_ip() {
	ip=$(curl -s ipinfo.io/ip)
}
error() {

	echo -e "\n$red 输入错误！$none\n"

}
while :; do
	echo
	echo "........... Filebrowser 快速一键安装 by 233blog.com .........."
	echo
	echo "帮助说明: https://233blog.com/post/26/"
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	read -p "请选择[1-2]:" choose
	case $choose in
	1)
		install
		break
		;;
	2)
		uninstall
		break
		;;
	*)
		error
		;;
	esac
done