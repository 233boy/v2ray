###----
echo
echo -e "$red V2RAY Telegram MTProto 相关配置暂时不推荐使用 $none"
echo
echo -e "$green 推荐使用 https://github.com/cutelua/mtg-dist $none"
echo
exit
###----

_view_mtproto_info() {
	if [[ $mtproto ]]; then
		_mtproto_info
	else
		_mtproto_ask
	fi
}
_mtproto_info() {
	[[ -z $ip ]] && get_ip
	echo
	echo "---------- Telegram MTProto 配置信息 -------------"
	echo
	echo -e "$yellow 主机 (Hostname) = $cyan${ip}$none"
	echo
	echo -e "$yellow 端口 (Port) = $cyan$mtproto_port$none"
	echo
	echo -e "$yellow 密钥 (Secret) = $cyan$mtproto_secret$none"
	echo
	echo -e "$yellow Telegram 代理配置链接 = ${cyan}https://t.me/proxy?server=${ip}&port=${mtproto_port}&secret=${mtproto_secret}$none"
	echo
}
_mtproto_main() {
	if [[ $mtproto ]]; then

		while :; do
			echo
			echo -e "$yellow 1. $none查看 Telegram MTProto 配置信息"
			echo
			echo -e "$yellow 2. $none修改 Telegram MTProto 端口"
			echo
			echo -e "$yellow 3. $none修改 Telegram MTProto 密钥"
			echo
			echo -e "$yellow 4. $none关闭 Telegram MTProto"
			echo
			read -p "$(echo -e "请选择 [${magenta}1-4$none]:")" _opt
			if [[ -z $_opt ]]; then
				error
			else
				case $_opt in
				1)
					_mtproto_info
					break
					;;
				2)
					change_mtproto_port
					break
					;;
				3)
					change_mtproto_secret
					break
					;;
				4)
					disable_mtproto
					break
					;;
				*)
					error
					;;
				esac
			fi

		done
	else
		_mtproto_ask
	fi
}
_mtproto_ask() {
	echo
	echo
	echo -e " $red大佬...你没有配置 Telegram MTProto $none...不过现在想要配置的话也是可以的 ^_^"
	echo
	echo
	new_mtproto_secret="dd$(date | md5sum | cut -c-30)"
	while :; do
		echo -e "是否配置 ${yellow}Telegram MTProto${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(默认 [${cyan}N$none]):") " new_mtproto
		[[ -z "$new_mtproto" ]] && new_mtproto="n"
		if [[ "$new_mtproto" == [Yy] ]]; then
			echo
			mtproto=true
			mtproto_port_config
			pause
			open_port $new_mtproto_port
			backup_config +mtproto
			mtproto_port=$new_mtproto_port
			mtproto_secret=$new_mtproto_secret
			config
			clear
			_mtproto_info
			break
		elif [[ "$new_mtproto" == [Nn] ]]; then
			echo
			echo -e " $green已取消配置 Telegram MTProto ....$none"
			echo
			break
		else
			error
		fi

	done
}
disable_mtproto() {
	echo

	while :; do
		echo -e "是否关闭 ${yellow}Telegram MTProto${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(默认 [${cyan}N$none]):") " y_n
		[[ -z "$y_n" ]] && y_n="n"
		if [[ "$y_n" == [Yy] ]]; then
			echo
			echo
			echo -e "$yellow 关闭 Telegram MTProto = $cyan是$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config -mtproto
			del_port $mtproto_port
			mtproto=''
			config
			echo
			echo
			echo
			echo -e "$green Telegram MTProto 已关闭...不过你也可以随时重新启用 Telegram MTProto ...只要你喜欢$none"
			echo
			break
		elif [[ "$y_n" == [Nn] ]]; then
			echo
			echo -e " $green已取消关闭 Telegram MTProto ....$none"
			echo
			break
		else
			error
		fi

	done
}
mtproto_port_config() {
	local random=$(shuf -i20001-65535 -n1)
	echo
	while :; do
		echo -e "请输入 "$yellow"Telegram MTProto"$none" 端口 ["$magenta"1-65535"$none"]，不能和 "$yellow"V2Ray"$none" 端口相同"
		read -p "$(echo -e "(默认端口: ${cyan}${random}$none):") " new_mtproto_port
		[ -z "$new_mtproto_port" ] && new_mtproto_port=$random
		case $new_mtproto_port in
		$v2ray_port)
			echo
			echo " 不能和 V2Ray 端口一毛一样...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_mtproto_port == "80" ]] || [[ $tls && $new_mtproto_port == "443" ]]; then
				echo
				echo -e "由于你已选择了 "$green"WebSocket + TLS $none或$green HTTP/2"$none" 传输协议."
				echo
				echo -e "所以不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_mtproto_port || $v2ray_dynamicPort_end == $new_mtproto_port ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_mtproto_port && $new_mtproto_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_mtproto_port == $ssport ]]; then
				echo
				echo -e "抱歉, 此端口跟 Shadowsocks 端口冲突...当前 Shadowsocks 端口: ${cyan}$ssport$none"
				error
			elif [[ $socks && $new_mtproto_port == $socks_port ]]; then
				echo
				echo -e "抱歉, 此端口跟 Socks 端口冲突...当前 Socks 端口: ${cyan}$socks_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow Telegram MTProto 端口 = $cyan$new_mtproto_port$none"
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
change_mtproto_secret() {
	new_mtproto_secret="dd$(date | md5sum | cut -c-30)"
	echo
	while :; do
		read -p "$(echo -e "是否更改 ${yellow}Telegram MTProto 密钥${none} [${magenta}Y/N$none]"): " y_n
		[ -z "$y_n" ] && error && continue
		case $y_n in
		n | N)
			echo
			echo -e " 已取消更改.... "
			echo
			break
			;;
		y | Y)
			echo
			echo
			echo -e "$yellow 更改 Telegram MTProto 密钥 = $cyan是$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config mtproto_secret
			mtproto_secret=$new_mtproto_secret
			config
			clear
			_mtproto_info
			break
			;;
		esac
	done
}
change_mtproto_port() {
	echo
	while :; do
		echo -e "请输入新的 "$yellow"Telegram MTProto"$none" 端口 ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(当前端口: ${cyan}${mtproto_port}$none):") " new_mtproto_port
		[ -z "$new_mtproto_port" ] && error && continue
		case $new_mtproto_port in
		$mtproto_port)
			echo
			echo " 不能跟当前端口一毛一样...."
			error
			;;
		$v2ray_port)
			echo
			echo " 不能和 V2Ray 端口一毛一样...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_mtproto_port == "80" ]] || [[ $tls && $new_mtproto_port == "443" ]]; then
				echo
				echo -e "由于你已选择了 "$green"WebSocket + TLS $none或$green HTTP/2"$none" 传输协议."
				echo
				echo -e "所以不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_mtproto_port || $v2ray_dynamicPort_end == $new_mtproto_port ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_mtproto_port && $new_mtproto_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_mtproto_port == $ssport ]]; then
				echo
				echo -e "抱歉, 此端口跟 Shadowsocks 端口冲突...当前 Shadowsocks 端口: ${cyan}$ssport$none"
				error
			elif [[ $socks && $new_mtproto_port == $socks_port ]]; then
				echo
				echo -e "抱歉, 此端口跟 Socks 端口冲突...当前 Socks 端口: ${cyan}$socks_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow socks 端口 = $cyan$new_mtproto_port$none"
				echo "----------------------------------------------------------------"
				echo
				pause
				backup_config mtproto_port
				mtproto_port=$new_mtproto_port
				config
				clear
				_mtproto_info
				break
			fi
			;;
		*)
			error
			;;
		esac

	done

}
