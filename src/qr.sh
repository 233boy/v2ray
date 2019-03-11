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
