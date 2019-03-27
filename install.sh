#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

author=233boy
# Root
[[ $(id -u) != 0 ]] && echo -e "\n 哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
	v2ray_bit="32"
	v2arch="386"
elif [[ $sys_bit == "x86_64" ]]; then
	v2ray_bit="64"
	v2arch="amd64"
else
	echo -e " 
	哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1
fi

# 笨笨的检测方法
if [[ -f /usr/bin/apt-get || -f /usr/bin/yum ]] && [[ -f /bin/systemctl ]]; then

	if [[ -f /usr/bin/yum ]]; then

		cmd="yum"

	fi

else

	echo -e " 
	哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi

uuid=$(cat /proc/sys/kernel/random/uuid)
v2ray_server_config="/etc/v2ray/config.json"
v2ray_client_config="/etc/v2ray/233blog_v2ray_config.json"
backup="/etc/v2ray/233blog_v2ray_backup.conf"
_v2ray_sh="/usr/local/sbin/v2ray"
systemd=true
# _test=true

# site
_site="dduck.xyz"

transport=(
	TCP
	TCP_HTTP
	WebSocket
	"WebSocket + TLS"
	HTTP/2
	mKCP
	mKCP_utp
	mKCP_srtp
	mKCP_wechat-video
	mKCP_dtls
	mKCP_wireguard
	QUIC
	QUIC_utp
	QUIC_srtp
	QUIC_wechat-video
	QUIC_dtls
	QUIC_wireguard
	TCP_dynamicPort
	TCP_HTTP_dynamicPort
	WebSocket_dynamicPort
	mKCP_dynamicPort
	mKCP_utp_dynamicPort
	mKCP_srtp_dynamicPort
	mKCP_wechat-video_dynamicPort
	mKCP_dtls_dynamicPort
	mKCP_wireguard_dynamicPort
	QUIC_dynamicPort
	QUIC_utp_dynamicPort
	QUIC_srtp_dynamicPort
	QUIC_wechat-video_dynamicPort
	QUIC_dtls_dynamicPort
	QUIC_wireguard_dynamicPort
)

ciphers=(
	aes-128-cfb
	aes-256-cfb
	chacha20
	chacha20-ietf
	aes-128-gcm
	aes-256-gcm
	chacha20-ietf-poly1305
)

_load() {
	local _dir="/etc/v2ray/233boy/v2ray/src/"
	. "${_dir}$@"
}

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
	echo -e "\n主机时间：${yellow}"
	timedatectl status | sed -n '1p;4p'
	echo -e "${none}"
	[[ $IS_OPENV ]] && pause
}

v2ray_config() {
	# clear
	echo
	while :; do
		echo -e "请选择 "$yellow"V2Ray"$none" 传输协议 [${magenta}1-${#transport[*]}$none]"
		echo
		for ((i = 1; i <= ${#transport[*]}; i++)); do
			Stream="${transport[$i - 1]}"
			if [[ "$i" -le 9 ]]; then
				# echo
				echo -e "$yellow  $i. $none${Stream}"
			else
				# echo
				echo -e "$yellow $i. $none${Stream}"
			fi
		done
		echo
		echo "备注1: 含有 [dynamicPort] 的即启用动态端口.."
		echo "备注2: [utp | srtp | wechat-video | dtls | wireguard] 分别伪装成 [BT下载 | 视频通话 | 微信视频通话 | DTLS 1.2 数据包 | WireGuard 数据包]"
		echo
		read -p "$(echo -e "(默认协议: ${cyan}TCP$none)"):" new_v2ray_transport
		[ -z "$new_v2ray_transport" ] && new_v2ray_transport=1
		case $new_v2ray_transport in
		[1-9] | [1-2][0-9] | 3[0-2])
			echo
			echo
			echo -e "$yellow V2Ray 传输协议 = $cyan${transport[$new_v2ray_transport - 1]}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
	new_v2ray_port_config
}
new_v2ray_port_config() {
	case $new_v2ray_transport in
	4 | 5)
		tls_config
		;;
	*)
		local random=$(shuf -i20001-65535 -n1)
		while :; do
			echo -e "请输入 "$yellow"V2Ray"$none" 端口 ["$magenta"1-65535"$none"]"
			read -p "$(echo -e "(默认端口: ${cyan}${random}$none):")" new_v2ray_port
			[ -z "$new_v2ray_port" ] && new_v2ray_port=$random
			case $new_v2ray_port in
			[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
				echo
				echo
				echo -e "$yellow V2Ray 端口 = $cyan$new_v2ray_port$none"
				echo "----------------------------------------------------------------"
				echo
				break
				;;
			*)
				error
				;;
			esac
		done
		if [[ $new_v2ray_transport -ge 18 ]]; then
			v2ray_dynamic_port_start
		fi
		;;
	esac
}

