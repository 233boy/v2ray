_qr_create() {
	local vmess="vmess://$(cat /etc/v2ray/vmess_qr.json | base64 -w 0)"
	local link="https://233boy.github.io/tools/qr.html#${vmess}"
	echo
	echo "---------- V2Ray 二维码链接 适用于 V2RayNG v0.4.1+ / Kitsunebi -------------"
	echo
	echo -e ${cyan}$link${none}
	echo
	echo
	echo -e "$red 友情提醒: 请务必核对扫码结果 (V2RayNG 除外) $none"
	echo
	echo
	echo " V2Ray 客户端使用教程: https://v2ray6.com/post/4/"
	echo
	echo
	rm -rf /etc/v2ray/vmess_qr.json
}
_ss_qr() {
	local ss_link="ss://$(echo -n "${ssciphers}:${sspass}@${ip}:${ssport}" | base64 -w 0)#v2ray6.com_ss_${ip}"
	local link="https://233boy.github.io/tools/qr.html#${ss_link}"
	echo
	echo "---------- Shadowsocks 二维码链接 -------------"
	echo
	echo -e "$yellow 链接 = $cyan$link$none"
	echo
	echo -e " 温馨提示...$red Shadowsocks Win 4.0.6 $none客户端可能无法识别该二维码"
	echo
	echo
}
