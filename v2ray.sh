#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

# Root
[[ $(id -u) != 0 ]] && echo -e " Ops... execute como usuário ${red}root ${none} ${yellow}~(^_^) ${none}" && exit 1

_version="v3.65"

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
i[36]86)
	v2ray_bit="32"
	caddy_arch="386"
	;;
'amd64' | x86_64)
	v2ray_bit="64"
	caddy_arch="amd64"
	;;
*armv6*)
	v2ray_bit="arm32-v6"
	caddy_arch="arm6"
	;;
*armv7*)
	v2ray_bit="arm32-v7a"
	caddy_arch="arm7"
	;;
*aarch64* | *armv8*)
	v2ray_bit="arm64-v8a"
	caddy_arch="arm64"
	;;
*)
	echo -e " 
	Haha... este ${red}script${none} não suporta o seu sistema. ${yellow}(-_-) ${none}

	Nota: Suporta apenas sistemas Ubuntu 16+ / Debian 8+ / CentOS 7+
	" && exit 1
	;;
esac

if [[ $(command -v yum) ]]; then

	cmd="yum"

fi

backup="/etc/v2ray/233blog_v2ray_backup.conf"

if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then

	. $backup

elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then

	. /etc/v2ray/233boy/v2ray/tools/v1xx_to_v3xx.sh

else
	echo -e " Oops oops...${red} deu errado... por favor reinstale o V2Ray${none} ${yellow}~(^_^) ${none}" && exit 1
fi

if [[ $mark != "v3" ]]; then
	. /etc/v2ray/233boy/v2ray/tools/v3.sh
fi
if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
	dynamicPort=true
	port_range="${v2ray_dynamicPort_start}-${v2ray_dynamicPort_end}"
fi
if [[ $path_status ]]; then
	is_path=true
fi

uuid=$(cat /proc/sys/kernel/random/uuid)
old_id="e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
v2ray_server_config="/etc/v2ray/config.json"
v2ray_client_config="/etc/v2ray/233blog_v2ray_config.json"
v2ray_pid=$(pgrep -f /usr/bin/v2ray/v2ray)
caddy_pid=$(pgrep -f /usr/local/bin/caddy)
_v2ray_sh="/usr/local/sbin/v2ray"

/usr/bin/v2ray/v2ray -version >/dev/null 2>&1
if [[ $? == 0 ]]; then
	v2ray_ver="$(/usr/bin/v2ray/v2ray -version | head -n 1 | cut -d " " -f2)"
else
	v2ray_ver="$(/usr/bin/v2ray/v2ray version | head -n 1 | cut -d " " -f2)"
	v2ray_ver_v5=1
fi

. /etc/v2ray/233boy/v2ray/src/init.sh
systemd=true
# _test=true

# fix VMessAEAD
if [[ ! $(grep 'run -config' /lib/systemd/system/v2ray.service)  && $v2ray_ver_v5 ]]; then
	_load download-v2ray.sh
	_install_v2ray_service
	systemctl daemon-reload
	systemctl restart v2ray
fi

# fix caddy2 config
if [[ $caddy ]]; then
	/usr/local/bin/caddy version >/dev/null 2>&1
	if [[ $? == 1 ]]; then
		echo -e "\n $yellow Aviso: O script atualizará automaticamente a versão do Caddy.  $none  \n"
		systemctl stop caddy
		_load download-caddy.sh
		_download_caddy_file
		_install_caddy_service
		systemctl daemon-reload
		_load caddy-config.sh
		systemctl restart caddy
		echo -e "\n $green A atualização da versão do Caddy está completa, se houver algum problema, você pode reinstalá-lo para resolver. $none  \n"
		exit 0
	fi
fi

if [[ $v2ray_ver != v* ]]; then
	v2ray_ver="v$v2ray_ver"
fi
if [[ ! -f $_v2ray_sh ]]; then
	mv -f /usr/local/bin/v2ray $_v2ray_sh
	chmod +x $_v2ray_sh
	echo -e "\n $yellow Aviso: Faça login novamente no SSH para evitar que o comando v2ray não seja encontrado. $none  \n" && exit 1
fi

if [ $v2ray_pid ]; then
	v2ray_status="$green on$none"
else
	v2ray_status="$red off$none"
fi
if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy_pid && $caddy ]]; then
	caddy_run_status="$green on$none"
else
	caddy_run_status="$red off$none"
fi

_load transport.sh
ciphers=(
	aes-128-gcm
	aes-256-gcm
	chacha20-ietf-poly1305
)

get_transport_args() {
	_load v2ray-info.sh
	_v2_args
}
create_vmess_URL_config() {

	[[ -z $net ]] && get_transport_args

	if [[ $v2ray_transport == [45] ]]; then
		cat >/etc/v2ray/vmess_qr.json <<-EOF
			{
				"v": "2",
				"ps": "233v2.com_${domain}",
				"add": "${domain}",
				"port": "443",
				"id": "${v2ray_id}",
				"aid": "${alterId}",
				"net": "${net}",
				"type": "none",
				"host": "${domain}",
				"path": "$_path",
				"tls": "tls"
			}
		EOF
	elif [[ $v2ray_transport == 33 ]]; then
		cat >/etc/v2ray/vmess_qr.json <<-EOF
			vless://${v2ray_id}@${domain}:443?encryption=none&security=tls&type=ws&host=${domain}&path=${_path}#233v2_${domain}
		EOF
	else
		[[ -z $ip ]] && get_ip
		cat >/etc/v2ray/vmess_qr.json <<-EOF
			{
				"v": "2",
				"ps": "233v2.com_${ip}",
				"add": "${ip}",
				"port": "${v2ray_port}",
				"id": "${v2ray_id}",
				"aid": "${alterId}",
				"net": "${net}",
				"type": "${header}",
				"host": "${host}",
				"path": "",
				"tls": ""
			}
		EOF
	fi
}
view_v2ray_config_info() {

	_load v2ray-info.sh
	_v2_args
	_v2_info
}
get_shadowsocks_config() {
	if [[ $shadowsocks ]]; then

		while :; do
			echo
			echo -e "$yellow 1. $noneVer informações de configuração do Shadowsocks"
			echo
			echo -e "$yellow 2. $none Gerar link de código QR"
			echo
			read -p "$(echo -e "por favor escolha [${magenta}1-2$none]:")" _opt
			if [[ -z $_opt ]]; then
				error
			else
				case $_opt in
				1)
					view_shadowsocks_config_info
					break
					;;
				2)
					get_shadowsocks_config_qr_link
					break
					;;
				*)
					error
					;;
				esac
			fi

		done
	else
		shadowsocks_config
	fi
}
view_shadowsocks_config_info() {
	if [[ $shadowsocks ]]; then
		_load ss-info.sh
	else
		shadowsocks_config
	fi
}
get_shadowsocks_config_qr_link() {
	if [[ $shadowsocks ]]; then
		get_ip
		_load qr.sh
		_ss_qr
	else
		shadowsocks_config
	fi

}

