

_get_ssray_latest_version() {
	ssray_latest_ver="$(curl -H 'Cache-Control: no-cache' -s https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest | grep 'tag_name' | cut -d\" -f4)"

	if [[ ! $ssray_latest_ver ]]; then
		echo
		echo -e " $red获取 V2Ray 最新版本失败!!!$none"
		echo
		echo -e " 请尝试执行如下命令: $green echo 'nameserver 8.8.8.8' >/etc/resolv.conf $none"
		echo
		echo " 然后再重新运行脚本...."
		echo
		exit 1
	fi
}

_download_ssray_file() {
	_get_ssray_latest_version
	[[ -d /tmp/ssray ]] && rm -rf /tmp/ssray
	mkdir -p /tmp/ssray
	ssray_tmp_file="/tmp/ssray.zip"
	ssray_download_link="https://github.com/shadowsocks/v2ray-plugin/releases/download/${ssray_latest_ver}/v2ray-plugin-linux-${v2arch}-${ssray_latest_ver}.tar.gz"

	if ! wget --no-check-certificate -O "$ssray_tmp_file" $ssray_download_link; then
		echo -e "
        $red 下载 V2Ray Plugin 失败啦..可能是你的 VPS 网络太辣鸡了...请重试...$none
        " && exit 1
	fi

	tar xvfz $ssray_tmp_file -C /tmp
	install -m755 $(ls /tmp/v2ray-plugin*) /usr/local/bin/v2ray-plugin
	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/v2ray-plugin
}

_install_ssray_service() {
	if [[ $systemd ]]; then
		install -m644 /etc/v2ray/233boy/v2ray/src/ssray.service "/lib/systemd/system/"
		install -m644 /etc/v2ray/233boy/v2ray/src/ssray.conf /etc/v2ray/
		sed -i "s/__REMOTEPORT__/${ssrayport}/; s/__LOCALPORT__/${ssport}/; s/__OPTION__/${ssrayopt}/;" /etc/v2ray/ssray.conf
		systemctl enable ssray
	else
        $red 暂时不资瓷...$none
		exit 1
	fi
}

_update_ssray_version() {
	_get_ssray_latest_version
	if [[ $ssray_ver != $ssray_latest_ver ]]; then
		echo
		echo -e " $green 咦...发现新版本耶....正在拼命更新.......$none"
		echo
		_download_ssray_file
		do_service restart ssray
		echo
		echo -e " $green 更新成功啦...当前 V2Ray plugin 版本: ${cyan}$ssray_latest_ver$none"
		echo
		echo -e " $yellow 温馨提示: 为了避免出现莫名其妙的问题...V2Ray 客户端的版本最好和服务器的版本保持一致$none"
		echo
	else
		echo
		echo -e " $green 木有发现新版本....$none"
		echo
	fi
}

_uninstall_ssray() {
	if [[ $systemd ]]; then
		systemctl disable ssray
		rm -f "/lib/systemd/system/ssray.service" /etc/v2ray/ssray.conf 
	fi
	rm -f /usr/local/bin/v2ray-plugin 
}