v2ray_dynamic_port_start() {

	while :; do
		echo -e "请输入 "$yellow"V2Ray 动态端口开始 "$none"范围 ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(默认开始端口: ${cyan}10000$none):")" v2ray_dynamic_port_start_input
		[ -z $v2ray_dynamic_port_start_input ] && v2ray_dynamic_port_start_input=10000
		case $v2ray_dynamic_port_start_input in
		$new_v2ray_port)
			echo
			echo " 不能和 V2Ray 端口一毛一样...."
			echo
			echo -e " 当前 V2Ray 端口：${cyan}$new_v2ray_port${none}"
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow V2Ray 动态端口开始 = $cyan$v2ray_dynamic_port_start_input$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac

	done

	if [[ $v2ray_dynamic_port_start_input -lt $new_v2ray_port ]]; then
		lt_new_v2ray_port=true
	fi

	v2ray_dynamic_port_end
}
v2ray_dynamic_port_end() {

	while :; do
		echo -e "请输入 "$yellow"V2Ray 动态端口结束 "$none"范围 ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(默认结束端口: ${cyan}20000$none):")" v2ray_dynamic_port_end_input
		[ -z $v2ray_dynamic_port_end_input ] && v2ray_dynamic_port_end_input=20000
		case $v2ray_dynamic_port_end_input in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])

			if [[ $v2ray_dynamic_port_end_input -le $v2ray_dynamic_port_start_input ]]; then
				echo
				echo " 不能小于或等于 V2Ray 动态端口开始范围"
				echo
				echo -e " 当前 V2Ray 动态端口开始：${cyan}$v2ray_dynamic_port_start_input${none}"
				error
			elif [ $lt_new_v2ray_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $new_v2ray_port ]]; then
				echo
				echo " V2Ray 动态端口结束范围 不能包括 V2Ray 端口..."
				echo
				echo -e " 当前 V2Ray 端口：${cyan}$new_v2ray_port${none}"
				error
			else
				echo
				echo
				echo -e "$yellow V2Ray 动态端口结束 = $cyan$v2ray_dynamic_port_end_input$none"
				echo "----------------------------------------------------------------"
				echo
				break
			fi
			;;
		*)
			error
			;;
		esac

	done

}

