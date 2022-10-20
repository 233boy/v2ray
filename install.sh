#!/bin/bash

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

# Root
[[ $(id -u) != 0 ]] && echo -e "\n opa... por favor use ${red}root ${none}execução do usuário ${yellow}~(^_^) ${none}\n" && exit 1

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

# 笨笨的检测方法
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

	if [[ $(command -v yum) ]]; then

		cmd="yum"

	fi

else

	echo -e " 
	Haha... este ${red}script${none} não suporta o seu sistema. ${yellow}(-_-) ${none}

	Nota: Suporta apenas sistemas Ubuntu 16+ / Debian 8+ / CentOS 7+
	" && exit 1

fi

uuid=$(cat /proc/sys/kernel/random/uuid)
old_id="e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
v2ray_server_config="/etc/v2ray/config.json"
v2ray_client_config="/etc/v2ray/233blog_v2ray_config.json"
backup="/etc/v2ray/233blog_v2ray_backup.conf"
_v2ray_sh="/usr/local/sbin/v2ray"
systemd=true
# _test=true

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
	VLESS_WebSocket_TLS
)

ciphers=(
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
	timedatectl set-timezone America/Sao_Paulo
	timedatectl set-ntp true
	echo "Seu host foi definido para o fuso horário da America/Sao_Paulo e sincronizado automaticamente com o systemd-timesyncd."
	echo

	if [[ $IS_OPENVZ ]]; then
		echo
		echo -e "Seu ambiente de host é ${yellow}Openvz${none} , é recomendável usar a série de protocolos ${yellow}v2ray mkcp${none}."
        echo -e "Observação: a hora do sistema ${yellow}Openvz${none} não pode ser sincronizada pelo controle do programa in-vm."
        echo -e "Se a hora do host diferir do host real em ${yellow} por mais de 90 segundos ${none}, v2ray não poderá se comunicar normalmente. Por favor, envie um ticket para entrar em contato com o host vps para ajuste."
	fi
}

_sys_time() {
	echo -e "\n hora do host:${yellow}"
	timedatectl status | sed -n '1p;4p'
	echo -e "${none}"
	[[ $IS_OPENV ]] && pause
}
v2ray_config() {
	# clear
	echo
	while :; do
		echo -e "Por favor, selecione o protocolo de transporte "$yellow"V2Ray"$none" [${magenta}1-${#transport[*]}$none]"
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
		read -p "$(echo -e "(Protocolo padrão: ${cyan}TCP$none)"):" v2ray_transport
		[ -z "$v2ray_transport" ] && v2ray_transport=1
		case $v2ray_transport in
		[1-9] | [1-2][0-9] | 3[0-3])
			echo
			echo
			echo -e "$yellow Protocolo de transporte V2Ray = $cyan${transport[$v2ray_transport - 1]}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
	v2ray_port_config
}
v2ray_port_config() {
	case $v2ray_transport in
	4 | 5 | 33)
		tls_config
		;;
	*)
		local random=$(shuf -i20001-65535 -n1)
		while :; do
			echo -e "Por favor, insira "$yellow"V2Ray"$none" porta ["$magenta"1-65535"$none"]"
			read -p "$(echo -e "(porta padrão: ${cyan}${random}$none):")" v2ray_port
			[ -z "$v2ray_port" ] && v2ray_port=$random
			case $v2ray_port in
			[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
				echo
				echo
				echo -e "$yellow Porta V2Ray = $cyan$v2ray_port$none"
				echo "----------------------------------------------------------------"
				echo
				break
				;;
			*)
				error
				;;
			esac
		done
		if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
			v2ray_dynamic_port_start
		fi
		;;
	esac
}

