_load status.sh
_get_status
_qr_create() {
	local vmess="vmess://$(cat /etc/v2ray/vmess_qr.json | base64 -w 0)"
	local link="https://233boy.github.io/tools/qr.html#${vmess}"
	echo
	echo "---------- V2Ray 二维码链接 适用于 V2RayNG v0.4.1+ / Kitsunebi -------------"
	echo
	echo
	_cyan "$link"
	echo
	echo
	_yellow "没看到二维码啊???用浏览器打开上面的链接啊...."
	echo
	echo
	_red "友情提醒: 请务必核对扫码结果 (V2RayNG 除外)"
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
	echo "---------- Shadowsocks 二维码链接 -------------"
	echo
	echo
	_cyan "$link"
	echo
	echo
	_yellow "没看到二维码啊???用浏览器打开上面的链接啊...."
	echo
	echo
	_red " 温馨提示... Shadowsocks Win 4.0.6 客户端可能无法识别该二维码"
	echo
	echo
}