get_shadowsocks_config_qr_ask() {
	echo
	while :; do
		echo -e "Você precisa gerar $yellow Shadowsocks informações de configuração $none QR code link [${magenta}Y/N$none]"
		read -p "$(echo -e "padrão [${magenta}N$none]:")" y_n
		[ -z $y_n ] && y_n="n"
		if [[ $y_n == [Yy] ]]; then
			get_shadowsocks_config_qr_link
			break
		elif [[ $y_n == [Nn] ]]; then
			break
		else
			error
		fi
	done

}
change_shadowsocks_config() {
	if [[ $shadowsocks ]]; then

		while :; do
			echo
			echo -e "$yellow 1. $none Modifique a porta Shadowsocks"
			echo
			echo -e "$yellow 2. $none Modifique a senha do Shadowsocks"
			echo
			echo -e "$yellow 3. $none Modifique o protocolo de criptografia Shadowsocks"
			echo
			echo -e "$yellow 4. $none Fechar Meias Sombrias"
			echo
			read -p "$(echo -e "por favor escolha [${magenta}1-4$none]:")" _opt
			if [[ -z $_opt ]]; then
				error
			else
				case $_opt in
				1)
					change_shadowsocks_port
					break
					;;
				2)
					change_shadowsocks_password
					break
					;;
				3)
					change_shadowsocks_ciphers
					break
					;;
				4)
					disable_shadowsocks
					break
					;;
				*)
					error
					;;
				esac
			fi

		done
	else

		shadowsocks_config
	fi
}
shadowsocks_config() {
	echo
	echo
	echo -e " $red Cara... você não configurou o Shadowsocks $none...mas você pode configurá-lo agora se quiser ^_^"
	echo
	echo

	while :; do
		echo -e "Quer configurar ${yellow}Shadowsocks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):") " install_shadowsocks
		[[ -z "$install_shadowsocks" ]] && install_shadowsocks="n"
		if [[ "$install_shadowsocks" == [Yy] ]]; then
			echo
			shadowsocks=true
			shadowsocks_port_config
			shadowsocks_password_config
			shadowsocks_ciphers_config
			pause
			backup_config +ss
			ssport=$new_ssport
			sspass=$new_sspass
			ssciphers=$new_ssciphers
			config
			clear
			view_shadowsocks_config_info
			# get_shadowsocks_config_qr_ask
			break
		elif [[ "$install_shadowsocks" == [Nn] ]]; then
			echo
			echo -e " $green Shadowsocks não configurados ....$none"
			echo
			break
		else
			error
		fi

	done
}
shadowsocks_port_config() {
	local random=$(shuf -i20001-65535 -n1)
	while :; do
		echo -e "Por favor, insira "$yellow"Shadowsocks"$none" port ["$magenta"1-65535"$none"], não pode ser o mesmo que "$yellow"V2ray"$none" port"
		read -p "$(echo -e "(porta padrão: ${cyan}${random}$none):") " new_ssport
		[ -z "$new_ssport" ] && new_ssport=$random
		case $new_ssport in
		$v2ray_port)
			echo
			echo -e " Não é o mesmo que $cyan V2Ray port $none...."
			echo
			echo -e " Porta V2Ray atual: ${cyan}$v2ray_port${none}"
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_ssport == "80" ]] || [[ $tls && $new_ssport == "443" ]]; then
				echo
				echo -e "Como você está usando o WebSocket "$green" + TLS $none ou $green HTTP/2 "$none" transporte."
				echo
				echo -e "Assim, as portas "$magenta"80"$none" ou "$magenta"443"$none" não podem ser selecionadas"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_ssport || $v2ray_dynamicPort_end == $new_ssport ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta dinâmica do V2Ray, o intervalo de portas dinâmicas do V2Ray atual é: ${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_ssport && $new_ssport -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray. O intervalo de portas dinâmicas V2Ray atual é: ${cyan}$port_range${none}"
				error
			elif [[ $socks && $new_ssport == $socks_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Socks...Porta atual do Socks: ${cyan}$socks_port$none"
				error
			elif [[ $mtproto && $new_ssport == $mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta MTProto...Porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow Porta Shadowsocks = $cyan$new_ssport$none"
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

shadowsocks_password_config() {

	while :; do
		echo -e "Por favor, digite "$yellow"Shadowsocks"$none"password"
		read -p "$(echo -e "(senha padrão: ${cyan}233blog.com$none)"): " new_sspass
		[ -z "$new_sspass" ] && new_sspass="233blog.com"
		case $new_sspass in
		*[/$]*)
			echo
			echo -e " Como este script é muito picante, a senha não pode conter os dois símbolos $red / $none ou $red $ $none. ..."
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow Senha do Shadowsocks = $cyan$new_sspass$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac

	done

}

shadowsocks_ciphers_config() {

	while :; do
		echo -e "Por favor, selecione o protocolo de criptografia "$yellow"Shadowsocks"$none" [${magenta}1-3$none]"
		for ((i = 1; i <= ${#ciphers[*]}; i++)); do
			ciphers_show="${ciphers[$i - 1]}"
			echo
			echo -e "$yellow $i. $none${ciphers_show}"
		done
		echo
		read -p "$(echo -e "(Protocolo de criptografia padrão: ${cyan}${ciphers[1]}$none)"):" ssciphers_opt
		[ -z "$ssciphers_opt" ] && ssciphers_opt=2
		case $ssciphers_opt in
		[1-3])
			new_ssciphers=${ciphers[$ssciphers_opt - 1]}
			echo
			echo
			echo -e "$yellow Protocolo de criptografia Shadowsocks = $cyan${new_ssciphers}$none"
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

change_shadowsocks_port() {
	echo
	while :; do
		echo -e "Por favor, digite "$yellow"Shadowsocks"$none" porta ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(porta atual: ${cyan}$ssport$none):") " new_ssport
		[ -z "$new_ssport" ] && error && continue
		case $new_ssport in
		$ssport)
			echo
			echo " É o mesmo que a porta atual .... modifique algo..."
			error
			;;
		$v2ray_port)
			echo
			echo -e "Não pode ser o mesmo que $cyan V2Ray port $none..."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]]; then
				local tls=ture
			fi
			if [[ $tls && $new_ssport == "80" ]] || [[ $tls && $new_ssport == "443" ]]; then
				echo
				echo -e "Porque você selecionou o transporte "$green"WebSocket + TLS $none ou $green HTTP/2"$none"."
				echo
				echo -e "Assim, as portas "$magenta"80"$none" ou "$magenta"443"$none" não podem ser selecionadas"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $new_ssport || $v2ray_dynamicPort_end == $new_ssport ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
				error
			elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $new_ssport && $new_ssport -le $v2ray_dynamicPort_end ]]; then
				echo
				echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
				error
			elif [[ $socks && $new_ssport == $socks_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Socks...porta atual do Socks: ${cyan}$socks_port$none"
				error
			elif [[ $mtproto && $new_ssport == $mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta MTProto...porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow Porta Shadowsocks = $cyan$new_ssport$none"
				echo "----------------------------------------------------------------"
				echo
				pause
				backup_config ssport
				ssport=$new_ssport
				config
				clear
				view_shadowsocks_config_info
				# get_shadowsocks_config_qr_ask
				break
			fi
			;;
		*)
			error
			;;
		esac

	done
}
change_shadowsocks_password() {
	echo
	while :; do
		echo -e "Por favor, insira "$yellow"Shadowsocks"$none" senha"
		read -p "$(echo -e "(Senha atual: ${cyan}$sspass$none)"): " new_sspass
		[ -z "$new_sspass" ] && error && continue
		case $new_sspass in
		$sspass)
			echo
			echo "É a mesma senha atual... modifique algo.."
			error
			;;
		*[/$]*)
			echo
			echo -e " Como este script é muito picante, a senha não pode conter os dois símbolos $red / $none ou $red $ $none...."
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow Senha do Shadowsocks = $cyan$new_sspass$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config sspass
			sspass=$new_sspass
			config
			clear
			view_shadowsocks_config_info
			# get_shadowsocks_config_qr_ask
			break
			;;
		esac

	done

}

change_shadowsocks_ciphers() {
	echo
	while :; do
		echo -e "Por favor, selecione o protocolo de criptografia "$yellow"Shadowsocks"$none" [${magenta}1-${#ciphers[*]}$none]"
		for ((i = 1; i <= ${#ciphers[*]}; i++)); do
			ciphers_show="${ciphers[$i - 1]}"
			echo
			echo -e "$yellow $i. $none${ciphers_show}"
		done
		echo
		read -p "$(echo -e "(Protocolos de criptografia atuais: ${cyan}${ssciphers}$none)"):" ssciphers_opt
		[ -z "$ssciphers_opt" ] && error && continue
		case $ssciphers_opt in
		[1-3])
			new_ssciphers=${ciphers[$ssciphers_opt - 1]}
			if [[ $new_ssciphers == $ssciphers ]]; then
				echo
				echo " É o mesmo que o protocolo de criptografia atual... modifique algo..."
				error && continue
			fi
			echo
			echo
			echo -e "$yellow Protocolo de criptografia Shadowsocks = $cyan${new_ssciphers}$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config ssciphers
			ssciphers=$new_ssciphers
			config
			clear
			view_shadowsocks_config_info
			# get_shadowsocks_config_qr_ask
			break
			;;
		*)
			error
			;;
		esac

	done

}
disable_shadowsocks() {
	echo

	while :; do
		echo -e "desativar ${yellow}Shadowsocks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):") " y_n
		[[ -z "$y_n" ]] && y_n="n"
		if [[ "$y_n" == [Yy] ]]; then
			echo
			echo
			echo -e "$yellow desativar Shadowsocks = $cyan sim$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config -ss
			shadowsocks=''
			config
			# clear
			echo
			echo
			echo
			echo -e "$green Shadowsocks 已关闭...不过你也可以随时重新启用 Shadowsocks ...只要你喜欢$none"
			echo
			break
		elif [[ "$y_n" == [Nn] ]]; then
			echo
			echo -e " $green Shadowsocks foi cancelado....$none"
			echo
			break
		else
			error
		fi

	done
}
change_v2ray_config() {
	local _menu=(
		"Modificar porta V2Ray"
		"Modificar protocolo de transporte V2Ray"
		"Modifique as portas dinâmicas do V2Ray (se possível)"
		"Modificar ID de usuário (UUID)"
		"Modifique o nome de domínio TLS (se aplicável)"
		"Modifique o caminho de derivação (se possível)"
		"Modificar URL falsificado (se possível)"
		"Desative o mascaramento e roteamento do site (se possível)"
		"Ativar/desativar o bloqueio de anúncios"
	)
	while :; do
		for ((i = 1; i <= ${#_menu[*]}; i++)); do
			if [[ "$i" -le 9 ]]; then
				echo
				echo -e "$yellow  $i. $none${_menu[$i - 1]}"
			else
				echo
				echo -e "$yellow $i. $none${_menu[$i - 1]}"
			fi
		done
		echo
		read -p "$(echo -e "por favor escolha [${magenta}1-${#_menu[*]}$none]:")" _opt
		if [[ -z $_opt ]]; then
			error
		else
			case $_opt in
			1)
				change_v2ray_port
				break
				;;
			2)
				change_v2ray_transport
				break
				;;
			3)
				change_v2ray_dynamicport
				break
				;;
			4)
				change_v2ray_id
				break
				;;
			5)
				change_domain
				break
				;;
			6)
				change_path_config
				break
				;;
			7)
				change_proxy_site_config
				break
				;;
			8)
				disable_path
				break
				;;
			9)
				blocked_hosts
				break
				;;
			[aA][Ii][aA][Ii] | [Dd][Dd])
				custom_uuid
				break
				;;
			[Dd] | [Aa][Ii] | 233 | 233[Bb][Ll][Oo][Gg] | 233[Bb][Ll][Oo][Gg].[Cc][Oo][Mm] | 233[Bb][Oo][Yy] | [Aa][Ll][Tt][Ee][Rr][Ii][Dd])
				change_v2ray_alterId
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
}
change_v2ray_port() {
	if [[ $v2ray_transport == 4 ]]; then
		echo
		echo -e " Como você está usando o protocolo de transporte $yellow WebSocket + TLS $none ... então não faz diferença se você modifica a porta V2Ray ou não"
		echo
		echo  " Se você quiser usar outra porta... você pode modificar o protocolo de transporte V2Ray primeiro... e depois modificar a porta V2Ray"
		echo
		change_v2ray_transport_ask
	elif [[ $v2ray_transport == 5 ]]; then
		echo
		echo -e "Como você está usando o protocolo de transporte $yellow HTTP/2 $none... então não faz diferença se você modifica a porta V2Ray ou não"
		echo
		echo " Se você quiser usar outra porta... você pode modificar o protocolo de transporte V2Ray primeiro... e depois modificar a porta V2Ray"
		echo
		change_v2ray_transport_ask
	else
		echo
		while :; do
			echo -e "Por favor, insira a porta "$yellow"V2Ray"$none" ["$magenta"1-65535"$none"]"
			read -p "$(echo -e "(porta atual: ${cyan}${v2ray_port}$none):")" v2ray_port_opt
			[[ -z $v2ray_port_opt ]] && error && continue
			case $v2ray_port_opt in
			$v2ray_port)
				echo
				echo " Oops...é o mesmo que a porta atual...modifique algo.."
				error
				;;
			[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
				if [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start == $v2ray_port_opt || $v2ray_dynamicPort_end == $v2ray_port_opt ]]; then
					echo
					echo -e "Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
					error
				elif [[ $dynamicPort ]] && [[ $v2ray_dynamicPort_start -lt $v2ray_port_opt && $v2ray_port_opt -le $v2ray_dynamicPort_end ]]; then
					echo
					echo -e " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：${cyan}$port_range${none}"
					error
				elif [[ $shadowsocks && $v2ray_port_opt == $ssport ]]; then
					echo
					echo -e "Desculpe, esta porta está em conflito com a porta Shadowsocks...porta atual do Shadowsocks: ${cyan}$ssport$none"
					error
				elif [[ $socks && $v2ray_port_opt == $socks_port ]]; then
					echo
					echo -e "Desculpe, esta porta está em conflito com a porta Socks...porta atual do Socks: ${cyan}$socks_port$none"
					error
				elif [[ $mtproto && $v2ray_port_opt == $mtproto_port ]]; then
					echo
					echo -e "Desculpe, esta porta está em conflito com a porta MTProto...porta MTProto atual: ${cyan}$mtproto_port$none"
					error
				else
					echo
					echo
					echo -e "$yellow Porta V2Ray = $cyan$v2ray_port_opt$none"
					echo "----------------------------------------------------------------"
					echo
					pause
					backup_config v2ray_port
					v2ray_port=$v2ray_port_opt
					config
					clear
					view_v2ray_config_info
					# download_v2ray_config_ask
					break
				fi
				;;
			*)
				error
				;;
			esac

		done
	fi

}
download_v2ray_config_ask() {
	echo
	while :; do
		echo -e "Você precisa baixar a configuração do V2Ray / gerar o link de informações de configuração / gerar o link do código QR [${magenta}Y/N$none]"
		read -p "$(echo -e "padrão [${cyan}N$none]:")" y_n
		[ -z $y_n ] && y_n="n"
		if [[ $y_n == [Yy] ]]; then
			download_v2ray_config
			break
		elif [[ $y_n == [Nn] ]]; then
			break
		else
			error
		fi
	done

}
change_v2ray_transport_ask() {
	echo
	while :; do
		echo -e "Você precisa modificar o protocolo de transporte $yellow V2Ray $none [${magenta}Y/N$none]"
		read -p "$(echo -e "padrão [${cyan}N$none]:")" y_n
		[ -z $y_n ] && break
		if [[ $y_n == [Yy] ]]; then
			change_v2ray_transport
			break
		elif [[ $y_n == [Nn] ]]; then
			break
		else
			error
		fi
	done
}
change_v2ray_transport() {
	echo
	while :; do
		echo -e "Selecione o protocolo de transporte "$yellow"V2Ray"$none" [${magenta}1-${#transport[*]}$none]"
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
		echo "Nota 1: uma porta dinâmica é habilitada com [dynamicPort].."
		echo "Nota 2: [utp | srtp | wechat-video | dtls | wireguard] respectivamente disfarçados como [BT download | videochamada | WeChat videochamada | DTLS 1.2 packet | WireGuard packet]"
		echo
		read -p "$(echo -e "(protocolo de transporte atual: ${cyan}${transport[$v2ray_transport - 1]}$none)"):" v2ray_transport_opt
		if [ -z "$v2ray_transport_opt" ]; then
			error
		else
			case $v2ray_transport_opt in
			$v2ray_transport)
				echo
				echo " Ops... é o mesmo que o protocolo de transporte atual... modifique um pau."
				error
				;;
			4 | 5 | 33)
				if [[ $v2ray_port == "80" || $v2ray_port == "443" ]]; then
					echo
					echo -e " Desculpe... se você quiser usar ${cyan} ${transport[$v2ray_transport_opt - 1]} $none transport protocol.. ${red}V2Ray port não pode ser 80 ou 443...$none"
					echo
					echo -e " Porta V2Ray atual: ${cyan}$v2ray_port$none"
					error
				elif [[ $shadowsocks ]] && [[ $ssport == "80" || $ssport == "443" ]]; then
					echo
					echo -e  " Desculpe... se você quiser usar ${cyan} ${transport[$v2ray_transport_opt - 1]} $none transport protocol.. ${red}A porta Shadowsocks não pode ser 80 ou 443...$none"
					echo
					echo -e " Porta atual de Shadowsocks: ${cyan}$ssport$none"
					error
				elif [[ $socks ]] && [[ $socks_port == "80" || $socks_port == "443" ]]; then
					echo
					echo -e "Desculpe... se você quiser usar ${cyan} ${transport[$v2ray_transport_opt - 1]} $none transport protocol.. ${red}A porta Socks não pode ser 80 ou 443...$none"
					echo
					echo -e "Porta atual das meias: ${cyan}$socks_port$none"
					error
				elif [[ $mtproto ]] && [[ $mtproto_port == "80" || $mtproto_port == "443" ]]; then
					echo
					echo -e "Desculpe... se você quiser usar ${cyan} ${transport[$v2ray_transport_opt - 1]} $none transport protocol.. ${red}MTProto port não pode ser 80 ou 443...$none"
					echo
					echo -e " Porta MTProto atual: ${cyan}$mtproto_port$none"
					error
				else
					echo
					echo
					echo -e "$yellow Protocolo de Transporte V2Ray = $cyan${transport[$v2ray_transport_opt - 1]}$none"
					echo "----------------------------------------------------------------"
					echo
					break
				fi
				;;
			[1-9] | [1-2][0-9] | 3[0-3])
				echo
				echo
				echo -e "$yellow Protocolo de transporte V2Ray = $cyan${transport[$v2ray_transport_opt - 1]}$none"
				echo "----------------------------------------------------------------"
				echo
				break
				;;
			*)
				error
				;;
			esac
		fi

	done
	pause

	if [[ $v2ray_transport_opt == [45] || $v2ray_transport_opt == 33 ]]; then
		tls_config
	elif [[ $v2ray_transport_opt -ge 18 && $v2ray_transport_opt -ne 33 ]]; then
		v2ray_dynamic_port_start
		v2ray_dynamic_port_end
		pause
		old_transport
		backup_config v2ray_transport v2ray_dynamicPort_start v2ray_dynamicPort_end
		port_range="${v2ray_dynamic_port_start_input}-${v2ray_dynamic_port_end_input}"
		v2ray_transport=$v2ray_transport_opt
		config
		clear
		view_v2ray_config_info
		# download_v2ray_config_ask
	else
		old_transport
		backup_config v2ray_transport
		v2ray_transport=$v2ray_transport_opt
		config
		clear
		view_v2ray_config_info
		# download_v2ray_config_ask
	fi

}
old_transport() {
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]]; then
		if [[ $caddy && $caddy_pid ]]; then
			do_service stop caddy
			if [[ $systemd ]]; then
				systemctl disable caddy >/dev/null 2>&1
			else
				update-rc.d -f caddy remove >/dev/null 2>&1
			fi
		elif [[ $caddy ]]; then
			if [[ $systemd ]]; then
				systemctl disable caddy >/dev/null 2>&1
			else
				update-rc.d -f caddy remove >/dev/null 2>&1
			fi
		fi
		if [[ $is_path ]]; then
			backup_config -path
		fi
	fi
}