v2ray_dynamic_port_start() {

	while :; do
		echo -e "Por favor, digite "$yellow" V2Ray dynamic port start "$none" range ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Porta inicial padrão: ${cyan}10000$none):")" v2ray_dynamic_port_start_input
		[ -z $v2ray_dynamic_port_start_input ] && v2ray_dynamic_port_start_input=10000
		case $v2ray_dynamic_port_start_input in
		$v2ray_port)
			echo
			echo " Não pode ser o mesmo que a porta V2Ray...."
			echo
			echo -e " Porta V2Ray atual：${cyan}$v2ray_port${none}"
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow A porta dinâmica V2Ray é iniciada = $cyan$v2ray_dynamic_port_start_input$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac

	done

	if [[ $v2ray_dynamic_port_start_input -lt $v2ray_port ]]; then
		lt_v2ray_port=true
	fi

	v2ray_dynamic_port_end
}
v2ray_dynamic_port_end() {

	while :; do
		echo -e "Por favor, insira "$yellow" V2Ray final da porta dinâmica "$none" intervalo ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Porta final padrão: ${cyan}20000$none):")" v2ray_dynamic_port_end_input
		[ -z $v2ray_dynamic_port_end_input ] && v2ray_dynamic_port_end_input=20000
		case $v2ray_dynamic_port_end_input in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])

			if [[ $v2ray_dynamic_port_end_input -le $v2ray_dynamic_port_start_input ]]; then
				echo
				echo "Não pode ser menor ou igual ao intervalo de início da porta dinâmica V2Ray"
				echo
				echo -e "A porta dinâmica atual do V2Ray inicia: ${cyan}$v2ray_dynamic_port_start_input${none}"
				error
			elif [ $lt_v2ray_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $v2ray_port ]]; then
				echo
				echo " O intervalo de extremidade da porta dinâmica V2Ray não pode incluir portas V2Ray..."
				echo
				echo -e " Porta V2Ray atual: ${cyan}$v2ray_port${none}"
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

