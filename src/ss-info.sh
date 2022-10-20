[[ -z $ip ]] && get_ip
if [[ $shadowsocks ]]; then
	local ss="ss://$(echo -n "${ssciphers}:${sspass}@${ip}:${ssport}" | base64 -w 0)#233v2.com_ss_${ip}"
	echo
	echo "---------- Informações de configuração do Shadowsocks -------------"
	echo
	echo -e "$yellow endereço do servidor = $cyan${ip}$none"
	echo
	echo -e "$yellow porta do servidor = $cyan$ssport$none"
	echo
	echo -e "$yellow senha = $cyan$sspass$none"
	echo
	echo -e "$yellow protocolo de criptografia = $cyan${ssciphers}$none"
	echo
	echo -e "$yellow link SS= ${cyan}$ss$none"
	echo
	echo -e " Nota: $red Shadowsocks Win 4.0.6 $none cliente pode não reconhecer o link SS"
	echo
	echo -e "Dica: digite $cyan v2ray ssqr $none para gerar um link de código QR do Shadowsocks"
	echo
	echo -e "${yellow}Livre de ser emparedado. JMS é recomendado: ${cyan}https://getjms.com${none}"
	echo
fi
