_view_socks_info() {
	if [[ $socks ]]; then
		_socks_info
	else
		_socks_ask
	fi
}
_socks_info() {
	[[ -z $ip ]] && get_ip
	echo
	echo "---------- Socks 配置信息 -------------"
	echo
	echo -e "$yellow 主机 (Hostname) = $cyan${ip}$none"
	echo
	echo -e "$yellow 端口 (Port) = $cyan$socks_port$none"
	echo
	echo -e "$yellow 用户名 (Username) = $cyan$socks_username$none"
	echo
	echo -e "$yellow 密码 (Password) = $cyan$socks_userpass$none"
	echo
	echo -e "$yellow Telegram 代理配置链接 = ${cyan}tg://socks?server=${ip}&port=${socks_port}&user=${socks_username}&pass=${socks_userpass}$none"
	echo
}
_socks_main() {
	if [[ $socks ]]; then

		while :; do
			echo
			echo -e "$yellow 1. $none查看 Socks 配置信息"
			echo
			echo -e "$yellow 2. $none修改 Socks 端口"
			echo
			echo -e "$yellow 3. $none修改 Socks 用户名"
			echo
			echo -e "$yellow 4. $none修改 Socks 密码"
			echo
			echo -e "$yellow 5. $none关闭 Socks"
			echo
			read -p "$(echo -e "请选择 [${magenta}1-4$none]:")" _opt
			if [[ -z $_opt ]]; then
				error
			else
				case $_opt in
				1)
					_socks_info
					break
					;;
				2)
					change_socks_port_config
					break
					;;
				3)
					change_socks_user_config
					break
					;;
				4)
					change_socks_pass_config
					break
					;;
				5)
					disable_socks
					break
					;;
				*)
					error
					;;
				esac
			fi

		done
	else
		_socks_ask
	fi
}
_socks_ask() {
	echo
	echo
	echo -e " $red大佬...你没有配置 Socks $none...不过现在想要配置的话也是可以的 ^_^"
	echo
	echo

	while :; do
		echo -e "是否配置 ${yellow}Socks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(默认 [${cyan}N$none]):") " new_socks
		[[ -z "$new_socks" ]] && new_socks="n"
		if [[ "$new_socks" == [Yy] ]]; then
			echo
			socks=true
			socks_port_config
			socks_user_config
			socks_pass_config
			pause
			open_port $new_socks_port
			backup_config +socks
			socks_port=$new_socks_port
			socks_username=$new_socks_username
			socks_userpass=$new_socks_userpass
			config
			clear
			_socks_info
			break
		elif [[ "$new_socks" == [Nn] ]]; then
			echo
			echo -e " $green已取消配置 Socks ....$none"
			echo
			break
		else
			error
		fi

	done
}
disable_socks() {
	echo

	while :; do
		echo -e "是否关闭 ${yellow}Socks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(默认 [${cyan}N$none]):") " y_n
		[[ -z "$y_n" ]] && y_n="n"
		if [[ "$y_n" == [Yy] ]]; then
			echo
			echo
			echo -e "$yellow 关闭 Socks = $cyan是$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config -socks
			del_port $socks_port
			socks=''
			config
			echo
			echo
			echo
			echo -e "$green Socks 已关闭...不过你也可以随时重新启用 Socks ...只要你喜欢$none"
			echo
			break
		elif [[ "$y_n" == [Nn] ]]; then
			echo
			echo -e " $green已取消关闭 Socks ....$none"
			echo
			break
		else
			error
		fi

	done
}
socks_port_config() {
	local random=$(shuf -i20001-65535 -n1)
	echo
	while :; do
		echo -e "请输入 "$yellow"Socks"$none" 端口 ["$magenta"1-65535"$none"]，不能和 "$yellow"V2Ray"$none" 端口相同"
		read -p "$(echo -e "(默认端口: ${cyan}${random}$none):") " new_socks_port
		[ -z "$new_socks_port" ] && new_socks_port=$random
		case $new_socks_port in
		$v2ray_port)
			echo
			echo " 不能和 V2Ray 端口一毛一样...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_socks_port == "80" ]] || [[ $tls && $new_socks_port == "443" ]]; then
				echo
				echo -e "由于你已选择了 "$green"WebSocket + TLS $none或$green HTTP/2"$none" 传输协议."
				echo
				echo -e "所以不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_socks_port || $v2ray_dynamicPort_end == $new_socks_port ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_socks_port && $new_socks_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_socks_port == $ssport ]]; then
				echo
				echo -e "抱歉, 此端口跟 Shadowsocks 端口冲突...当前 Shadowsocks 端口: ${cyan}$ssport$none"
				error
			elif [[ $mtproto && $new_socks_port == $mtproto_port ]]; then
				echo
				echo -e "抱歉, 此端口跟 MTProto 端口冲突...当前 MTProto 端口: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow Socks 端口 = $cyan$new_socks_port$none"
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
socks_user_config() {
	echo
	while :; do
		read -p "$(echo -e "请输入$yellow用户名$none...(默认用户名: ${cyan}233blog$none)"): " new_socks_username
		[ -z "$new_socks_username" ] && new_socks_username="233blog"
		case $new_socks_username in
		*[/$]* | *\&*)
			echo
			echo -e " 由于这个脚本太辣鸡了..所以用户名不能包含$red / $none或$red $ $none或$red & $none这三个符号.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow 用户名 = $cyan$new_socks_username$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done

}
socks_pass_config() {
	echo
	while :; do
		read -p "$(echo -e "请输入$yellow密码$none...(默认密码: ${cyan}233blog.com$none)"): " new_socks_userpass
		[ -z "$new_socks_userpass" ] && new_socks_userpass="233blog.com"
		case $new_socks_userpass in
		*[/$]* | *\&*)
			echo
			echo -e " 由于这个脚本太辣鸡了..所以密码不能包含$red / $none或$red $ $none或$red & $none这三个符号.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow 密码 = $cyan$new_socks_userpass$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done
}
change_socks_user_config() {
	echo
	while :; do
		read -p "$(echo -e "请输入$yellow用户名$none...(当前用户名: ${cyan}$socks_username$none)"): " new_socks_username
		[ -z "$new_socks_username" ] && error && continue
		case $new_socks_username in
		$socks_username)
			echo
			echo -e " 大佬...跟 当前用户名 一毛一样啊...修改个鸡鸡哦 "
			echo
			error
			;;
		*[/$]* | *\&*)
			echo
			echo -e " 由于这个脚本太辣鸡了..所以用户名不能包含$red / $none或$red $ $none或$red & $none这三个符号.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow 用户名 = $cyan$new_socks_username$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config socks_username
			socks_username=$new_socks_username
			config
			clear
			_socks_info
			break
			;;
		esac
	done
}
change_socks_pass_config() {
	echo
	while :; do
		read -p "$(echo -e "请输入$yellow密码$none...(当前密码: ${cyan}$socks_userpass$none)"): " new_socks_userpass
		[ -z "$new_socks_userpass" ] && error && continue
		case $new_socks_userpass in
		$socks_userpass)
			echo
			echo -e " 大佬...跟 当前密码 一毛一样啊...修改个鸡鸡哦 "
			echo
			error
			;;
		*[/$]* | *\&*)
			echo
			echo -e " 由于这个脚本太辣鸡了..所以密码不能包含$red / $none或$red $ $none或$red & $none这三个符号.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow 密码 = $cyan$new_socks_userpass$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config socks_userpass
			socks_userpass=$new_socks_userpass
			config
			clear
			_socks_info
			break
			;;
		esac
	done
}
change_socks_port_config() {
	echo
	while :; do
		echo -e "请输入新的 "$yellow"Socks"$none" 端口 ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(当前端口: ${cyan}${socks_port}$none):") " new_socks_port
		[ -z "$new_socks_port" ] && error && continue
		case $new_socks_port in
		$socks_port)
			echo
			echo " 不能和当前端口一毛一样...."
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
			if [[ $tls && $new_socks_port == "80" ]] || [[ $tls && $new_socks_port == "443" ]]; then
				echo
				echo -e "由于你已选择了 "$green"WebSocket + TLS $none或$green HTTP/2"$none" 传输协议."
				echo
				echo -e "所以不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_socks_port || $v2ray_dynamicPort_end == $new_socks_port ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_socks_port && $new_socks_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " 抱歉，此端口和 V2Ray 动态端口 冲突，当前 V2Ray 动态端口范围为：${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_socks_port == $ssport ]]; then
				echo
				echo -e "抱歉, 此端口跟 Shadowsocks 端口冲突...当前 Shadowsocks 端口: ${cyan}$ssport$none"
				error
			elif [[ $mtproto && $new_socks_port == $mtproto_port ]]; then
				echo
				echo -e "抱歉, 此端口跟 MTProto 端口冲突...当前 MTProto 端口: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow socks 端口 = $cyan$new_socks_port$none"
				echo "----------------------------------------------------------------"
				echo
				pause
				backup_config socks_port
				socks_port=$new_socks_port
				config
				clear
				_socks_info
				break
			fi
			;;
		*)
			error
			;;
		esac

	done

}