tls_config() {
	while :; do
		echo
		echo
		echo
		echo -e "Insira um ${magenta}nome de domínio correto${none}, deve estar correto, não! posso! Fora! errado! "
		read -p "(Por exemplo: 233blog.com): " new_domain
		[ -z "$new_domain" ] && error && continue
		echo
		echo
		echo -e "$yellow seu nome de domínio = $cyan$new_domain$none"
		echo "----------------------------------------------------------------"
		break
	done
	get_ip
	echo
	echo
	echo -e "$yellow por favor $magenta$new_domain$none $yellow resolver: $cyan$ip$none"
	echo
	echo -e "$yellow por favor $magenta$new_domain$none $yellow resolver: $cyan$ip$none"
	echo
	echo -e "$yellow por favor $magenta$new_domain$none $yellow resolver: $cyan$ip$none"
	echo "----------------------------------------------------------------"
	echo

	while :; do

		read -p "$(echo -e "(Está analisado corretamente: [${magenta}Y$none]):") " record
		if [[ -z "$record" ]]; then
			error
		else
			if [[ "$record" == [Yy] ]]; then
				domain_check
				echo
				echo
				echo -e "$yellow resolução de nome de domínio = ${cyan}Tenho certeza que já está resolvido $none"
				echo "----------------------------------------------------------------"
				echo
				break
			else
				error
			fi
		fi

	done

	if [[ $caddy ]]; then
		path_config_ask
		pause
		# domain_check
		backup_config v2ray_transport domain
		if [[ $new_path ]]; then
			backup_config +path
			path=$new_path
			proxy_site=$new_proxy_site
			is_path=true
		fi

		domain=$new_domain

		if [[ $systemd ]]; then
			systemctl enable caddy >/dev/null 2>&1
		else
			update-rc.d -f caddy defaults >/dev/null 2>&1
		fi
		v2ray_transport=$v2ray_transport_opt
		caddy_config
		config
		clear
		view_v2ray_config_info
		# download_v2ray_config_ask
	else
		if [[ $v2ray_transport_opt -ne 4 ]]; then
			path_config_ask
			pause
			domain_check
			backup_config v2ray_transport domain caddy
			if [[ $new_path ]]; then
				backup_config +path
				path=$new_path
				proxy_site=$new_proxy_site
				is_path=true
			fi
			domain=$new_domain
			install_caddy
			v2ray_transport=$v2ray_transport_opt
			caddy_config
			config
			caddy=true
			clear
			view_v2ray_config_info
			# download_v2ray_config_ask
		else
			auto_tls_config
		fi
	fi

}
auto_tls_config() {
	echo -e "

		Instale o Caddy para configurar automaticamente o TLS

		Se você tiver o Nginx ou o Caddy instalado

		$yellow e.. você mesmo pode configurar o TLS $none

		então não há necessidade de ativar o TLS de configuração automática			
		"
	echo "----------------------------------------------------------------"
	echo

	while :; do

		read -p "$(echo -e "(Se deve configurar o TLS automaticamente: [${magenta}Y/N$none]):") " auto_install_caddy
		if [[ -z "$auto_install_caddy" ]]; then
			error
		else
			if [[ "$auto_install_caddy" == [Yy] ]]; then
				echo
				echo
				echo -e "$yellow Configurar TLS automaticamente = $cyan打开$none"
				echo "----------------------------------------------------------------"
				echo
				path_config_ask
				pause
				domain_check
				backup_config v2ray_transport domain caddy
				if [[ $new_path ]]; then
					backup_config +path
					path=$new_path
					proxy_site=$new_proxy_site
					is_path=true
				fi
				domain=$new_domain
				install_caddy
				v2ray_transport=$v2ray_transport_opt
				caddy_config
				config
				caddy=true
				clear
				view_v2ray_config_info
				# download_v2ray_config_ask
				break
			elif [[ "$auto_install_caddy" == [Nn] ]]; then
				echo
				echo
				echo -e "$yellow Configurar TLS automaticamente = $cyan desativado$none"
				echo "----------------------------------------------------------------"
				echo
				pause
				domain_check
				backup_config v2ray_transport domain
				domain=$new_domain
				v2ray_transport=$v2ray_transport_opt
				config
				clear
				view_v2ray_config_info
				# download_v2ray_config_ask
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
		echo -e "Se deve ativar o mascaramento do site e o desvio de caminho [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão: [${cyan}N$none]):")" path_ask
		[[ -z $path_ask ]] && path_ask="n"

		case $path_ask in
		Y | y)
			path_config
			break
			;;
		N | n)
			echo
			echo
			echo -e "$yellow Mascaramento de site e divisão de caminho = $cyan não deseja configurar $none"
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
		echo -e "Por favor, digite o caminho que você deseja que ${magenta} use para desviar $none , como /233blog , então apenas digite 233blog "
		read -p "$(echo -e "(padrão: [${cyan}233blog$none]):")" new_path
		[[ -z $new_path ]] && new_path="233blog"

		case $new_path in
		*[/$]*)
			echo
			echo -e "Porque este script é muito picante.. então o caminho do desvio não pode conter os dois símbolos $red / $none ou $red $ $none ...."
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow caminho de desvio = ${cyan}/${new_path}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done
	proxy_site_config
}
proxy_site_config() {
	echo
	while :; do
		echo -e "Por favor, digite ${magenta} um $none ${cyan} URL$none correto para ser usado como um falso $none para sites ${cyan}, por exemplo https://google.com"
		echo -e "Exemplo... digamos que seu domínio atual seja $green $domain $none, e o URL falso seja https://google.com"
		echo -e "Então, quando você abre seu domínio... o conteúdo exibido é o conteúdo de https://google.com"
		echo -e "Na verdade, é uma anti-geração... apenas entenda..."
		echo -e "Se você não conseguir disfarçar com sucesso... você pode usar a configuração v2ray para modificar o URL disfarçado"
		read -p "$(echo -e "(padrão: [${cyan}https://google.com$none]):")" new_proxy_site
		[[ -z $new_proxy_site ]] && new_proxy_site="https://google.com"

		case $new_proxy_site in
		*[#$]*)
			echo
			echo -e " Como esse script é muito picante, o URL falso não pode conter os símbolos $red # $none ou $red $ $none. …"
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow URL falso = ${cyan}${new_proxy_site}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done
}

install_caddy() {
	_load download-caddy.sh
	_download_caddy_file
	_install_caddy_service

}
caddy_config() {
	# local email=$(shuf -i1-10000000000 -n1)
	_load caddy-config.sh
	# systemctl restart caddy
	do_service restart caddy
}
v2ray_dynamic_port_start() {
	echo
	echo
	while :; do
		echo -e "Por favor, digite "$yellow" V2Ray dynamic port start "$none" range ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Porta inicial padrão: ${cyan}10000$none):")" v2ray_dynamic_port_start_input
		[ -z $v2ray_dynamic_port_start_input ] && v2ray_dynamic_port_start_input=10000
		case $v2ray_dynamic_port_start_input in
		$v2ray_port)
			echo
			echo " porta V2Ray livre..."
			echo
			echo -e " Porta V2Ray atual: ${cyan}$v2ray_port${none}"
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $shadowsocks && $v2ray_dynamic_port_start_input == $ssport ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Shadowsocks...porta atual do Shadowsocks: ${cyan}$ssport$none"
				error
			elif [[ $socks && $v2ray_dynamic_port_start_input == $socks_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Socks...porta atual do Socks: ${cyan}$socks_port$none"
				error
			elif [[ $mtproto && $v2ray_dynamic_port_start_input == $mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta MTProto...porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow A porta dinâmica V2Ray é iniciada= $cyan$v2ray_dynamic_port_start_input$none"
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

	if [[ $v2ray_dynamic_port_start_input -lt $v2ray_port ]]; then
		lt_v2ray_port=true
	fi
	if [[ $shadowsocks ]] && [[ $v2ray_dynamic_port_start_input -lt $ssport ]]; then
		lt_ssport=true
	fi
	if [[ $socks ]] && [[ $v2ray_dynamic_port_start_input -lt $socks_port ]]; then
		lt_socks_port=true
	fi
	if [[ $mtproto ]] && [[ $v2ray_dynamic_port_start_input -lt $mtproto_port ]]; then
		lt_mtproto_port=true
	fi

}

v2ray_dynamic_port_end() {
	echo
	while :; do
		echo -e "Insira "$yellow" V2Ray dynamic port end "$none" range ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Porta final padrão: ${cyan}20000$none):")" v2ray_dynamic_port_end_input
		[ -z $v2ray_dynamic_port_end_input ] && v2ray_dynamic_port_end_input=20000
		case $v2ray_dynamic_port_end_input in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])

			if [[ $v2ray_dynamic_port_end_input -le $v2ray_dynamic_port_start_input ]]; then
				echo
				echo "Não pode ser menor ou igual ao intervalo de início da porta dinâmica V2Ray"
				echo
				echo -e " A porta dinâmica atual do V2Ray inicia：${cyan}$v2ray_dynamic_port_start_input${none}"
				error
			elif [ $lt_v2ray_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $v2ray_port ]]; then
				echo
				echo " Faixa de extremidade da porta dinâmica V2Ray Não pode incluir portas V2Ray..."
				echo
				echo -e " Porta V2Ray atual: ${cyan}$v2ray_port$none"
				error
			elif [ $lt_ssport ] && [[ ${v2ray_dynamic_port_end_input} -ge $ssport ]]; then
				echo
				echo "O intervalo de portas dinâmicas do V2Ray não pode incluir portas Shadowsocks..."
				echo
				echo -e " Porta atual de Shadowsocks: ${cyan}$ssport$none"
				error
			elif [ $lt_socks_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $socks_port ]]; then
				echo
				echo " O intervalo de extremidade da porta dinâmica V2Ray não pode incluir portas Socks..."
				echo
				echo -e "Porta atual das meias: ${cyan}$socks_port$none"
				error
			elif [ $lt_mtproto_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $mtproto_port ]]; then
				echo
				echo " O intervalo de extremidade da porta dinâmica V2Ray não pode incluir portas MTProto..."
				echo
				echo -e " Porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow A porta dinâmica V2Ray termina = $cyan$v2ray_dynamic_port_end_input$none"
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
change_v2ray_dynamicport() {
	if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		change_v2ray_dynamic_port_start
		change_v2ray_dynamic_port_end
		pause
		backup_config v2ray_dynamicPort_start v2ray_dynamicPort_end
		port_range="${v2ray_dynamic_port_start_input}-${v2ray_dynamic_port_end_input}"
		config
		# clear
		echo
		echo -e "$green A modificação da porta dinâmica foi bem-sucedida... você não precisa modificar a configuração do cliente V2Ray... mantenha a configuração original...$none"
		echo
	else
		echo
		echo -e "$red ...O protocolo de transporte atual não possui portas dinâmicas habilitadas...$none"
		echo
		while :; do
			echo -e "O protocolo de transferência precisa ser modificado? [${magenta}Y/N$none]"
			read -p "$(echo -e "padrão [${cyan}N$none]:")" y_n
			if [[ -z $y_n ]]; then
				echo
				echo -e "$green Modificar protocolo de transferência cancelado...$none"
				echo
				break
			else
				if [[ $y_n == [Yy] ]]; then
					change_v2ray_transport
					break
				elif [[ $y_n == [Nn] ]]; then
					echo
					echo -e "$green Modificar protocolo de transferência cancelado...$none"
					echo
					break
				else
					error
				fi
			fi
		done

	fi
}
change_v2ray_dynamic_port_start() {
	echo
	echo
	while :; do
		echo -e "Insira "$yellow" V2Ray dynamic port start "$none" range ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Porta inicial dinâmica atual: ${cyan}$v2ray_dynamicPort_start$none):")" v2ray_dynamic_port_start_input
		[ -z $v2ray_dynamic_port_start_input ] && error && continue
		case $v2ray_dynamic_port_start_input in
		$v2ray_port)
			echo
			echo " Nada como a porta V2Ray..."
			echo
			echo -e " Porta V2Ray atual: ${cyan}$v2ray_port${none}"
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $shadowsocks && $v2ray_dynamic_port_start_input == $ssport ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Shadowsocks...Porta atual do Shadowsocks: ${cyan}$ssport$none"
				error
			elif [[ $socks && $v2ray_dynamic_port_start_input == $socks_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta Socks...Porta atual do Socks: ${cyan}$socks_port$none"
				error
			elif [[ $mtproto && $v2ray_dynamic_port_start_input == $mtproto_port ]]; then
				echo
				echo -e "Desculpe, esta porta está em conflito com a porta MTProto...Porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow A porta dinâmica V2Ray é iniciada = $cyan$v2ray_dynamic_port_start_input$none"
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

	if [[ $v2ray_dynamic_port_start_input -lt $v2ray_port ]]; then
		lt_v2ray_port=true
	fi
	if [[ $shadowsocks ]] && [[ $v2ray_dynamic_port_start_input -lt $ssport ]]; then
		lt_ssport=true
	fi
	if [[ $socks ]] && [[ $v2ray_dynamic_port_start_input -lt $socks_port ]]; then
		lt_socks_port=true
	fi
	if [[ $mtproto ]] && [[ $v2ray_dynamic_port_start_input -lt $mtproto_port ]]; then
		lt_mtproto_port=true
	fi
}

change_v2ray_dynamic_port_end() {
	echo
	while :; do
		echo -e "Por favor, insira "$yellow" V2Ray final da porta dinâmica "$none" intervalo ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Porta final dinâmica atual : ${cyan}$v2ray_dynamicPort_end$none):")" v2ray_dynamic_port_end_input
		[ -z $v2ray_dynamic_port_end_input ] && error && continue
		case $v2ray_dynamic_port_end_input in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])

			if [[ $v2ray_dynamic_port_end_input -le $v2ray_dynamic_port_start_input ]]; then
				echo
				echo " Não pode ser menor ou igual ao intervalo inicial da porta dinâmica do V2Ray"
				echo
				echo -e " A porta dinâmica atual do V2Ray inicia: ${cyan}$v2ray_dynamic_port_start_input${none}"
				error
			elif [ $lt_v2ray_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $v2ray_port ]]; then
				echo
				echo " O intervalo de extremidade da porta dinâmica V2Ray não pode incluir portas V2Ray..."
				echo
				echo -e " Porta V2Ray atual: ${cyan}$v2ray_port$none"
				error
			elif [ $lt_ssport ] && [[ ${v2ray_dynamic_port_end_input} -ge $ssport ]]; then
				echo
				echo " A faixa de extremidade da porta dinâmica V2Ray não pode incluir a porta Shadowsocks..."
				echo
				echo -e " Porta atual de Shadowsocks: ${cyan}$ssport$none"
				error
			elif [ $lt_socks_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $socks_port ]]; then
				echo
				echo "O intervalo de extremidade da porta dinâmica V2Ray não pode incluir portas Socks..."
				echo
				echo -e " Porta atual das meias: ${cyan}$socks_port$none"
				error
			elif [ $lt_mtproto_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $mtproto_port ]]; then
				echo
				echo " O intervalo de extremidade da porta dinâmica V2Ray não pode incluir portas MTProto..."
				echo
				echo -e " Porta MTProto atual: ${cyan}$mtproto_port$none"
				error
			else
				echo
				echo
				echo -e "$yellow A porta dinâmica V2Ray termina = $cyan$v2ray_dynamic_port_end_input$none"
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
change_v2ray_id() {
	echo
	while :; do
		echo -e "Tem certeza de que deseja modificar o ID do usuário [${magenta}Y/N$none]"
		read -p "$(echo -e "padrão [${cyan}N$none]:")" y_n
		if [[ -z $y_n ]]; then
			echo
			echo -e "$green Modificação do ID do usuário cancelada...$none"
			echo
			break
		else
			if [[ $y_n == [Yy] ]]; then
				echo
				echo
				echo -e "$yellow Modificar ID do usuário = $cyan Claro$none"
				echo "----------------------------------------------------------------"
				echo
				pause
				backup_config uuid
				v2ray_id=$uuid
				config
				clear
				view_v2ray_config_info
				# download_v2ray_config_ask
				break
			elif [[ $y_n == [Nn] ]]; then
				echo
				echo -e "$green Modificação do ID do usuário cancelada...$none"
				echo
				break
			else
				error
			fi
		fi
	done
}
change_domain() {
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy ]]; then
		while :; do
			echo
			echo -e "Por favor, digite um nome de domínio ${magenta}correto${none}, deve estar correto, não! Sim! Errado! Errado!"
			read -p "$(echo -e "(nome de domínio atual: ${cyan}$domain$none):") " new_domain
			[ -z "$new_domain" ] && error && continue
			if [[ $new_domain == $domain ]]; then
				echo
				echo -e " É o mesmo que o nome de domínio atual... modifique algo..."
				echo
				error && continue
			fi
			echo
			echo
			echo -e "$yellow seu nome de domínio = $cyan$new_domain$none"
			echo "----------------------------------------------------------------"
			break
		done
		get_ip
		echo
		echo
		echo -e "$yellow por favor $magenta$new_domain$none $yellow resolver: $cyan$ip$none"
		echo
		echo -e "$yellow por favor $magenta$new_domain$none $yellow resolver: $cyan$ip$none"
		echo
		echo -e "$yellow por favor $magenta$new_domain$none $yellow resolver: $cyan$ip$none"
		echo "----------------------------------------------------------------"
		echo

		while :; do

			read -p "$(echo -e "(Está analisado corretamente: [${magenta}Y$none]):") " record
			if [[ -z "$record" ]]; then
				error
			else
				if [[ "$record" == [Yy] ]]; then
					domain_check
					echo
					echo
					echo -e "$yellow Resolução de nome de domínio = ${cyan}já está resolvido$none"
					echo "----------------------------------------------------------------"
					echo
					pause
					# domain_check
					backup_config domain
					domain=$new_domain
					caddy_config
					config
					clear
					view_v2ray_config_info
					# download_v2ray_config_ask
					break
				else
					error
				fi
			fi

		done
	else
		echo
		echo -e "$red Desculpe... a modificação não é suportada...$none"
		echo
		echo -e " Observações.. Modificar o nome de domínio TLS suporta apenas o protocolo de transporte como ${yellow}WebSocket + TLS$none ou ${yellow}HTTP/2$none e $yellow auto-configurar TLS = open $none"
		echo
		echo -e " O protocolo de transporte atual é: ${cyan}${transport[$v2ray_transport - 1]}${none}"
		echo
		if [[ $caddy ]]; then
			echo -e " Configuração TLS automática  = ${cyan} ativar$none"
		else
			echo -e " Configuração TLS automática  = $red desativar$none"
		fi
		echo
	fi
}
change_path_config() {
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy && $is_path ]]; then
		echo
		while :; do
			echo -e "Por favor, digite o caminho que você deseja que ${magenta} use para o desvio $none , por exemplo /233blog , então apenas digite 233blog "
			read -p "$(echo -e "(O caminho de desvio atual: [${cyan}/${path}$none]):")" new_path
			[[ -z $new_path ]] && error && continue

			case $new_path in
			$path)
				echo
				echo -e "Cara ... é o mesmo que o caminho de desvio atual... modifique um algo."
				echo
				error
				;;
			*[/$]*)
				echo
				echo -e " Porque este script é muito picante.. então o caminho do desvio não pode conter os dois símbolos $red / $none ou $red $ $none ...."
				echo
				error
				;;
			*)
				echo
				echo
				echo -e "$yellow caminho de desvio = ${cyan}/${new_path}$none"
				echo "----------------------------------------------------------------"
				echo
				break
				;;
			esac
		done
		pause
		backup_config path
		path=$new_path
		caddy_config
		config
		clear
		view_v2ray_config_info
		# download_v2ray_config_ask
	elif [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy ]]; then
		path_config_ask
		if [[ $new_path ]]; then
			backup_config +path
			path=$new_path
			proxy_site=$new_proxy_site
			is_path=true
			caddy_config
			config
			clear
			view_v2ray_config_info
			# download_v2ray_config_ask
		else
			echo
			echo
			echo " Dê um joinha para o grandalhão .... Então, desista decisivamente da configuração da camuflagem do site e do desvio de caminho "
			echo
			echo
		fi
	else
		echo
		echo -e "$red desculpe... a modificação não é suportada...$none"
		echo
		echo -e " Comentários.. Modifique o caminho do descarregamento para oferecer suporte apenas ao protocolo de transporte como ${yellow}WebSocket + TLS$none ou ${yellow}HTTP/2$none e $yellow auto-configure TLS = open $none"
		echo
		echo -e " O protocolo de transporte atual é: ${cyan}${transport[$v2ray_transport - 1]}${none}"
		echo
		if [[ $caddy ]]; then
			echo -e " Configurar TLS automaticamente = ${cyan} ativar$none"
		else
			echo -e " Configurar TLS automaticamente = $red desativar$none"
		fi
		echo
		change_v2ray_transport_ask
	fi

}
change_proxy_site_config() {
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy && $is_path ]]; then
		echo
		while :; do
			echo -e "Por favor, digite ${magenta} um correto $none ${cyan} url $none é usado como um falso $none para ${cyan} sites, por exemplo https://google.com"
			echo -e "Exemplo... seu nome de domínio atual é $green $domain $none, o URL falso é https://google.com"
			echo -e "Então, quando você abre seu nome de domínio... o conteúdo exibido é o conteúdo de https://google.com"
			echo -e "Na verdade é uma anti-geração... apenas entenda..."
			echo -e "Se você não conseguir disfarçar com sucesso...você pode usar a configuração v2ray para modificar o URL disfarçado"
			read -p "$(echo -e "(URL atualmente disfarçado: [${cyan}${proxy_site}$none]):")" new_proxy_site
			[[ -z $new_proxy_site ]] && error && continue

			case $new_proxy_site in
			*[#$]*)
				echo
				echo -e "Como esse script é muito picante, o URL falso não pode conter os símbolos $red # $none ou $red $ $none …"
				echo
				error
				;;
			*)
				echo
				echo
				echo -e "$yellow URL falso = ${cyan}${new_proxy_site}$none"
				echo "----------------------------------------------------------------"
				echo
				break
				;;
			esac
		done
		pause
		backup_config proxy_site
		proxy_site=$new_proxy_site
		caddy_config
		echo
		echo
		echo " Ai... Parece que a modificação foi bem sucedida..."
		echo
		echo -e "Abra rapidamente seu domínio ${cyan}https://${domain}$none e confira"
		echo
		echo
	elif [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy ]]; then
		path_config_ask
		if [[ $new_path ]]; then
			backup_config +path
			path=$new_path
			proxy_site=$new_proxy_site
			is_path=true
			caddy_config
			config
			clear
			view_v2ray_config_info
			# download_v2ray_config_ask
		else
			echo
			echo
			echo " Dê um joinha para o grandalhão .... Então, desista decisivamente da configuração da camuflagem do site e do desvio de caminho "
			echo
			echo
		fi
	else
		echo
		echo -e "$red Desculpe... a modificação não é suportada...$none"
		echo
		echo -e " Observações..Modificar URL de máscara para suportar apenas o protocolo de transporte como ${yellow}WebSocket + TLS$none ou ${yellow}HTTP/2$none e $yellow auto-configurar TLS = open $none"
		echo
		echo -e " O protocolo de transporte atual é: ${cyan}${transport[$v2ray_transport - 1]}${none}"
		echo
		if [[ $caddy ]]; then
			echo -e " Configurar TLS automaticamente = ${cyan} ativar$none"
		else
			echo -e "Configurar TLS automaticamente = $red desativar$none"
		fi
		echo
		change_v2ray_transport_ask
	fi

}
domain_check() {
	# test_domain=$(dig $new_domain +short)
	test_domain=$(ping $new_domain -c 1 -4 -W 2 | grep -oE -m1 "([0-9]{1,3}\.){3}[0-9]{1,3}")
	# test_domain=$(wget -qO- --header='accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$new_domain&type=A" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -1)
	# test_domain=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$new_domain&type=A" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -1)
	if [[ $test_domain != $ip ]]; then
		echo
		echo -e "$red Detectar erros de resolução de nomes de domínio....$none"
		echo
		echo -e "Seu domínio: $yellow$new_domain$none não foi resolvido para: $cyan$ip$none"
		echo
		echo -e " Seu nome de domínio atualmente resolve para: $cyan$test_domain$none"
		echo
		echo "Observação... se o seu domínio for resolvido usando Cloudflare.. clique nesse ícone em Status.. deixe-o acinzentado"
		echo
		exit 1
	fi
}
disable_path() {
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy && $is_path ]]; then
		echo

		while :; do
			echo -e "Desativar ${yellow} mascaramento de site e desvio de caminho ${none} [${magenta}Y/N$none]"
			read -p "$(echo -e "(padrão [${cyan}N$none]):") " y_n
			[[ -z "$y_n" ]] && y_n="n"
			if [[ "$y_n" == [Yy] ]]; then
				echo
				echo
				echo -e "$yellow Desative o mascaramento e o roteamento de sites = $cyan sim$none"
				echo "----------------------------------------------------------------"
				echo
				pause
				backup_config -path
				is_path=''
				caddy_config
				config
				clear
				view_v2ray_config_info
				# download_v2ray_config_ask
				break
			elif [[ "$y_n" == [Nn] ]]; then
				echo
				echo -e " $greenO mascaramento e o roteamento de sites foram removidos...$none"
				echo
				break
			else
				error
			fi

		done
	else
		echo
		echo -e "$red desculpe... a modificação não é suportada...$none"
		echo
		echo -e " O protocolo de transporte atual é: ${cyan}${transport[$v2ray_transport - 1]}${none}"
		echo
		if [[ $caddy ]]; then
			echo -e " Configurar TLS automaticamente = ${cyan}ativar$none"
		else
			echo -e " Configurar TLS automaticamente = $red desativar$none"
		fi
		echo
		if [[ $is_path ]]; then
			echo -e " desvio de caminho = ${cyan}ativar$none"
		else
			echo -e " desvio de caminho = $red desativar$none"
		fi
		echo
		echo -e " Deve ser protocolo de transporte WebSocket + TLS ou HTTP/2, TLS de configuração automática = ${cyan} open $none, divisão de caminho = ${cyan} open $none, pode ser modificado"
		echo

	fi
}
blocked_hosts() {
	if [[ $ban_ad ]]; then
		local _info="$green ativado$none"
	else
		local _info="$red desativado$none"
	fi
	_opt=''
	while :; do
		echo
		echo -e "$yellow 1. $none Ative o Bloqueio de anúncios"
		echo
		echo -e "$yellow 2. $none Desative o Bloqueio de anúncios"
		echo
		echo "Observação: o bloqueio de anúncios é baseado no bloqueio de nomes de domínio. Portanto, pode fazer com que alguns elementos fiquem em branco ao navegar na web ou outros problemas"
		echo
		echo "Problemas de feedback ou solicitações para bloquear mais domínios: https://github.com/233boy/v2ray/issues"
		echo
		echo -e "Status atual de bloqueio de anúncios: $_info"
		echo
		read -p "$(echo -e "por favor escolha [${magenta}1-2$none]:")" _opt
		if [[ -z $_opt ]]; then
			error
		else
			case $_opt in
			1)
				if [[ $ban_ad ]]; then
					echo
					echo -e " Peitos grandes... Será que você não viu (status atual de bloqueio de anúncios: $_info) este belo lembrete... e ele virou um pau."
					echo
				else
					echo
					echo
					echo -e "$yellow bloqueador de anúncios = $cyan em $none"
					echo "----------------------------------------------------------------"
					echo
					pause
					backup_config +ad
					ban_ad=true
					config
					echo
					echo
					echo -e "$green O bloqueador de anúncios está ativado... se algo der errado... desligue-o$none"
					echo
				fi
				break
				;;
			2)
				if [[ $ban_ad ]]; then
					echo
					echo
					echo -e "$yellow bloqueador de anúncios = $cyan off$none"
					echo "----------------------------------------------------------------"
					echo
					pause
					backup_config -ad
					ban_ad=''
					config
					echo
					echo
					echo -e "$red O bloqueio de anúncios está desativado... mas você sempre pode ativá-lo novamente... se quiser$none"
					echo
				else
					echo
					echo -e " Peitos grandes... Será que você não viu (status atual de bloqueio de anúncios: $_info) essa dica linda... e desligue-a."
					echo
				fi
				break
				;;
			*)
				error
				;;
			esac
		fi
	done

}
change_v2ray_alterId() {
	echo
	while :; do
		echo -e "Por favor, insira ${yellow}alterId${none} o valor de [${magenta}0-65535$none]"
		read -p "$(echo -e "(O valor atual é: ${cyan}$alterId$none):") " new_alterId
		[[ -z $new_alterId ]] && error && continue
		case $new_alterId in
		$alterId)
			echo
			echo -e " Cara grande... é o mesmo que o alterId atual... modifique um pau "
			echo
			error
			;;
		[0-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow alterId = $cyan$new_alterId$none"
			echo "----------------------------------------------------------------"
			echo
			pause
			backup_config alterId
			alterId=$new_alterId
			config
			clear
			view_v2ray_config_info
			# download_v2ray_config_ask
			break
			;;
		*)
			error
			;;
		esac
	done
}

