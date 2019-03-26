_load status.sh
_get_status
[[ -z $ip ]] && get_ip
if [[ $shadowsocks ]]; then
	#local ss="ss://$(echo -n "${ssciphers}:${sspass}@${ip}:${ssport}" | base64 -w 0)#${_site}_ss_${ip}"
	local cipherstr=$(echo -n ${ssciphers}:${sspass} | base64 -w 0 | sed 's/=*$//')
	local clientopt=$(echo ${ssrayopt} | sed 's/server;\?//')
	local opt="?plugin=$(echo "v2ray-plugin;${clientopt}" | sed 's/=/%3d/g; s/;/%3b/g;')"

	local ss="ss://${cipherstr}@${ip}:${ssport}#${_site}_ss_${ip}"
	local ssplugin="ss://${cipherstr}@${ssray_domain}:${ssrayport}/${opt}#${_site}_ssv2_${ssray_domain}"

	echo
	echo "---------- Shadowsocks 配置信息 -------------"
	echo
	echo -e "$yellow 服务器地址 = $cyan${ip}$none"
	echo
	if [[ $v6ip ]]; then
		local ssv6="ss://${cipherstr}@[${v6ip}]:${ssport}#${_site}_ss_${ip}"
		echo -e "$yellow 服务器IPv6地址 = $cyan${v6ip}$none"
		echo
	fi
	echo -e "$yellow 服务器端口 = $cyan$ssport$none"
	echo
	echo -e "$yellow 密码 = $cyan$sspass$none"
	echo
	echo -e "$yellow 加密协议 = $cyan${ssciphers}$none"
	echo
	echo -e "$yellow SS 链接 = ${cyan}$ss$none"
	echo
	if [[ $ssv6 ]]; then
		echo -e "$yellow SS IPv6 链接 = ${cyan}$ssv6$none"
		echo
	fi
	if [[ $ssray ]]; then
		echo -e "$yellow SS + V2ray - Plugin 地址 = ${cyan}${ssray_domain}$none"
		echo
		echo -e "$yellow SS + V2ray - Plugin 端口 = ${cyan}${ssrayport}$none"
		echo
		echo -e "$yellow SS + V2ray - Plugin 参数 = ${cyan}${clientopt}$none"
		echo
		echo -e "$yellow SS + V2ray - Plugin 链接 = ${cyan}${ssplugin}$none"
		echo
	fi
	echo -e "提示: 输入$cyan v2ray ssqr $none可生成 Shadowsocks 二维码链接"
	echo
fi
