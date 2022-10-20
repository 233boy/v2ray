_qr_create() {
	if [[ $v2ray_transport == 33 ]]; then
		local vmess="$(cat /etc/v2ray/vmess_qr.json)"
	else
		local vmess="vmess://$(cat /etc/v2ray/vmess_qr.json | base64 -w 0)"
	fi
	local link="https://233boy.github.io/tools/qr.html#${vmess}"
	echo
	echo "---------- V2Ray 二维码 -------------"
	echo
	qrencode -s 1 -m 1 -t ansi "${vmess}"
	echo
	echo "Se o código QR não puder ser exibido corretamente, use o link abaixo para gerar o código QR:"
	echo -e ${cyan}$link${none}
	echo
	echo
	echo -e "$red Lembrete amigável: Certifique-se de verificar o resultado da verificação (exceto V2RayNG)$none"
	echo
	echo
	echo "Tutorial do cliente V2Ray: https://233v2.com/post/4/"
	echo
	echo
	rm -rf /etc/v2ray/vmess_qr.json
}
_ss_qr() {
	local ss_link="ss://$(echo -n "${ssciphers}:${sspass}@${ip}:${ssport}" | base64 -w 0)#233v2.com_ss_${ip}"
	local link="https://233boy.github.io/tools/qr.html#${ss_link}"
	echo
	echo "----------  Código QR Shadowsocks  -------------"
	echo
	qrencode -s 1 -m 1 -t ansi "${ss_link}"
	echo
	echo "Se o código QR não puder ser exibido corretamente, use o link abaixo para gerar o código QR:"
	echo -e ${cyan}$link${none}
	echo
	echo -e " Lembrete...$red Shadowsocks Win 4.0.6 $none cliente pode não reconhecer o código QR"
	echo
	echo
}