custom_uuid() {
	echo
	while :; do
		echo -e "Insira o UUID$none personalizado de $yello...(${cyan}O formato UUID deve estar correto!!!$none)"
		read -p "$(echo -e "(atual UUID: ${cyan}${v2ray_id}$none)"): " myuuid
		[ -z "$myuuid" ] && error && continue
		case $myuuid in
		$v2ray_id)
			echo
			echo -e " Cara grande... é o mesmo que o UUID atual... modifique um pau."
			echo
			error
			;;
		*[/$]* | *\&*)
			echo
			echo -e " Porque este script é muito picante .. então UUID não pode conter os três símbolos $red / $none ou $red $ $none ou $red & $none ...."
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow UUID = $cyan$myuuid$none"
			echo
			echo -e "Porque este script é muito picante .. então UUID não pode conter os três símbolos $red / $none ou $red $ $none ou $red & $none ...."
			echo "----------------------------------------------------------------"
			echo
			pause
			uuid=$myuuid
			backup_config uuid
			v2ray_id=$uuid
			config
			clear
			view_v2ray_config_info
			# download_v2ray_config_ask
			break
			;;
		esac
	done
}
v2ray_service() {
	while :; do
		echo
		echo -e "$yellow 1. $none start V2Ray"
		echo
		echo -e "$yellow 2. $none stop V2Ray"
		echo
		echo -e "$yellow 3. $none reinicie o V2Ray"
		echo
		echo -e "$yellow 4. $none ver log de acesso"
		echo
		echo -e "$yellow 5. $none ver log de erros"
		echo
		read -p "$(echo -e "Por favor, escolha [${magenta}1-5$none]:")" _opt
		if [[ -z $_opt ]]; then
			error
		else
			case $_opt in
			1)
				start_v2ray
				break
				;;
			2)
				stop_v2ray
				break
				;;
			3)
				restart_v2ray
				break
				;;
			4)
				view_v2ray_log
				break
				;;
			5)
				view_v2ray_error_log
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
}
start_v2ray() {
	if [[ $v2ray_pid ]]; then
		echo
		echo -e "${green} V2Ray está rodando... não há necessidade de iniciar $none novamente"
		echo
	else

		# systemctl start v2ray
		service v2ray start >/dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			echo
			echo -e "${red} V2Ray falhou ao iniciar!$none"
			echo
		else
			echo
			echo -e "${green} V2Ray começou!$none"
			echo
		fi

	fi
}
stop_v2ray() {
	if [[ $v2ray_pid ]]; then
		# systemctl stop v2ray
		service v2ray stop >/dev/null 2>&1
		echo
		echo -e "${green} V2Ray parou$none"
		echo
	else
		echo
		echo -e "${red} V2Ray não está rodando$none"
		echo
	fi
}
restart_v2ray() {
	# systemctl restart v2ray
	service v2ray restart >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo
		echo -e "${red} Falha na reinicialização do V2Ray！$none"
		echo
	else
		echo
		echo -e "${green} A reinicialização do V2Ray está concluída $none"
		echo
	fi
}
view_v2ray_log() {
	echo
	echo -e "$green Pressione Ctrl + C para sair...$none"
	echo
	tail -f /var/log/v2ray/access.log
}
view_v2ray_error_log() {
	echo
	echo -e "$green Pressione Ctrl + C para sair...$none"
	echo
	tail -f /var/log/v2ray/error.log
}
download_v2ray_config() {
	while :; do
		echo
		echo -e "$yellow 1. $none Baixe o arquivo de configuração do cliente V2Ray diretamente (suporta apenas Xshell)"
		echo
		echo -e "$yellow 2. $none Gerar link de download do arquivo de configuração do cliente V2Ray"
		echo
		echo -e "$yellow 3. $none Gerar link de informações de configuração do V2Ray"
		echo
		echo -e "$yellow 4. $none Gerar link de código QR de configuração do V2Ray"
		echo
		read -p "$(echo -e "por favor escolha [${magenta}1-4$none]:")" other_opt
		if [[ -z $other_opt ]]; then
			error
		else
			case $other_opt in
			1)
				get_v2ray_config
				break
				;;
			2)
				get_v2ray_config_link
				break
				;;
			3)
				get_v2ray_config_info_link
				break
				;;
			4)
				get_v2ray_config_qr_link
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
}
get_v2ray_config() {
	config
	echo
	echo "Se o seu cliente SSH atual não for o Xshell... o download do arquivo de configuração do cliente V2Ray ficará travado"
	echo
	while :; do
		read -p "$(echo -e "Não BB... Brother está usando Xshell [${magenta}Y$none]:")" is_xshell
		if [[ -z $is_xshell ]]; then
			error
		else
			if [[ $is_xshell == [yY] ]]; then
				echo
				echo "Iniciando download....Selecione um local para salvar o arquivo de configuração do cliente V2Ray"
				echo
				# sz /etc/v2ray/233blog_v2ray.zip
				local tmpfile="/tmp/233blog_v2ray_config_$RANDOM.json"
				cp -f $v2ray_client_config $tmpfile
				sz $tmpfile
				echo
				echo
				echo -e "$green Download completo...$none"
				echo
				# echo -e "$yellow 解压密码 = ${cyan}233blog.com$none"
				# echo
				echo -e "$yellow Porta de escuta SOCKS = ${cyan}2333${none}"
				echo
				echo -e "${yellow}porta de escuta HTTP = ${cyan}6666$none"
				echo
				echo "Tutorial do cliente V2Ray: https://233v2.com/post/4/"
				echo
				break
			else
				error
			fi
		fi
	done
	[[ -f $tmpfile ]] && rm -rf $tmpfile

}
get_v2ray_config_link() {
	_load client_file.sh
	_get_client_file
}
create_v2ray_config_text() {

	get_transport_args

	echo
	echo
	echo "----------Informações de configuração do V2Ray-------------"
	if [[ $v2ray_transport == [45] ]]; then
		if [[ ! $caddy ]]; then
			echo
			echo "aviso ! Configure o TLS você mesmo... Tutorial: https://233v2.com/post/3/"
		fi
		echo
		echo "Endereço (Address) = ${domain}"
		echo
		echo "Porta (Port) = 443"
		echo
		echo "ID do usuário (User ID / UUID) = ${v2ray_id}"
		echo
		echo "ID extra (Alter Id) = ${alterId}"
		echo
		echo "Protocolo de transporte (Network) = ${net}"
		echo
		echo "tipo de camuflagem (header type) = ${header}"
		echo
		echo "nome de domínio falso (host) = ${domain}"
		echo
		echo "caminho (path) = ${_path}"
		echo
		echo "segurança de transporte subjacente (TLS) = tls"
		echo
		if [[ $ban_ad ]]; then
			echo " Observação: o bloqueio de anúncios está ativado.."
			echo
		fi
	elif [[ $v2ray_transport == 33 ]]; then
		echo
		echo '---dica..esta é a configuração do servidor VLESS---'
		echo
		echo "Endereço (Address) = ${domain}"
		echo
		echo "Porta (Port) = 443"
		echo
		echo "ID do usuário (User ID / UUID) = ${v2ray_id}"
		echo
		echo "Controle de fluxo (Flow) = nulo"
		echo
		echo "criptografia (Encryption) = none"
		echo
		echo "Protocolo de Transferência (Network) = ${net}"
		echo
		echo "tipo de camuflagem (header type) = ${header}"
		echo
		echo "nome de domínio falso (host) = ${domain}"
		echo
		echo "caminho (path) = ${_path}"
		echo
		echo "segurança de transporte subjacente (TLS) = tls"
		echo
		if [[ $ban_ad ]]; then
			echo " Observação: o bloqueio de anúncios está ativado.."
			echo
		fi
	else
		[[ -z $ip ]] && get_ip
		echo
		echo "Endereço (Address) = ${ip}"
		echo
		echo "Porta (Port) = $v2ray_port"
		echo
		echo "ID do usuário (User ID / UUID) = ${v2ray_id}"
		echo
		echo "ID extra (Alter Id) = ${alterId}"
		echo
		echo "Protocolo de Transferência (Network) = ${net}"
		echo
		echo "tipo de camuflagem (header type) = ${header}"
		echo
	fi
	if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]] && [[ $ban_ad ]]; then
		echo "Observação: portas dinâmicas ativadas...Bloqueio de anúncios ativado..."
		echo
	elif [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		echo "Nota: As portas dinâmicas estão habilitadas..."
		echo
	elif [[ $ban_ad ]]; then
		echo "Observação: o bloqueio de anúncios está ativado.."
		echo
	fi
	echo "---------- FIM -------------"
	echo
	echo "Tutorial do cliente V2Ray: https://233v2.com/post/4/"
	echo
}
get_v2ray_config_info_link() {
	echo
	echo -e "$green Gerando link.... Aguarde um momento....$none"
	echo
	create_v2ray_config_text >/tmp/233blog_v2ray.txt
	local random=$(echo $RANDOM-$RANDOM-$RANDOM | base64 -w 0)
	local link=$(curl -s --upload-file /tmp/233blog_v2ray.txt "https://transfer.sh/${random}_233v2_v2ray.txt")
	if [[ $link ]]; then
		echo
		echo "---------- Link de informações de configuração do V2Ray ------------"
		echo
		echo -e "$yellow Link = $cyan$link$none"
		echo
		echo -e " Tutorial do cliente V2Ray: https://233v2.com/post/4/"
		echo
		echo "Observação... o link expirará em 14 dias..."
		echo
		echo "Lembrete... por favor, não compartilhe o link... a menos que você tenha um motivo específico...."
		echo
	else
		echo
		echo -e "$red oops...algo deu errado...por favor tente novamente$none"
		echo
	fi
	rm -rf /tmp/233blog_v2ray.txt
}
get_v2ray_config_qr_link() {

	create_vmess_URL_config

	_load qr.sh
	_qr_create
}
get_v2ray_vmess_URL_link() {
	create_vmess_URL_config
	if [[ $v2ray_transport == 33 ]]; then
		local vmess="$(cat /etc/v2ray/vmess_qr.json)"
	else
		local vmess="vmess://$(cat /etc/v2ray/vmess_qr.json | base64 -w 0)"
	fi
	echo
	echo "---------- V2Ray vmess URL / V2RayNG v0.4.1+ / V2RayN v2.1+ / apenas para alguns clientes -------------"
	echo
	echo -e ${cyan}$vmess${none}
	echo
	echo -e "${yellow}Evite ficar emparedado. Recomenda-se JMS: ${cyan}https://getjms.com${none}"
	echo
	rm -rf /etc/v2ray/vmess_qr.json
}
other() {
	while :; do
		echo
		echo -e "$yellow 1. $noneInstalar BBR"
		echo
		read -p "$(echo -e "por favor escolha [${magenta}1$none]:")" _opt
		if [[ -z $_opt ]]; then
			error
		else
			case $_opt in
			1)
				install_bbr
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
}
install_bbr() {
	local test1=$(sed -n '/net.ipv4.tcp_congestion_control/p' /etc/sysctl.conf)
	local test2=$(sed -n '/net.core.default_qdisc/p' /etc/sysctl.conf)
	if [[ $test1 == "net.ipv4.tcp_congestion_control = bbr" && $test2 == "net.core.default_qdisc = fq" ]]; then
		echo
		echo -e "$green BBR já está habilitado... não é necessário instalar$none"
		echo
	else
		_load bbr.sh
		_try_enable_bbr
		[[ ! $enable_bbr ]] && bash <(curl -s -L https://github.com/teddysun/across/raw/master/bbr.sh)
	fi
}

update() {
	while :; do
		echo
		echo -e "$yellow 1. $none Atualize o programa principal do V2Ray"
		echo
		echo -e "$yellow 2. $none Atualize o script de gerenciamento do V2Ray"
		echo
		read -p "$(echo -e "por favor escolha [${magenta}1-2$none]:")" _opt
		if [[ -z $_opt ]]; then
			error
		else
			case $_opt in
			1)
				update_v2ray
				break
				;;
			2)
				update_v2ray.sh
				exit
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
}
update_v2ray() {
	_load download-v2ray.sh
	_update_v2ray_version
}
update_v2ray.sh() {
	if [[ $_test ]]; then
		local latest_version=$(curl -H 'Cache-Control: no-cache' -s -L "https://raw.githubusercontent.com/TelksBr/v2ray/master/v2ray.sh" | grep '_version' -m1 | cut -d\" -f2)
	else
		local latest_version=$(curl -H 'Cache-Control: no-cache' -s -L "https://raw.githubusercontent.com/233boy/v2ray/master/v2ray.sh" | grep '_version' -m1 | cut -d\" -f2)
	fi

	if [[ ! $latest_version ]]; then
		echo
		echo -e " $red Falha ao obter a versão mais recente do V2Ray!!!$none"
		echo
		echo -e " Por favor, tente executar o seguinte comando: $green echo 'nameserver 8.8.8.8' >/etc/resolv.conf $none"
		echo
		echo " então continue...."
		echo
		exit 1
	fi

	if [[ $latest_version == $_version ]]; then
		echo
		echo -e "$green nenhuma nova versão encontrada $none"
		echo
	else
		echo
		echo -e " $green Huh... Encontrei uma nova versão.... está desesperadamente atualizando....$none"
		echo
		cd /etc/v2ray/233boy/v2ray
		git pull
		cp -f /etc/v2ray/233boy/v2ray/v2ray.sh $_v2ray_sh
		chmod +x $_v2ray_sh
		echo
		echo -e "$green A atualização foi bem-sucedida... A versão atual do script de gerenciamento do V2Ray: ${cyan}$latest_version$none"
		echo
	fi

}
uninstall_v2ray() {
	_load uninstall.sh
}
config() {
	_load config.sh

	if [[ $v2ray_port == "80" ]]; then
		if [[ $cmd == "yum" ]]; then
			[[ $(pgrep "httpd") ]] && systemctl stop httpd >/dev/null 2>&1
			[[ $(command -v httpd) ]] && yum remove httpd -y >/dev/null 2>&1
		else
			[[ $(pgrep "apache2") ]] && service apache2 stop >/dev/null 2>&1
			[[ $(command -v apache2) ]] && apt-get remove apache2* -y >/dev/null 2>&1
		fi
	fi
	do_service restart v2ray
}
backup_config() {
	for keys in $*; do
		case $keys in
		v2ray_transport)
			sed -i "18s/=$v2ray_transport/=$v2ray_transport_opt/" $backup
			;;
		v2ray_port)
			sed -i "21s/=$v2ray_port/=$v2ray_port_opt/" $backup
			;;
		uuid)
			sed -i "24s/=$v2ray_id/=$uuid/" $backup
			;;
		alterId)
			sed -i "27s/=$alterId/=$new_alterId/" $backup
			;;
		v2ray_dynamicPort_start)
			sed -i "30s/=$v2ray_dynamicPort_start/=$v2ray_dynamic_port_start_input/" $backup
			;;
		v2ray_dynamicPort_end)
			sed -i "33s/=$v2ray_dynamicPort_end/=$v2ray_dynamic_port_end_input/" $backup
			;;
		domain)
			sed -i "36s/=$domain/=$new_domain/" $backup
			;;
		caddy)
			sed -i "39s/=/=true/" $backup
			;;
		+ss)
			sed -i "42s/=/=true/; 45s/=$ssport/=$new_ssport/; 48s/=$sspass/=$new_sspass/; 51s/=$ssciphers/=$new_ssciphers/" $backup
			;;
		-ss)
			sed -i "42s/=true/=/" $backup
			;;
		ssport)
			sed -i "45s/=$ssport/=$new_ssport/" $backup
			;;
		sspass)
			sed -i "48s/=$sspass/=$new_sspass/" $backup
			;;
		ssciphers)
			sed -i "51s/=$ssciphers/=$new_ssciphers/" $backup
			;;
		+ad)
			sed -i "54s/=/=true/" $backup
			;;
		-ad)
			sed -i "54s/=true/=/" $backup
			;;
		+path)
			sed -i "57s/=/=true/; 60s/=$path/=$new_path/; 63s#=$proxy_site#=$new_proxy_site#" $backup
			;;
		-path)
			sed -i "57s/=true/=/" $backup
			;;
		path)
			sed -i "60s/=$path/=$new_path/" $backup
			;;
		proxy_site)
			sed -i "63s#=$proxy_site#=$new_proxy_site#" $backup
			;;
		+socks)
			sed -i "66s/=/=true/; 69s/=$socks_port/=$new_socks_port/; 72s/=$socks_username/=$new_socks_username/; 75s/=$socks_userpass/=$new_socks_userpass/;" $backup
			;;
		-socks)
			sed -i "66s/=true/=/" $backup
			;;
		socks_port)
			sed -i "69s/=$socks_port/=$new_socks_port/" $backup
			;;
		socks_username)
			sed -i "72s/=$socks_username/=$new_socks_username/" $backup
			;;
		socks_userpass)
			sed -i "75s/=$socks_userpass/=$new_socks_userpass/" $backup
			;;
		+mtproto)
			sed -i "78s/=/=true/; 81s/=$mtproto_port/=$new_mtproto_port/; 84s/=$mtproto_secret/=$new_mtproto_secret/" $backup
			;;
		-mtproto)
			sed -i "78s/=true/=/" $backup
			;;
		mtproto_port)
			sed -i "81s/=$mtproto_port/=$new_mtproto_port/" $backup
			;;
		mtproto_secret)
			sed -i "84s/=$mtproto_secret/=$new_mtproto_secret/" $backup
			;;
		+bt)
			sed -i "87s/=/=true/" $backup
			;;
		-bt)
			sed -i "87s/=true/=/" $backup
			;;
		esac
	done

}

