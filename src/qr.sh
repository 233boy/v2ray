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
	echo "如果无法正常显示二维码，请使用下面的链接来生成二维码:"
	echo -e ${cyan}$link${none}
	echo
	echo
	echo -e "$red 友情提醒: 请务必核对扫码结果 (V2RayNG 除外) $none"
	echo
	echo
	echo " V2Ray 客户端使用教程: https://233v2.com/post/4/"
	echo
	echo
	rm -rf /etc/v2ray/vmess_qr.json
}
_ss_qr() {
	local ss_link="ss://$(echo -n "${ssciphers}:${sspass}@${ip}:${ssport}" | base64 -w 0)#233v2.com_ss_${ip}"
	local link="https://233boy.github.io/tools/qr.html#${ss_link}"
	echo
	echo "---------- Shadowsocks 二维码 -------------"
	echo
	qrencode -s 1 -m 1 -t ansi "${ss_link}"
	echo
	echo "如果无法正常显示二维码，请使用下面的链接来生成二维码:"
	echo -e ${cyan}$link${none}
	echo
	echo -e " 温馨提示...$red Shadowsocks Win 4.0.6 $none客户端可能无法识别该二维码"
	echo
	echo
}