tls_config() {

	echo
	local random=$(shuf -i20001-65535 -n1)
	while :; do
		echo -e "Por favor, insira a porta "$yellow"V2Ray"$none" ["$magenta"1-65535"$none"], não é possível selecionar a porta "$magenta"80"$none" ou "$magenta"443"$none""
		read -p "$(echo -e "(porta padrão: ${cyan}${random}$none):")" v2ray_port
		[ -z "$v2ray_port" ] && v2ray_port=$random
		case $v2ray_port in
		80)
			echo
			echo " ... eles disseram que você não pode escolher a porta 80 ..."
			error
			;;
		443)
			echo
			echo ".. eles disseram que você não pode mais escolher a porta 443..."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow Porta V2Ray = $cyan$v2ray_port$none"
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
		echo -e "Por favor, digite um nome de domínio ${magenta}correto${none}, deve estar correto, não! Sim! Errado! Errado!"
		read -p "(Por exemplo: 233blog.com): " domain
		[ -z "$domain" ] && error && continue
		echo
		echo
		echo -e "$yellow seu nome de domínio = $cyan$domain$none"
		echo "----------------------------------------------------------------"
		break
	done
	get_ip
	echo
	echo
	echo -e "$yellow por favor $magenta$domain$none $yellow resolver: $cyan$ip$none"
	echo
	echo -e "$yellow por favor $magenta$domain$none $yellow resolver: $cyan$ip$none"
	echo
	echo -e "$yellow por favor $magenta$domain$none $yellow resolver: $cyan$ip$none"
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
				echo -e "$yellow DNS = ${cyan}Tenho certeza que já foi analisado$none"
				echo "----------------------------------------------------------------"
				echo
				break
			else
				error
			fi
		fi

	done

	if [[ $v2ray_transport -eq 4 ]]; then
		auto_tls_config
	else
		caddy=true
		install_caddy_info="ativado"
	fi

	if [[ $caddy ]]; then
		path_config_ask
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

		read -p "$(echo -e "(Se configurar automaticamente TLS: [${magenta}Y/N$none]):") " auto_install_caddy
		if [[ -z "$auto_install_caddy" ]]; then
			error
		else
			if [[ "$auto_install_caddy" == [Yy] ]]; then
				caddy=true
				install_caddy_info="ativado"
				echo
				echo
				echo -e "$yellow Configuração TLS automática  = $cyan$install_caddy_info$none"
				echo "----------------------------------------------------------------"
				echo
				break
			elif [[ "$auto_install_caddy" == [Nn] ]]; then
				install_caddy_info="desativado"
				echo
				echo
				echo -e "$yellow Configurar TLS automaticamente = $cyan$install_caddy_info$none"
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
		echo -e "Se habilitar o mascaramento do site e o desvio de caminho [${magenta}Y/N$none]"
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
		echo -e "Por favor, digite o caminho que você deseja que ${magenta} use para desviar $none, como /233blog, então apenas digite 233blog."
		read -p "$(echo -e "(padrão: [${cyan}233blog$none]):")" path
		[[ -z $path ]] && path="233blog"

		case $path in
		*[/$]*)
			echo
			echo -e " Porque este script é muito picante.. então o caminho do desvio não pode conter os dois símbolos $red / $none ou $red $ $none ...."
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow caminho de desvio = ${cyan}/${path}$none"
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
		echo -e "Por favor, insira ${magenta} um $none ${cyan} URL$none válido para usar como $none para sites ${cyan}, por exemplo https://liyafly.com"
		echo -e "Exemplo... seu nome de domínio atual é $green$domain$none , o URL falso é https://liyafly.com"
		echo -e "Então, quando você abre seu domínio... o conteúdo exibido é o conteúdo de https://liyafly.com"
		echo -e "Na verdade, é uma anti-geração... apenas entenda..."
		echo -e "Se você não conseguir disfarçar com sucesso... você pode usar a configuração v2ray para modificar o URL disfarçado"
		read -p "$(echo -e "(padrão: [${cyan}https://liyafly.com$none]):")" proxy_site
		[[ -z $proxy_site ]] && proxy_site="https://liyafly.com"

		case $proxy_site in
		*[#$]*)
			echo
			echo -e " Como esse script é muito picante, o URL falso não pode conter os símbolos $red # $none ou $red $ $none. …"
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow URL falso = ${cyan}${proxy_site}$none"
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
		echo -e "Se habilitar o bloqueio de anúncios (afetará o desempenho) [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):")" blocked_ad
		[[ -z $blocked_ad ]] && blocked_ad="n"

		case $blocked_ad in
		Y | y)
			blocked_ad_info="ativado"
			ban_ad=true
			echo
			echo
			echo -e "bloqueador de anúncios $yellow = $cyan em $none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		N | n)
			blocked_ad_info="desativado"
			echo
			echo
			echo -e "$yellow adblock = $cyan off $none"
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
		echo -e "Quer configurar ${yellow}Shadowsocks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(padrão [${cyan}N$none]):") " install_shadowsocks
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
		echo -e "Por favor, insira a porta "$yellow"Shadowsocks"$none" ["$magenta"1-65535"$none"], não pode ser a mesma que a porta "$yellow"V2Ray"$none""
		read -p "$(echo -e "(porta padrão: ${cyan}${random}$none):") " ssport
		[ -z "$ssport" ] && ssport=$random
		case $ssport in
		$v2ray_port)
			echo
			echo " Não pode ser o mesmo que a porta V2Ray...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $ssport == "80" ]] || [[ $tls && $ssport == "443" ]]; then
				echo
				echo -e "Porque você selecionou o transporte "$green"WebSocket + TLS $none ou $green HTTP/2"$none"."
				echo
				echo -e "Assim, as portas "$magenta"80"$none" ou "$magenta"443"$none" não podem ser selecionadas"
				error
			elif [[ $v2ray_dynamic_port_start_input == $ssport || $v2ray_dynamic_port_end_input == $ssport ]]; then
				local multi_port="${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}"
				echo
				echo " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：$multi_port"
				error
			elif [[ $v2ray_dynamic_port_start_input -lt $ssport && $ssport -le $v2ray_dynamic_port_end_input ]]; then
				local multi_port="${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}"
				echo
				echo " Desculpe, esta porta está em conflito com a porta dinâmica V2Ray, o intervalo de porta dinâmica V2Ray atual é：$multi_port"
				error
			else
				echo
				echo
				echo -e "$yellow Porta Shadowsocks = $cyan$ssport$none"
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
		echo -e "Por favor, digite "$yellow"Shadowsocks"$none"password"
		read -p "$(echo -e "(senha padrão: ${cyan}233blog.com$none)"): " sspass
		[ -z "$sspass" ] && sspass="233blog.com"
		case $sspass in
		*[/$]*)
			echo
			echo -e " Como este script é muito picante, a senha não pode conter os dois símbolos $red / $none ou $red $ $none. ..."
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow Senha do Shadowsocks = $cyan$sspass$none"
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
		echo -e "Por favor, selecione o protocolo de criptografia "$yellow"Shadowsocks"$none" [${magenta}1-${#ciphers[*]}$none]"
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
			ssciphers=${ciphers[$ssciphers_opt - 1]}
			echo
			echo
			echo -e "$yellow Protocolo de criptografia Shadowsocks = $cyan${ssciphers}$none"
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
	echo " ....Pronto para instalar..Veja se a configuração está correta..."
	echo
	echo "---------- Informações de instalação -------------"
	echo
	echo -e "$yellow Protocolo de transporte V2Ray = $cyan${transport[$v2ray_transport - 1]}$none"

	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]]; then
		echo
		echo -e "$yellow Porta V2Ray = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow seu nome de domínio = $cyan$domain$none"
		echo
		echo -e "$yellow DNS = ${cyan}!!!analisado!!!$none"
		echo
		echo -e "$yellow Configurar TLS automaticamente = $cyan$install_caddy_info$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow bloqueio de anúncios = $cyan$blocked_ad_info$none"
		fi
		if [[ $is_path ]]; then
			echo
			echo -e "$yellow desvio de caminho = ${cyan}/${path}$none"
		fi
	elif [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		echo
		echo -e "$yellow Porta V2Ray = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow Faixa de portas dinâmicas V2Ray = $cyan${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow bloqueio de anúncios = $cyan$blocked_ad_info$none"
		fi
	else
		echo
		echo -e "$yellow Porta V2Ray = $cyan$v2ray_port$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow bloqueio de anúncios = $cyan$blocked_ad_info$none"
		fi
	fi
	if [ $shadowsocks ]; then
		echo
		echo -e "$yellow Porta Shadowsocks = $cyan$ssport$none"
		echo
		echo -e "$yellow Shadowsocks 密码 = $cyan$sspass$none"
		echo
		echo -e "$yellow Protocolo de criptografia Shadowsocks = $cyan${ssciphers}$none"
	else
		echo
		echo -e "$yellow Se deve configurar Shadowsocks = ${cyan}Não configurado${none}"
	fi
	echo
	echo "---------- FIM -------------"
	echo
	pause
	echo
}