tls_config() {

	echo
	local random=$(shuf -i20001-65535 -n1)
	while :; do
		echo -e "请输入 "$yellow"V2Ray"$none" 端口 ["$magenta"1-65535"$none"]，不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
		read -p "$(echo -e "(默认端口: ${cyan}${random}$none):")" new_v2ray_port
		[ -z "$new_v2ray_port" ] && new_v2ray_port=$random
		case $new_v2ray_port in
		80)
			echo
			echo " ...都说了不能选择 80 端口了咯....."
			error
			;;
		443)
			echo
			echo " ..都说了不能选择 443 端口了咯....."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow V2Ray 端口 = $cyan$new_v2ray_port$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done

	while :; do
		echo
		echo -e "请输入一个 $magenta正确的域名$none，一定一定一定要正确，不！能！出！错！"
		read -p "(例如：233blog.com): " domain
		[ -z "$domain" ] && error && continue
		echo
		echo
		echo -e "$yellow 你的域名 = $cyan$domain$none"
		echo "----------------------------------------------------------------"
		break
	done
	get_ip
	echo
	echo
	echo -e "$yellow 请将 $magenta$domain$none $yellow解析到: $cyan$ip$none"
	echo
	echo -e "$yellow 请将 $magenta$domain$none $yellow解析到: $cyan$ip$none"
	echo
	echo -e "$yellow 请将 $magenta$domain$none $yellow解析到: $cyan$ip$none"
	echo "----------------------------------------------------------------"
	echo

	while :; do

		read -p "$(echo -e "(是否已经正确解析: [${magenta}Y$none]):") " record
		if [[ -z "$record" ]]; then
			error
		else
			if [[ "$record" == [Yy] ]]; then
				domain_check
				echo
				echo
				echo -e "$yellow 域名解析 = ${cyan}我确定已经有解析了$none"
				echo "----------------------------------------------------------------"
				echo
				break
			else
				error
			fi
		fi

	done

	if [[ $new_v2ray_transport -ne 5 ]]; then
		auto_tls_config
	else
		caddy=true
		install_caddy_info="打开"
	fi

	if [[ $caddy ]]; then
		path_config_ask
	fi
}
auto_tls_config() {
	echo -e "

		安装 Caddy 来实现 自动配置 TLS
		
		如果你已经安装 Nginx 或 Caddy

		$yellow并且..自己能搞定配置 TLS$none

		那么就不需要 打开自动配置 TLS
		"
	echo "----------------------------------------------------------------"
	echo

	while :; do

		read -p "$(echo -e "(是否自动配置 TLS: [${magenta}Y/N$none]):") " auto_install_caddy
		if [[ -z "$auto_install_caddy" ]]; then
			error
		else
			if [[ "$auto_install_caddy" == [Yy] ]]; then
				caddy=true
				install_caddy_info="打开"
				echo
				echo
				echo -e "$yellow 自动配置 TLS = $cyan$install_caddy_info$none"
				echo "----------------------------------------------------------------"
				echo
				break
			elif [[ "$auto_install_caddy" == [Nn] ]]; then
				install_caddy_info="关闭"
				echo
				echo
				echo -e "$yellow 自动配置 TLS = $cyan$install_caddy_info$none"
				echo "----------------------------------------------------------------"
				echo
				break
			else
				error
			fi
		fi

	done
}
path_config_ask() {
	echo
	while :; do
		echo -e "是否开启 网站伪装 和 路径分流 [${magenta}Y/N$none]"
		read -p "$(echo -e "(默认: [${cyan}N$none]):")" path_ask
		[[ -z $path_ask ]] && path_ask="n"

		case $path_ask in
		Y | y)
			path_config
			break
			;;
		N | n)
			echo
			echo
			echo -e "$yellow 网站伪装 和 路径分流 = $cyan不想配置$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
}
path_config() {
	echo
	while :; do
		echo -e "请输入想要 ${magenta}用来分流的路径$none , 例如 /233blog , 那么只需要输入 233blog 即可"
		read -p "$(echo -e "(默认: [${cyan}233blog$none]):")" path
		[[ -z $path ]] && path="233blog"

		case $path in
		*[/$]*)
			echo
			echo -e " 由于这个脚本太辣鸡了..所以分流的路径不能包含$red / $none或$red $ $none这两个符号.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow 分流的路径 = ${cyan}/${path}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done
	is_path=true
	proxy_site_config
}
proxy_site_config() {
	echo
	while :; do
		echo -e "请输入 ${magenta}一个正确的$none ${cyan}网址$none 用来作为 ${cyan}网站的伪装$none , 例如 https://liyafly.com"
		echo -e "举例...你当前的域名是 $green$domain$none , 伪装的网址的是 https://liyafly.com"
		echo -e "然后打开你的域名时候...显示出来的内容就是来自 https://liyafly.com 的内容"
		echo -e "其实就是一个反代...明白就好..."
		echo -e "如果不能伪装成功...可以使用 v2ray config 修改伪装的网址"
		read -p "$(echo -e "(默认: [${cyan}https://liyafly.com$none]):")" proxy_site
		[[ -z $proxy_site ]] && proxy_site="https://liyafly.com"

		case $proxy_site in
		*[#$]*)
			echo
			echo -e " 由于这个脚本太辣鸡了..所以伪装的网址不能包含$red # $none或$red $ $none这两个符号.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow 伪装的网址 = ${cyan}${proxy_site}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done
}

blocked_hosts() {
	echo
	while :; do
		echo -e "是否开启广告拦截(会影响性能) [${magenta}Y/N$none]"
		read -p "$(echo -e "(默认 [${cyan}N$none]):")" blocked_ad
		[[ -z $blocked_ad ]] && blocked_ad="n"

		case $blocked_ad in
		Y | y)
			blocked_ad_info="开启"
			ban_ad=true
			echo
			echo
			echo -e "$yellow 广告拦截 = $cyan开启$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		N | n)
			blocked_ad_info="关闭"
			echo
			echo
			echo -e "$yellow 广告拦截 = $cyan关闭$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
}
shadowsocks_config() {

	echo

	while :; do
		echo -e "是否配置 ${yellow}Shadowsocks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(默认 [${cyan}N$none]):") " install_shadowsocks
		[[ -z "$install_shadowsocks" ]] && install_shadowsocks="n"
		if [[ "$install_shadowsocks" == [Yy] ]]; then
			echo
			shadowsocks=true
			shadowsocks_port_config
			break
		elif [[ "$install_shadowsocks" == [Nn] ]]; then
			break
		else
			error
		fi

	done

}

shadowsocks_port_config() {
	local random=$(shuf -i20001-65535 -n1)
	while :; do
		echo -e "请输入 "$yellow"Shadowsocks"$none" 端口 ["$magenta"1-65535"$none"]，不能和 "$yellow"V2Ray"$none" 端口相同"
		read -p "$(echo -e "(默认端口: ${cyan}${random}$none):") " ssport
		[ -z "$ssport" ] && ssport=$random
		case $ssport in
		$new_v2ray_port)
			echo
			echo " 不能和 V2Ray 端口一毛一样...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $new_v2ray_transport == [45] ]]; then
				local tls=true
			fi
			if [[ $tls && $ssport == "80" ]] || [[ $tls && $ssport == "443" ]]; then
				echo
				echo -e "由于你已选择了 "$green"WebSocket + TLS $none或$green HTTP/2"$none" 传输协议."
				echo
				echo -e "所以不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
				error
			elif [[ $v2ray_dynamic_port_start_input == $ssport || $v2ray_dynamic_port_end_input == $ssport ]]; then
				local multi_port="${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}"
				echo
				echo " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：$multi_port"
				error
			elif [[ $v2ray_dynamic_port_start_input -lt $ssport && $ssport -le $v2ray_dynamic_port_end_input ]]; then
				local multi_port="${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}"
				echo
				echo " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：$multi_port"
				error
			else
				echo
				echo
				echo -e "$yellow Shadowsocks 端口 = $cyan$ssport$none"
				echo "----------------------------------------------------------------"
				echo
				break
			fi
			;;
		*)
			error
			;;
		esac

	done

	shadowsocks_password_config
}
shadowsocks_password_config() {

	while :; do
		echo -e "请输入 "$yellow"Shadowsocks"$none" 密码"
		read -p "$(echo -e "(默认密码: ${cyan}233blog.com$none)"): " sspass
		[ -z "$sspass" ] && sspass="233blog.com"
		case $sspass in
		*[/$]*)
			echo
			echo -e " 由于这个脚本太辣鸡了..所以密码不能包含$red / $none或$red $ $none这两个符号.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow Shadowsocks 密码 = $cyan$sspass$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac

	done

	shadowsocks_ciphers_config
}
shadowsocks_ciphers_config() {

	while :; do
		echo -e "请选择 "$yellow"Shadowsocks"$none" 加密协议 [${magenta}1-${#ciphers[*]}$none]"
		for ((i = 1; i <= ${#ciphers[*]}; i++)); do
			ciphers_show="${ciphers[$i - 1]}"
			echo
			echo -e "$yellow $i. $none${ciphers_show}"
		done
		echo
		read -p "$(echo -e "(默认加密协议: ${cyan}${ciphers[6]}$none)"):" ssciphers_opt
		[ -z "$ssciphers_opt" ] && ssciphers_opt=7
		case $ssciphers_opt in
		[1-7])
			ssciphers=${ciphers[$ssciphers_opt - 1]}
			echo
			echo
			echo -e "$yellow Shadowsocks 加密协议 = $cyan${ssciphers}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac

	done
	pause
}

install_info() {
	clear
	echo
	echo " ....准备安装了咯..看看有毛有配置正确了..."
	echo
	echo "---------- 安装信息 -------------"
	echo
	echo -e "$yellow V2Ray 传输协议 = $cyan${transport[$new_v2ray_transport - 1]}$none"

	if [[ $new_v2ray_transport == [45] ]]; then
		echo
		echo -e "$yellow V2Ray 端口 = $cyan$new_v2ray_port$none"
		echo
		echo -e "$yellow 你的域名 = $cyan$domain$none"
		echo
		echo -e "$yellow 域名解析 = ${cyan}我确定已经有解析了$none"
		echo
		echo -e "$yellow 自动配置 TLS = $cyan$install_caddy_info$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow 广告拦截 = $cyan$blocked_ad_info$none"
		fi
		if [[ $is_path ]]; then
			echo
			echo -e "$yellow 路径分流 = ${cyan}/${path}$none"
		fi
	elif [[ $new_v2ray_transport -ge 18 ]]; then
		echo
		echo -e "$yellow V2Ray 端口 = $cyan$new_v2ray_port$none"
		echo
		echo -e "$yellow V2Ray 动态端口范围 = $cyan${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow 广告拦截 = $cyan$blocked_ad_info$none"
		fi
	else
		echo
		echo -e "$yellow V2Ray 端口 = $cyan$new_v2ray_port$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow 广告拦截 = $cyan$blocked_ad_info$none"
		fi
	fi
	if [ $shadowsocks ]; then
		echo
		echo -e "$yellow Shadowsocks 端口 = $cyan$ssport$none"
		echo
		echo -e "$yellow Shadowsocks 密码 = $cyan$sspass$none"
		echo
		echo -e "$yellow Shadowsocks 加密协议 = $cyan${ssciphers}$none"
	else
		echo
		echo -e "$yellow 是否配置 Shadowsocks = ${cyan}未配置${none}"
	fi
	echo
	echo "---------- END -------------"
	echo
	pause
	echo
}

domain_check() {
	test_domain=$(ping $domain -c 1 | grep -oE -m1 "([0-9]{1,3}\.){3}[0-9]{1,3}")
	if [[ $test_domain != $ip ]]; then
		echo
		echo -e "$red 检测域名解析错误....$none"
		echo
		echo -e " 你的域名: $yellow$domain$none 未解析到: $cyan$ip$none"
		echo
		echo -e " 你的域名当前解析到: $cyan$test_domain$none"
		echo
		echo "备注...如果你的域名是使用 Cloudflare 解析的话..在 Status 那里点一下那图标..让它变灰"
		echo
		exit 1
	fi
}

install_caddy() {
	# download caddy file then install
	_load download-caddy.sh
	_download_caddy_file
	_install_caddy_service
	caddy_config

}
caddy_config() {
	# local email=$(shuf -i1-10000000000 -n1)
	_load caddy-config.sh

	systemctl restart caddy
}

install_v2ray() {
	## install
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

	# download v2ray file then install
	_load download-v2ray.sh
	_download_v2ray_file
	_install_v2ray_service
	_mkdir_dir
}

open_port() {
	_load iptables.sh
	_iptables_add $1
}
del_port() {
	_load iptables.sh
	_iptables_del $1
}

config() {
	cp -f /etc/v2ray/233boy/v2ray/config/backup.conf $backup
	ln -s /etc/v2ray/233boy/v2ray/v2ray.sh $_v2ray_sh
	chmod +x $_v2ray_sh

	ban_bt=true
	alterId=233
	v2ray_id=$uuid
	v2ray_port=$new_v2ray_port
	v2ray_transport=$new_v2ray_transport

	if [[ $new_v2ray_transport -ge 18 ]]; then
		v2ray_dynamicPort_start=${v2ray_dynamic_port_start_input}
		v2ray_dynamicPort_end=${v2ray_dynamic_port_end_input}
	fi
	_load config.sh

	## save iptables rules
	_load iptables.sh
	_iptables_save

	[[ $shadowsocks ]] && open_port $ssport
	if [[ $new_v2ray_transport == [45] ]]; then
		open_port "80"
		open_port "443"
		open_port $new_v2ray_port
	elif [[ $new_v2ray_transport -ge 18 ]]; then
		open_port $new_v2ray_port
		open_port "multiport"
	else
		open_port $new_v2ray_port
	fi
	systemctl restart v2ray
	backup_config

	## check status
	_load status.sh
	_check_status
}

backup_config() {

	# load backup script
	_load backup.sh

	## v2ray transport, port, uuid
	_first_backup v2ray

	## dynamic port
	if [[ $new_v2ray_transport -ge 18 ]]; then
		_first_backup dynamicPort
	fi

	## ss
	if [[ $shadowsocks ]]; then
		_first_backup +ss
	fi

	## domain, ws+tls / http2
	if [[ $new_v2ray_transport == [45] ]]; then
		_first_backup domain
	fi

	## ws+tls / http2, auto config tls
	if [[ $caddy ]]; then
		_first_backup caddy
	fi

	## ban ad
	if [[ $ban_ad ]]; then
		_first_backup +ad
	fi

	## ws+tls / http2, path
	if [[ $is_path ]]; then
		_first_backup +path
	fi
}

get_ip() {
	ip=$(curl -4 -s https://ipinfo.io/ip)
	[[ -z $ip ]] && ip=$(curl -4 -s https://api.ip.sb/ip)
	[[ -z $ip ]] && ip=$(curl -4 -s https://api.ipify.org)
	[[ -z $ip ]] && ip=$(curl -4 -s https://ip.seeip.org)
	[[ -z $ip ]] && ip=$(curl -4 -s https://ifconfig.co/ip)
	[[ -z $ip ]] && ip=$(curl -4 -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && ip=$(curl -4 -s icanhazip.com)
	[[ -z $ip ]] && ip=$(curl -4 -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n" && exit

	v6ip=$(curl -m 5 -6 -s https://ifconfig.co/ip)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s https://api.ip.sb/ip)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s https://ip.seeip.org)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s http://icanhazip.com)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s https://api.myip.com | cut -d\" -f4)
}

error() {

	echo -e "\n$red 输入错误！$none\n"

}

pause() {

	read -rsp "$(echo -e "按$green Enter 回车键 $none继续....或按$red Ctrl + C $none取消.")" -d $'\n'
	echo
}
do_service() {
	if [[ $systemd ]]; then
		systemctl $1 $2
	else
		service $2 $1
	fi
}
show_config_info() {
	clear
	_load v2ray-info.sh
	_v2_args
	_v2_info
	_load ss-info.sh
}

_install() {
	if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo " 大佬...你已经安装 V2Ray 啦...无需重新安装"
		echo
		echo -e " $yellow输入 ${cyan}v2ray${none} $yellow即可管理 V2Ray${none}"
		echo
		exit 1
	elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo "  如果你需要继续安装.. 请先卸载旧版本"
		echo
		echo -e " $yellow输入 ${cyan}v2ray uninstall${none} $yellow即可卸载${none}"
		echo
		exit 1
	fi
	v2ray_config
	blocked_hosts
	shadowsocks_config
	install_info
	# [[ $caddy ]] && domain_check
	install_v2ray
	if [[ $caddy || $new_v2ray_port == "80" ]]; then
		if [[ $cmd == "yum" ]]; then
			[[ $(pgrep "httpd") ]] && systemctl stop httpd
			[[ $(command -v httpd) ]] && yum remove httpd -y
		else
			[[ $(pgrep "apache2") ]] && service apache2 stop
			[[ $(command -v apache2) ]] && apt-get remove apache2* -y
		fi
	fi
	[[ $caddy ]] && install_caddy

	## bbr
	_load bbr.sh
	_try_enable_bbr

	get_ip
	config
	show_config_info
}

_uninstall() {

	if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
		. $backup
		if [[ $mark ]]; then
			_load uninstall.sh
		else
			echo
			echo -e " $yellow输入 ${cyan}v2ray uninstall${none} $yellow即可卸载${none}"
			echo
		fi

	elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo -e " $yellow输入 ${cyan}v2ray uninstall${none} $yellow即可卸载${none}"
		echo
	else
		echo -e "
		$red 大胸弟...你貌似毛有安装 V2Ray ....卸载个鸡鸡哦...$none

		备注...仅支持卸载使用我 ($author) 提供的 V2Ray 一键安装脚本
		" && exit 1
	fi

}

_disableselinux() {
	# Configure SELinux
	type selinuxenabled >/dev/null 2>&1 || return 0
	[[ ! -f /etc/selinux/config ]] && return 0
	if selinuxenabled; then
		setenforce Permissive
		# disable selinux needs reboot, set to Permissive
		sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	fi
}

args=$1
_gitbranch=$2
[ -z $1 ] && args="online"
case $args in
online)
	#hello world
	[[ -z $_gitbranch ]] && _gitbranch="master"
	;;
local)
	local_install=true
	;;
*)
	echo
	echo -e " 你输入的这个参数 <$red $args $none> ...这个是什么鬼啊...脚本不认识它哇"
	echo
	echo -e " 这个辣鸡脚本仅支持输入$green local / online $none参数"
	echo
	echo -e " 输入$yellow local $none即是使用本地安装"
	echo
	echo -e " 输入$yellow online $none即是使用在线安装 (默认)"
	echo
	exit 1
	;;
esac

clear
while :; do
	echo
	echo "........... V2Ray 一键安装脚本 & 管理脚本 by $author .........."
	echo
	echo "帮助说明: https://$_site/post/1/"
	echo
	echo "搭建教程: https://$_site/post/2/"
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	if [[ $local_install ]]; then
		echo -e "$yellow 温馨提示.. 本地安装已启用 ..$none"
		echo
	elif [[ $_gitbranch != "master" ]]; then
		echo -e "$yellow 温馨提示.. 脚本将使用 ${green}$_gitbranch $yellow分支进行安装..$none"
		echo
	fi
	read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" choose
	case $choose in
	1)
		_install
		break
		;;
	2)
		_uninstall
		break
		;;
	*)
		error
		;;
	esac
done
