###----
echo
echo -e "$red A configuração relacionada ao V2RAY Telegram MTProto não é recomendada temporariamente $none"
echo
echo -e "$green Uso recomendado https://github.com/cutelua/mtg-dist $none"
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
	echo "---------- Informações de configuração do Telegram MTProto -------------"
	echo
	echo -e "$yellow hospedeiro (Hostname) = $cyan${ip}$none"
	echo
	echo -e "$yellow porta (Port) = $cyan$mtproto_port$none"
	echo
	echo -e "$yellow chave (Secret) = $cyan$mtproto_secret$none"
	echo
	echo -e "$yellow Link de configuração do proxy do Telegram = ${cyan}https://t.me/proxy?server=${ip}&port=${mtproto_port}&secret=${mtproto_secret}$none"
	echo
}
_mtproto_main() {
	if [[ $mtproto ]]; then

		while :; do
			echo
			echo -e "$yellow 1. $none Ver informações de configuração do Telegram MTProto"
			echo
			echo -e "$yellow 2. $none Modificar a porta MTProto do Telegram"
			echo
			echo -e "$yellow 3. $none Modificar a chave MTProto do Telegram"
			echo
			echo -e "$yellow 4. $none Fechar Telegram MTProto"
			echo
			read -p "$(echo -e "por favor escolha [${magenta}1-4$none]:")" _opt
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
	echo -e " $red Chefe...você não configurou o Telegram MTProto $none...mas você pode configurá-lo agora se quiser ^_^"
	echo
	echo
	new_mtproto_secret="dd$(date | md5sum | cut -c-30)"
	while :; do
		echo -e "Quer configurar ${yellow}Telegram MTProto${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):") " new_mtproto
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
			echo -e " $green Telegram MTProto foi desconfigurado....$none"
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
		echo -e "se fechar ${yellow}Telegram MTProto${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):") " y_n
		[[ -z "$y_n" ]] && y_n="n"
		if [[ "$y_n" == [Yy] ]]; then
			echo
			echo
			echo -e "$yellow Fechar Telegram MTProto = $cyan是$none"
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
			echo -e "$green O Telegram MTProto está desativado... mas você sempre pode reativar o Telegram MTProto... como quiser$none"
			echo
			break
		elif [[ "$y_n" == [Nn] ]]; then
			echo
			echo -e " $green Cancelado fechamento do Telegram MTProto ....$none"
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
		echo -e "Por favor, digite "$yellow"Telegram MTProto"$none" port ["$magenta"1-65535"$none"], não pode ser o mesmo que "$yellow"V2Ray"$none" port"
		read -p "$(echo -e "(porta padrão: ${cyan}${random}$none):") " new_mtproto_port
		[ -z "$new_mtproto_port" ] && new_mtproto_port=$random
		case $new_mtproto_port in
		$v2ray_port)
			echo
			echo " Nada como a porta V2Ray..."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_mtproto_port == "80" ]] || [[ $tls && $new_mtproto_port == "443" ]]; then
				echo
				echo -e "Porque você selecionou o transporte "$green"WebSocket + TLS $none ou $green HTTP/2"$none"."
				echo
				echo -e "Assim, as portas "$magenta"80"$none" ou "$magenta"443"$none" não podem ser selecionadas"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_mtproto_port || $v2ray_dynamicPort_end == $new_mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta dinâmica do V2Ray. O intervalo de portas dinâmicas do V2Ray atual é: ${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_mtproto_port && $new_mtproto_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_mtproto_port == $ssport ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Shadowsocks...porta atual do Shadowsocks: ${cyan}$ssport$none"
				error
			elif [[ $socks && $new_mtproto_port == $socks_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Socks...Porta atual do Socks: ${cyan}$socks_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow Porta do Telegram MTProto = $cyan$new_mtproto_port$none"
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
		read -p "$(echo -e "Se deve alterar a chave ${yellow}Telegram MTProto${none} [${magenta}Y/N$none]"): " y_n
		[ -z "$y_n" ] && error && continue
		case $y_n in
		n | N)
			echo
			echo -e " Alteração cancelada.... "
			echo
			break
			;;
		y | Y)
			echo
			echo
			echo -e "$yellow Alterar a chave MTProto do Telegram = $cyan sim$none"
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
		echo -e "Por favor, digite a nova porta "$yellow"Telegram MTProto"$none" ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(porta atual: ${cyan}${mtproto_port}$none):") " new_mtproto_port
		[ -z "$new_mtproto_port" ] && error && continue
		case $new_mtproto_port in
		$mtproto_port)
			echo
			echo " Não pode ser igual à porta atual..."
			error
			;;
		$v2ray_port)
			echo
			echo " Nada como a porta V2Ray..."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_mtproto_port == "80" ]] || [[ $tls && $new_mtproto_port == "443" ]]; then
				echo
				echo -e"Porque você selecionou o transporte "$green"WebSocket + TLS $none ou $green HTTP/2"$none"."
				echo
				echo -e "Assim, as portas "$magenta"80"$none" ou "$magenta"443"$none" não podem ser selecionadas"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_mtproto_port || $v2ray_dynamicPort_end == $new_mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta dinâmica do V2Ray, o intervalo de portas dinâmicas do V2Ray atual é: ${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_mtproto_port && $new_mtproto_port -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray. O intervalo de portas dinâmicas V2Ray atual é:${cyan}$port_range${none}"
				error
			elif [[ $shadowsocks && $new_mtproto_port == $ssport ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Shadowsocks...porta atual do Shadowsocks: ${cyan}$ssport$none"
				error
			elif [[ $socks && $new_mtproto_port == $socks_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Socks...Porta atual do Socks: ${cyan}$socks_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow porta meias = $cyan$new_mtproto_port$none"
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