domain_check() {
	# if [[ $cmd == "yum" ]]; then
	# 	yum install bind-utils -y
	# else
	# 	$cmd install dnsutils -y
	# fi
	# test_domain=$(dig $domain +short)
	# test_domain=$(ping $domain -c 1 -4 | grep -oE -m1 "([0-9]{1,3}\.){3}[0-9]{1,3}")
	# test_domain=$(wget -qO- --header='accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$domain&type=A" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -1)
	test_domain=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$domain&type=A" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -1)
	if [[ $test_domain != $ip ]]; then
		echo
		echo -e "$red Detectar erros de resolução de nomes de domínio....$none"
		echo
		echo -e "Seu domínio: $yellow$domain$none não foi resolvido para: $cyan$ip$none"
		echo
		echo -e " Seu domínio atualmente resolve para: $cyan$test_domain$none"
		echo
		echo "Observação... se o seu domínio for resolvido usando Cloudflare.. clique nesse ícone em Status.. deixe-o acinzentado"
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

	# systemctl restart caddy
	do_service restart caddy
}

install_v2ray() {
	$cmd update -y
	if [[ $cmd == "apt-get" ]]; then
		$cmd install -y lrzsz git zip unzip curl wget qrencode libcap2-bin dbus
	else
		# $cmd install -y lrzsz git zip unzip curl wget qrencode libcap iptables-services
		$cmd install -y lrzsz git zip unzip curl wget qrencode libcap
	fi
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	[ -d /etc/v2ray ] && rm -rf /etc/v2ray
	# date -s "$(curl -sI g.cn | grep Date | cut -d' ' -f3-6)Z"
	_sys_timezone
	_sys_time

	if [[ $local_install ]]; then
		if [[ ! -d $(pwd)/config ]]; then
			echo
			echo -e "$red Ops... falha na instalação... $none"
			echo
			echo -e "Certifique-se de ter o script de instalação e gerenciamento de um clique completo do V2Ray carregado de 233v2.com para o diretório ${green}$(pwd) $none atual"
			echo
			exit 1
		fi
		mkdir -p /etc/v2ray/233boy/v2ray
		cp -rf $(pwd)/* /etc/v2ray/233boy/v2ray
	else
		pushd /tmp
		git clone https://github.com/TelksBr/v2ray.git -b "$_gitbranch" /etc/v2ray/233boy/v2ray --depth=1
		popd

	fi

	if [[ ! -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo -e "$red Ops...Erro ao clonar repositório de script...$none"
		echo
		echo -e " Lembrete..... Por favor, tente instalar o Git sozinho: ${green}$cmd install -y git $none e depois instale este script"
		echo
		exit 1
	fi

	# download v2ray file then install
	_load download-v2ray.sh
	_download_v2ray_file
	_install_v2ray_service
	_mkdir_dir
}

config() {
	cp -f /etc/v2ray/233boy/v2ray/config/backup.conf $backup
	cp -f /etc/v2ray/233boy/v2ray/v2ray.sh $_v2ray_sh
	chmod +x $_v2ray_sh

	v2ray_id=$uuid
	alterId=0
	ban_bt=true
	if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		v2ray_dynamicPort_start=${v2ray_dynamic_port_start_input}
		v2ray_dynamicPort_end=${v2ray_dynamic_port_end_input}
	fi
	_load config.sh

	# if [[ $cmd == "apt-get" ]]; then
	# 	cat >/etc/network/if-pre-up.d/iptables <<-EOF
	# 		#!/bin/sh
	# 		/sbin/iptables-restore < /etc/iptables.rules.v4
	# 		/sbin/ip6tables-restore < /etc/iptables.rules.v6
	# 	EOF
	# 	chmod +x /etc/network/if-pre-up.d/iptables
	# 	# else
	# 	# 	[ $(pgrep "firewall") ] && systemctl stop firewalld
	# 	# 	systemctl mask firewalld
	# 	# 	systemctl disable firewalld
	# 	# 	systemctl enable iptables
	# 	# 	systemctl enable ip6tables
	# 	# 	systemctl start iptables
	# 	# 	systemctl start ip6tables
	# fi

	# systemctl restart v2ray
	do_service restart v2ray
	backup_config

}

backup_config() {
	sed -i "18s/=1/=$v2ray_transport/; 21s/=2333/=$v2ray_port/; 24s/=$old_id/=$uuid/" $backup
	if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		sed -i "30s/=10000/=$v2ray_dynamic_port_start_input/; 33s/=20000/=$v2ray_dynamic_port_end_input/" $backup
	fi
	if [[ $shadowsocks ]]; then
		sed -i "42s/=/=true/; 45s/=6666/=$ssport/; 48s/=233blog.com/=$sspass/; 51s/=chacha20-ietf/=$ssciphers/" $backup
	fi
	[[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && sed -i "36s/=233blog.com/=$domain/" $backup
	[[ $caddy ]] && sed -i "39s/=/=true/" $backup
	[[ $ban_ad ]] && sed -i "54s/=/=true/" $backup
	if [[ $is_path ]]; then
		sed -i "57s/=/=true/; 60s/=233blog/=$path/" $backup
		sed -i "63s#=https://liyafly.com#=$proxy_site#" $backup
	fi
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

	echo -e "\n$red erro de entrada! $nenhum\n"

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
show_config_info() {
	clear
	_load v2ray-info.sh
	_v2_args
	_v2_info
	_load ss-info.sh

}

install() {
	if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo "Grande cara... você já instalou o V2Ray... não precisa reinstalar"
		echo
		echo -e " $yellow type ${cyan}v2ray${none} $yellow para gerenciar V2Ray${none}"
		echo
		exit 1
	elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo " Se você precisar continuar a instalação, desinstale a versão antiga primeiro"
		echo
		echo -e " $yellow digite ${cyan}v2ray uninstall${none} $yellow irá desinstalar ${none}"
		echo
		exit 1
	fi
	v2ray_config
	blocked_hosts
	shadowsocks_config
	install_info
	# [[ $caddy ]] && domain_check
	install_v2ray
	if [[ $caddy || $v2ray_port == "80" ]]; then
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
	# _load bbr.sh
	# _try_enable_bbr

	get_ip
	config
	show_config_info
}
uninstall() {

	if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
		. $backup
		if [[ $mark ]]; then
			_load uninstall.sh
		else
			echo
			echo -e " $amarelo Digite ${cyan}v2ray uninstall${none} $yellow para desinstalar ${none}"
			echo
		fi

	elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo -e "$yellow digite ${cyan}v2ray uninstall${none} $yellow irá desinstalar ${none}"
		echo
	else
		echo -e "
		$red Peitos grandes... Parece que você instalou o V2Ray.... Desinstale um pau...$none

		Observações...Suporta apenas a desinstalação e uso do script de instalação de um clique do V2Ray fornecido por mim (233v2.com)
		" && exit 1
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
	echo -e " O parâmetro que você digitou <$red $args $none>... que diabos é isso... o script não reconhece, uau"
	echo
	echo -e " Este script de frango picante suporta apenas o parâmetro de entrada $green local / online $none"
	echo
	echo -e " Digite $yellow local $none para usar a instalação local"
	echo
	echo -e " Digite $yellow online $none para usar a instalação online (padrão)"
	echo
	exit 1
	;;
esac

clear
while :; do
	echo
	echo "...........Script de instalação e script de gerenciamento V2Ray edit by @TALKERA .........."
	echo
	echo "MEU CANAL NO TELEEGRAM: t.me/ssh_t_roject"
	echo
	echo "creditos: https://233v2.com"
	echo
	echo " 1. Instalar"
	echo
	echo " 2. Desinstalar"
	echo
	if [[ $local_install ]]; then
		echo -e "$yellow Lembrete.. A instalação local está habilitada..$none"
		echo
	fi
	read -p "$(echo -e "por favor escolha [${magenta}1-2$none]:")" choose
	case $choose in
	1)
		install
		break
		;;
	2)
		uninstall
		break
		;;
	*)
		error
		;;
	esac
done