get_ip() {
	ip=$(curl -s https://ipinfo.io/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ip.sb/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ipify.org)
	[[ -z $ip ]] && ip=$(curl -s https://ip.seeip.org)
	[[ -z $ip ]] && ip=$(curl -s https://ifconfig.co/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && ip=$(curl -s icanhazip.com)
	[[ -z $ip ]] && ip=$(curl -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n" && exit
}

error() {

	echo -e "\n$red erro de entrada!$none\n"

}

pause() {

	read -rsp "$(echo -e "Pressione $green Digite $none para continuar... ou $red Ctrl + C $none para cancelar.")" -d $'\n'
	echo
}
do_service() {
	if [[ $systemd ]]; then
		systemctl $1 $2
	else
		service $2 $1
	fi
}
_help() {
	echo
	echo "........... Informações de ajuda do script de administração do V2Ray por @TALKERA ........."
	echo -e "
	${green}v2ray menu $none Gerenciar V2Ray (equivalente a entrada v2ray direta)

	${green}v2ray info $none Ver informações de configuração do V2Ray

	${green}v2ray config $none Modificar a configuração do V2Ray

	${green}v2ray link $none Gerar link do arquivo de configuração do cliente V2Ray

	${green}v2ray textlink $none Gerar link de informações de configuração do V2Ray

	${green}v2ray qr $none Gerar link de código QR de configuração do V2Ray

	${green}v2ray ss $none Modificar a configuração do Shadowsocks

	${green}v2ray ssinfo $none Ver informações de configuração do Shadowsocks

	${green}v2ray ssqr $none Gerar o link do código QR de configuração do Shadowsocks

	${green}v2ray status $none Veja o status de execução do V2Ray

	${green}v2ray start $none Iniciar V2Ray

	${green}v2ray stop $none Parar V2Ray

	${green}v2ray restart $none Reinicie o V2Ray

	${green}v2ray log $none Exibir log de execução do V2Ray

	${green}v2ray update $none Atualizar V2Ray

	${green}v2ray update.sh $none Atualizar scripts de gerenciamento do V2Ray

	${green}v2ray uninstall $none Desinstalar o V2Ray
"
}
menu() {
	clear
	while :; do
		echo
		echo "........... Script de administração do V2Ray $_version por 233v2.com ........."
		echo
		echo -e "## Versão do V2Ray: $cyan$v2ray_ver$none / status do V2Ray: $v2ray_status ##"
		echo
		echo "canal TG: https://t.me/ssh_t_project"
		echo
		echo "creditos: https://233v2.com/"
		echo
		echo -e "$yellow  1. $none Ver configuração do V2Ray"
		echo
		echo -e "$yellow  2. $none Modifique a configuração do V2Ray"
		echo
		echo -e "$yellow  3. $none Baixe a configuração do V2Ray / Gere o link de informações de configuração / Gere o link do código QR"
		echo
		echo -e "$yellow  4. $none Visualizar configuração do Shadowsocks / gerar links de código QR"
		echo
		echo -e "$yellow  5. $none Modifique a configuração do Shadowsocks"
		echo
		echo -e "$yellow  6. $none Visualizar configuração do MTProto/modificar configuração do MTProto"
		echo
		echo -e "$yellow  7. $none Ver configuração do Socks5 / Modificar configuração do Socks5"
		echo
		echo -e "$yellow  8. $none iniciar/parar/reiniciar/ver log"
		echo
		echo -e "$yellow  9. $none Atualizar V2Ray / Atualizar Script de Gerenciamento V2Ray"
		echo
		echo -e "$yellow 10. $none Desinstale o V2Ray"
		echo
		echo -e "$yellow 11. $none outro"
		echo
		echo -e "Lembrete... se você não quiser executar a opção... pressione $yellow Ctrl + C $none para sair"
		echo
		read -p "$(echo -e "Por favor, selecione um menu [${magenta}1-11$none]:")" choose
		if [[ -z $choose ]]; then
			exit 1
		else
			case $choose in
			1)
				view_v2ray_config_info
				break
				;;
			2)
				change_v2ray_config
				break
				;;
			3)
				download_v2ray_config
				break
				;;
			4)
				get_shadowsocks_config
				break
				;;
			5)
				change_shadowsocks_config
				break
				;;
			6)
				_load mtproto.sh
				_mtproto_main
				break
				;;
			7)
				_load socks.sh
				_socks_main
				break
				;;
			8)
				v2ray_service
				break
				;;
			9)
				update
				break
				;;
			10)
				uninstall_v2ray
				break
				;;
			11)
				other
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
}
args=$1
[ -z $1 ] && args="menu"
case $args in
menu)
	menu
	;;
