_get_latest_version() {
	v2ray_latest_ver="$(curl -H 'Cache-Control: no-cache' -s https://api.github.com/repos/v2ray/v2ray-core/releases/latest | grep 'tag_name' | cut -d\" -f4)"

	if [[ ! $v2ray_latest_ver ]]; then
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

_download_v2ray_file() {
	_get_latest_version
	[[ -d /tmp/v2ray ]] && rm -rf /tmp/v2ray
	mkdir -p /tmp/v2ray
	v2ray_tmp_file="/tmp/v2ray/v2ray.zip"
	v2ray_download_link="https://github.com/v2ray/v2ray-core/releases/download/$v2ray_latest_ver/v2ray-linux-${v2ray_bit}.zip"

	if ! wget --no-check-certificate -O "$v2ray_tmp_file" $v2ray_download_link; then
		echo -e "
        $red 下载 V2Ray 失败啦..可能是你的 VPS 网络太辣鸡了...请重试...$none
        " && exit 1
	fi

	unzip $v2ray_tmp_file -d "/tmp/v2ray/"
	mkdir -p /usr/bin/v2ray
	cp -f "/tmp/v2ray/v2ray" "/usr/bin/v2ray/v2ray"
	chmod +x "/usr/bin/v2ray/v2ray"
	cp -f "/tmp/v2ray/v2ctl" "/usr/bin/v2ray/v2ctl"
	chmod +x "/usr/bin/v2ray/v2ctl"
}

_install_v2ray_service() {
	if [[ $systemd ]]; then
		cp -f "/tmp/v2ray/systemd/v2ray.service" "/lib/systemd/system/"
		sed -i "s/on-failure/always/" /lib/systemd/system/v2ray.service
		systemctl enable v2ray
	else
		apt-get install -y daemon
		cp "/tmp/v2ray/systemv/v2ray" "/etc/init.d/v2ray"
		chmod +x "/etc/init.d/v2ray"
		update-rc.d -f v2ray defaults
	fi
}

_update_v2ray_version() {
	_get_latest_version
	if [[ $v2ray_ver != $v2ray_latest_ver ]]; then
		echo
		echo -e " $green 咦...发现新版本耶....正在拼命更新.......$none"
		echo
		_download_v2ray_file
		do_service restart v2ray
		echo
		echo -e " $green 更新成功啦...当前 V2Ray 版本: ${cyan}$v2ray_latest_ver$none"
		echo
		echo -e " $yellow 温馨提示: 为了避免出现莫名其妙的问题...V2Ray 客户端的版本最好和服务器的版本保持一致$none"
		echo
	else
		echo
		echo -e " $green 木有发现新版本....$none"
		echo
	fi
}

_mkdir_dir() {
	mkdir -p /var/log/v2ray
	mkdir -p /etc/v2ray
}
