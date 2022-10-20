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
	3 | 4 | 20 | 33)
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
	echo "---------- Informações de configuração do V2Ray -------------"
	if [[ $v2ray_transport == [45] ]]; then
		if [[ ! $caddy ]]; then
			echo
			echo -e " $red aviso! $none$yellow Configure o TLS você mesmo...tutorial: https://233v2.com/post/3/$none"
		fi
		echo
		echo -e "$yellow Endereço (Address) = $cyan${domain}$none"
		echo
		echo -e "$yellow porta (Port) = ${cyan}443${none}"
		echo
		echo -e "$yellow ID do usuário (User ID / UUID) = $cyan${v2ray_id}$none"
		echo
		echo -e "$yellow ID extra (Alter Id) = ${cyan}${alterId}${none}"
		echo
		echo -e "$yellow Protocolo de Transferência (Network) = ${cyan}${net}$none"
		echo
		echo -e "$yellow tipo de camuflagem (header type) = ${cyan}${header}$none"
		echo
		echo -e "$yellow nome de domínio falso (host) = ${cyan}${domain}$none"
		echo
		echo -e "$yellow caminho (path) = ${cyan}${_path}$none"
		echo
		echo -e "$yellow segurança de transporte subjacente (TLS) = ${cyan}tls$none"
		echo
		if [[ $ban_ad ]]; then
			echo " Observação: o bloqueio de anúncios está ativado."
			echo
		fi
	elif [[ $v2ray_transport == 33 ]]; then
		echo
		echo -e "$green ---DICA..ESTA É A CONFIGURAÇÃO DO SERVIDOR VLESS--- $none"
		echo
		echo -e "$yellow Endereço (Address) = $cyan${domain}$none"
		echo
		echo -e "$yellow porta (Port) = ${cyan}443${none}"
		echo
		echo -e "$yellow ID do usuário (User ID / UUID) = $cyan${v2ray_id}$none"
		echo
		echo -e "$yellow Controle de fluxo (Flow) = ${cyan}空${none}"
		echo
		echo -e "$yellow criptografia (Encryption) = ${cyan}none${none}"
		echo
		echo -e "$yellow Protocolo de Transferência (Network) = ${cyan}${net}$none"
		echo
		echo -e "$yellow tipo de camuflagem (header type) = ${cyan}${header}$none"
		echo
		echo -e "$yellow nome de domínio falso (host) = ${cyan}${domain}$none"
		echo
		echo -e "$yellow caminho (path) = ${cyan}${_path}$none"
		echo
		echo -e "$yellow segurança de transporte subjacente (TLS) = ${cyan}tls$none"
		echo
		if [[ $ban_ad ]]; then
			echo " Observação: o bloqueio de anúncios está ativado.."
			echo
		fi
	else
		echo
		echo -e "$yellow Endereço (Address) = $cyan${ip}$none"
		echo
		echo -e "$yellow porta (Port) = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow ID do usuário (User ID / UUID) = $cyan${v2ray_id}$none"
		echo
		echo -e "$yellow ID extra (Alter Id) = ${cyan}${alterId}${none}"
		echo
		echo -e "$yellow Protocolo de Transferência (Network) = ${cyan}${net}$none"
		echo
		echo -e "$yellow tipo de camuflagem (header type) = ${cyan}${header}$none"
		echo
	fi
	if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]] && [[ $ban_ad ]]; then
		echo " Observação: portas dinâmicas ativadas...Bloqueio de anúncios ativado..."
		echo
	elif [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		echo " Nota: As portas dinâmicas estão habilitadas..."
		echo
	elif [[ $ban_ad ]]; then
		echo "Observação: o bloqueio de anúncios está ativado..."
		echo
	fi
	echo "---------- FIM -------------"
	echo
	echo "Tutorial do cliente V2Ray: https://233v2.com/post/4/"
	echo
	echo -e "Dica: digite $cyan v2ray url $none para gerar um link de URL vmess / digite $cyan v2ray qr $none para gerar um link de código QR"
	echo
	echo -e "${yellow}Livre de ser emparedado. JMS é recomendado: ${cyan}https://getjms.com${none}"
	echo
}