i | info)
	view_v2ray_config_info
	;;
c | config)
	change_v2ray_config
	;;
l | link)
	get_v2ray_config_link
	;;
L | infolink)
	get_v2ray_config_info_link
	;;
q | qr)
	get_v2ray_config_qr_link
	;;
s | ss)
	change_shadowsocks_config
	;;
S | ssinfo)
	view_shadowsocks_config_info
	;;
Q | ssqr)
	get_shadowsocks_config_qr_link
	;;
socks)
	_load socks.sh
	_socks_main
	;;
socksinfo)
	_load socks.sh
	_view_socks_info
	;;
tg)
	_load mtproto.sh
	_mtproto_main
	;;
tginfo)
	_load mtproto.sh
	_view_mtproto_info
	;;
bt)
	_load bt.sh
	_ban_bt_main
	;;
status)
	echo
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy ]]; then
		echo -e " Status do V2Ray: $v2ray_status  /  Status do Caddy: $caddy_run_status"
	else
		echo -e " Status do V2Ray: $v2ray_status"
	fi
	echo
	;;
start)
	start_v2ray
	;;
stop)
	stop_v2ray
	;;
restart)
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy ]]; then
		do_service restart caddy
	fi
	restart_v2ray
	;;
reload)
	config
	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && [[ $caddy ]]; then
		caddy_config
	fi
	clear
	view_v2ray_config_info
	;;
time)
	date -s "$(curl -sI g.cn | grep Date | cut -d' ' -f3-6)Z"
	;;
log)
	view_v2ray_log
	;;
url | URL)
	get_v2ray_vmess_URL_link
	;;
u | update)
	update_v2ray
	;;
U | update.sh)
	update_v2ray.sh
	exit
	;;
un | uninstall)
	uninstall_v2ray
	;;
reinstall)
	uninstall_v2ray
	if [[ $is_uninstall_v2ray ]]; then
		cd
		cd - >/dev/null 2>&1
		bash <(curl -s -L https://git.io/v2ray.sh)
	fi
	;;
[aA][Ii] | [Dd])
	change_v2ray_alterId
	;;
[aA][Ii][aA][Ii] | [Dd][Dd] | aid)
	custom_uuid
	;;
reuuid)
	backup_config uuid
	v2ray_id=$uuid
	config
	clear
	view_v2ray_config_info
	# download_v2ray_config_ask
	;;
v | version)
	echo
	echo -e " Versão atual do V2Ray: ${green}$v2ray_ver$none / versão atual do script de administração do V2Ray: ${cyan}$_version$none"
	echo
	;;
bbr)
	other
	;;
help | *)
	_help
	;;
esac
