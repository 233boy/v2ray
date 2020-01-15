[[ -z $ip ]] && get_ip
_v2_args() {
	header="none"
	if [[ $is_path ]]; then
		_path="/$path"
	else
		_path="/"
	fi
	case $v2ray_transport in
	1 | 18)
		net="tcp"
		;;
	2 | 19)
		net="tcp"
		header="http"
		host="www.baidu.com"
		;;
	3 | 4 | 20)
		net="ws"
		;;
	5)
		net="h2"
		;;
	6 | 21)
		net="kcp"
		;;
	7 | 22)
		net="kcp"
		header="utp"
		;;
	8 | 23)
		net="kcp"
		header="srtp"
		;;
	9 | 24)
		net="kcp"
		header="wechat-video"
		;;
	10 | 25)
		net="kcp"
		header="dtls"
		;;
	11 | 26)
		net="kcp"
		header="wireguard"
		;;
	12 | 27)
		net="quic"
		;;
	13 | 28)
		net="quic"
		header="utp"
		;;
	14 | 29)
		net="quic"
		header="srtp"
		;;
	15 | 30)
		net="quic"
		header="wechat-video"
		;;
	16 | 31)
		net="quic"
		header="dtls"
		;;
	17 | 32)
		net="quic"
		header="wireguard"
		;;
	esac
}

_v2_info() {
	echo
	echo
	echo "---------- V2Ray 配置信息 -------------"
	if [[ $v2ray_transport == [45] ]]; then
		if [[ ! $caddy ]]; then
			echo
			echo -e " $red警告！$none$yellow请自行配置 TLS...教程: https://233v2.com/post/3/$none"
		fi
		echo
		echo -e "$yellow 地址 (Address) = $cyan${domain}$none"
		echo
		echo -e "$yellow 端口 (Port) = ${cyan}443${none}"
		echo
		echo -e "$yellow 用户ID (User ID / UUID) = $cyan${v2ray_id}$none"
		echo
		echo -e "$yellow 额外ID (Alter Id) = ${cyan}${alterId}${none}"
		echo
		echo -e "$yellow 传输协议 (Network) = ${cyan}${net}$none"
		echo
		echo -e "$yellow 伪装类型 (header type) = ${cyan}${header}$none"
		echo
		echo -e "$yellow 伪装域名 (host) = ${cyan}${domain}$none"
		echo
		echo -e "$yellow 路径 (path) = ${cyan}${_path}$none"
		echo
		echo -e "$yellow TLS (Enable TLS) = ${cyan}打开$none"
		echo
		if [[ $ban_ad ]]; then
			echo " 备注: 广告拦截已开启.."
			echo
		fi
	else
		echo
		echo -e "$yellow 地址 (Address) = $cyan${ip}$none"
		echo
		echo -e "$yellow 端口 (Port) = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow 用户ID (User ID / UUID) = $cyan${v2ray_id}$none"
		echo
		echo -e "$yellow 额外ID (Alter Id) = ${cyan}${alterId}${none}"
		echo
		echo -e "$yellow 传输协议 (Network) = ${cyan}${net}$none"
		echo
		echo -e "$yellow 伪装类型 (header type) = ${cyan}${header}$none"
		echo
	fi
	if [[ $v2ray_transport -ge 18 ]] && [[ $ban_ad ]]; then
		echo " 备注: 动态端口已启用...广告拦截已开启..."
		echo
	elif [[ $v2ray_transport -ge 18 ]]; then
		echo " 备注: 动态端口已启用..."
		echo
	elif [[ $ban_ad ]]; then
		echo " 备注: 广告拦截已开启.."
		echo
	fi
	echo "---------- END -------------"
	echo
	echo "V2Ray 客户端使用教程: https://233v2.com/post/4/"
	echo
	echo -e "提示: 输入$cyan v2ray url $none可生成 vmess URL 链接 / 输入$cyan v2ray qr $none可生成二维码链接"
	echo
	echo -e "${yellow}免被墙..推荐使用JMS: ${cyan}https://getjms.com${none}"
	echo
}
