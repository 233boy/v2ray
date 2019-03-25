_do_install() {
	echo
	echo
	echo -e "$yellow 同步系统仓库并安装必须组件，请骚吼~~~~~~~~~ $none"
	echo
	echo
	if [[ $cmd == "apt-get" ]]; then
		$cmd update -y
		$cmd install -y socat lrzsz git zip unzip curl wget qrencode libcap2-bin patch diffutils jq dbus
	else
		# $cmd install -y lrzsz git zip unzip curl wget qrencode libcap iptables-services
		$cmd install -y socat lrzsz git zip unzip curl wget qrencode libcap patch diffutils
		if [[ ! $(command -v jq) ]]; then
			pushd /tmp
			if curl -sL -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-${_jqArch}; then
				install -m 755 jq /usr/local/bin/
				rm -f jq
			else
				echo
				_red "安装 jq 失败..."
				echo
				exit 1
			fi
			popd
		fi
	fi
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	_disableselinux
	_sys_timezone
	_sys_time
	echo
	echo
	[ -d /etc/v2ray ] && rm -rf /etc/v2ray

	if [[ $local_install ]]; then
		if [[ ! -d $(pwd)/config ]]; then
			echo
			echo -e "$red 哎呀呀...安装失败了咯...$none"
			echo
			echo -e " 请确保你有完整的上传 $author 的 V2Ray 一键安装脚本 & 管理脚本到当前 ${green}$(pwd) $none目录下"
			echo
			exit 1
		fi
		mkdir -p /etc/v2ray/233boy/v2ray
		cp -rf $(pwd) /etc/v2ray/233boy/v2ray/
	else
		pushd /tmp
		git clone --depth=1 https://github.com/233boy/v2ray -b "$_gitbranch" /etc/v2ray/233boy/v2ray
		popd

	fi

	if [[ ! -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo -e "$red 哎呀呀...克隆脚本仓库出错了...$none"
		echo
		echo -e " 温馨提示..... 请尝试自行安装 Git: ${green}$cmd install -y git $none 之后再安装此脚本"
		echo
		exit 1
	fi
}
