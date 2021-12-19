while :; do
	echo
	read -p "$(echo -e "是否卸载 ${yellow}V2Ray$none [${magenta}Y/N$none]:")" uninstall_v2ray_ask
	if [[ -z $uninstall_v2ray_ask ]]; then
		error
	else
		case $uninstall_v2ray_ask in
		Y | y)
			is_uninstall_v2ray=true
			echo
			echo -e "$yellow 卸载 V2Ray = ${cyan}是${none}"
			echo
			break
			;;
		N | n)
			echo
			echo -e "$red 卸载已取消...$none"
			echo
			break
			;;
		*)
			error
			;;
		esac
	fi
done

if [[ $caddy && $is_uninstall_v2ray ]] && [[ -f /usr/local/bin/caddy && -f /etc/caddy/Caddyfile ]]; then
	while :; do
		echo
		read -p "$(echo -e "是否卸载 ${yellow}Caddy$none [${magenta}Y/N$none]:")" uninstall_caddy_ask
		if [[ -z $uninstall_caddy_ask ]]; then
			error
		else
			case $uninstall_caddy_ask in
			Y | y)
				is_uninstall_caddy=true
				echo
				echo -e "$yellow 卸载 Caddy = ${cyan}是${none}"
				echo
				break
				;;
			N | n)
				echo
				echo -e "$yellow 卸载 Caddy = ${cyan}否${none}"
				echo
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
fi

if [[ $is_uninstall_v2ray && $is_uninstall_caddy ]]; then
	pause
	echo

	# if [[ $shadowsocks ]]; then
	# 	del_port $ssport
	# fi
	# if [[ $socks ]]; then
	# 	del_port $socks_port
	# fi
	# if [[ $mtproto ]]; then
	# 	del_port $mtproto_port
	# fi

	# if [[ $v2ray_transport == [45] ]]; then
	# 	del_port "80"
	# 	del_port "443"
	# 	del_port $v2ray_port
	# elif [[ $v2ray_transport -ge 18 ]]; then
	# 	del_port $v2ray_port
	# 	del_port "multiport"
	# else
	# 	del_port $v2ray_port
	# fi

	[[ -f /etc/network/if-pre-up.d/iptables ]] && rm -rf /etc/network/if-pre-up.d/iptables

	# [ $v2ray_pid ] && systemctl stop v2ray
	[ $v2ray_pid ] && do_service stop v2ray

	rm -rf /usr/bin/v2ray
	rm -rf $_v2ray_sh
	sed -i '/alias v2ray=/d' /root/.bashrc
	rm -rf /etc/v2ray
	rm -rf /var/log/v2ray

	# [ $caddy_pid ] && systemctl stop caddy
	[ $caddy_pid ] && do_service stop caddy

	rm -rf /usr/local/bin/caddy
	rm -rf /etc/caddy
	rm -rf /etc/ssl/caddy

	if [[ $systemd ]]; then
		systemctl disable v2ray >/dev/null 2>&1
		rm -rf /lib/systemd/system/v2ray.service
		systemctl disable caddy >/dev/null 2>&1
		rm -rf /lib/systemd/system/caddy.service
	else
		update-rc.d -f caddy remove >/dev/null 2>&1
		update-rc.d -f v2ray remove >/dev/null 2>&1
		rm -rf /etc/init.d/caddy
		rm -rf /etc/init.d/v2ray
	fi
	# clear
	echo
	echo -e "$green V2Ray 卸载完成啦 ....$none"
	echo
	echo "如果你觉得这个脚本有哪些地方不够好的话...请告诉我"
	echo
	echo "反馈问题: https://github.com/233boy/v2ray/issues"
	echo

elif [[ $is_uninstall_v2ray ]]; then
	pause
	echo

	# if [[ $shadowsocks ]]; then
	# 	del_port $ssport
	# fi
	# if [[ $socks ]]; then
	# 	del_port $socks_port
	# fi
	# if [[ $mtproto ]]; then
	# 	del_port $mtproto_port
	# fi

	# if [[ $v2ray_transport == [45] ]]; then
	# 	del_port "80"
	# 	del_port "443"
	# 	del_port $v2ray_port
	# elif [[ $v2ray_transport -ge 18 ]]; then
	# 	del_port $v2ray_port
	# 	del_port "multiport"
	# else
	# 	del_port $v2ray_port
	# fi

	[[ -f /etc/network/if-pre-up.d/iptables ]] && rm -rf /etc/network/if-pre-up.d/iptables

	# [ $v2ray_pid ] && systemctl stop v2ray
	[ $v2ray_pid ] && do_service stop v2ray

	rm -rf /usr/bin/v2ray
	rm -rf $_v2ray_sh
	sed -i '/alias v2ray=/d' /root/.bashrc
	rm -rf /etc/v2ray
	rm -rf /var/log/v2ray
	if [[ $systemd ]]; then
		systemctl disable v2ray >/dev/null 2>&1
		rm -rf /lib/systemd/system/v2ray.service
	else
		update-rc.d -f v2ray remove >/dev/null 2>&1
		rm -rf /etc/init.d/v2ray
	fi
	# clear
	echo
	echo -e "$green V2Ray 卸载完成啦 ....$none"
	echo
	echo "如果你觉得这个脚本有哪些地方不够好的话...请告诉我"
	echo
	echo "反馈问题: https://github.com/233boy/v2ray/issues"
	echo
fi
