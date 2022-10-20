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
	echo "---------- Informações de configuração de meias -------------"
	echo
	echo -e "$yellow hospedeiro (Hostname) = $cyan${ip}$none"
	echo
	echo -e "$yellow porta (Port) = $cyan$socks_port$none"
	echo
	echo -e "$yellow nome de usuário (Username) = $cyan$socks_username$none"
	echo
	echo -e "$yellow senha (Password) = $cyan$socks_userpass$none"
	echo
	echo -e "$yellow Link de configuração do proxy do Telegram = ${cyan}tg://socks?server=${ip}&port=${socks_port}&user=${socks_username}&pass=${socks_userpass}$none"
	echo
}
_socks_main() {
	if [[ $socks ]]; then

		while :; do
			echo
			echo -e "$yellow 1. $none Ver informações de configuração do Socks"
			echo
			echo -e "$yellow 2. $none Modificar porta Meias"
			echo
			echo -e "$yellow 3. $none Modificar nome de usuário de meias"
			echo
			echo -e "$yellow 4. $none Modifique a senha do Meias"
			echo
			echo -e "$yellow 5. $none Fechar meias"
			echo
			read -p "$(echo -e "por favor escolha [${magenta}1-4$none]:")" _opt
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
	echo -e " $red Cara grande... você não configurou o Socks $none...mas você pode configurá-lo agora se quiser ^_^"
	echo
	echo

	while :; do
		echo -e "Quer configurar ${yellow}Socks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):") " new_socks
		[[ -z "$new_socks" ]] && new_socks="n"
		if [[ "$new_socks" == [Yy] ]]; then
			echo
			socks=true
			socks_port_config
			socks_user_config
			socks_pass_config
			pause
			# open_port $new_socks_port
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
			echo -e " $green Meias desconfiguradas ....$none"
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
		echo -e "se fechar ${yellow}Socks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):") " y_n
		[[ -z "$y_n" ]] && y_n="n"
		if [[ "$y_n" == [Yy] ]]; then
			echo
			echo
			echo -e "$yellow Fechar meias = $cyan sim$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config -socks
			# del_port $socks_port
			socks=''
			config
			echo
			echo
			echo
			echo -e "$green As meias estão desativadas... mas você sempre pode reativar as meias... se quiser$none"
			echo
			break
		elif [[ "$y_n" == [Nn] ]]; then
			echo
			echo -e " $green Fechar Meias cancelada....$none"
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
		echo -e "Por favor, insira a porta "$yellow"Meias"$none" ["$magenta"1-65535"$none"], não pode ser a mesma que a porta "$yellow"V2Ray"$none""
		read -p "$(echo -e "(porta padrão: ${cyan}${random}$none):") " new_socks_port
		[ -z "$new_socks_port" ] && new_socks_port=$random
		case $new_socks_port in
		$v2ray_port)
			echo
			echo "Não pode ser tão ruim quanto a porta V2Ray...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_socks_port == "80" ]] || [[ $tls && $new_socks_port == "443" ]]; then
				echo
				echo -e "Porque você selecionou o transporte "$green"WebSocket + TLS $none ou $green HTTP/2"$none"."
				echo
				echo -e "Assim, as portas "$magenta"80"$none" ou "$magenta"443"$none" não podem ser selecionadas"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_socks_port || $v2ray_dynamicPort_end == $new_socks_port ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_socks_port && $new_socks_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_socks_port == $ssport ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Shadowsocks...Porta atual do Shadowsocks: ${cyan}$ssport$none"
				error
			elif [[ $mtproto && $new_socks_port == $mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta MTProto...porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow Porta meias = $cyan$new_socks_port$none"
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
		read -p "$(echo -e "Por favor, digite $yellow username $none...(username default: ${cyan}233blog$none)"): " new_socks_username
		[ -z "$new_socks_username" ] && new_socks_username="233blog"
		case $new_socks_username in
		*[/$]* | *\&*)
			echo
			echo -e " Porque este script é muito picante .. então o nome de usuário não pode conter os três símbolos $red / $none ou $red $ $none ou $red & $none .... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow nome de usuário = $cyan$new_socks_username$none"
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
		read -p "$(echo -e "Por favor, digite a senha $yellow $none...(senha padrão: ${cyan}233blog.com$none)")): " new_socks_userpass
		[ -z "$new_socks_userpass" ] && new_socks_userpass="233blog.com"
		case $new_socks_userpass in
		*[/$]* | *\&*)
			echo
			echo -e " Porque este script é muito picante .. então a senha não pode conter os três símbolos $red / $none ou $red $ $none ou $red & $none .... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow senha = $cyan$new_socks_userpass$none"
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
		read -p "$(echo -e "Por favor, digite $yellow username $none...(Nome de usuário atual: ${cyan}$socks_username$none)"): " new_socks_username
		[ -z "$new_socks_username" ] && error && continue
		case $new_socks_username in
		$socks_username)
			echo
			echo -e " Cara grande... é o mesmo que o nome de usuário atual... modifique um pau."
			echo
			error
			;;
		*[/$]* | *\&*)
			echo
			echo -e " Porque este script é muito picante .. então o nome de usuário não pode conter os três símbolos $red / $none ou $red $ $none ou $red & $none ...."
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow nome de usuário = $cyan$new_socks_username$none"
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
		read -p "$(echo -e "Por favor, digite a senha $yellow $none...(senha atual: ${cyan}$socks_userpass$none)"): " new_socks_userpass
		[ -z "$new_socks_userpass" ] && error && continue
		case $new_socks_userpass in
		$socks_userpass)
			echo
			echo -e " Cara grande... é a mesma senha atual... modifique algo"
			echo
			error
			;;
		*[/$]* | *\&*)
			echo
			echo -e " Porque este script é muito picante .. então a senha não pode conter os três símbolos $red / $none ou $red $ $none ou $red & $none ...."
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
		echo -e "Por favor, insira a nova porta "$yellow"Meias"$none" ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(porta atual: ${cyan}${socks_port}$none):") " new_socks_port
		[ -z "$new_socks_port" ] && error && continue
		case $new_socks_port in
		$socks_port)
			echo
			echo " Não pode ser o mesmo que a porta atual...."
			error
			;;
		$v2ray_port)
			echo
			echo " Não pode ser o mesmo que a porta V2Ray...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_socks_port == "80" ]] || [[ $tls && $new_socks_port == "443" ]]; then
				echo
				echo -e "Como você selecionou o transporte "$green"WebSocket + TLS $none ou $green HTTP/2"$none"."
				echo
				echo -e "Portanto, as portas "$magenta"80"$none" ou "$magenta"443"$none" não podem ser selecionadas"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_socks_port || $v2ray_dynamicPort_end == $new_socks_port ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_socks_port && $new_socks_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_socks_port == $ssport ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Shadowsocks...porta atual do Shadowsocks: ${cyan}$ssport$none"
				error
			elif [[ $mtproto && $new_socks_port == $mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta MTProto...porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow porta meias = $cyan$new_socks_port$none"
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
