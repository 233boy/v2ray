[[ -z $ip ]] && get_ip
if [[ $shadowsocks ]]; then
	#local ss="ss://$(echo -n "${ssciphers}:${sspass}@${ip}:${ssport}" | base64 -w 0)#v2ray6.com_ss_${ip}"
	local cipherstr=$(echo -n ${ssciphers}:${sspass} | base64 -w 0 | sed 's/=*$//')
	local clientopt=$(echo ${ssrayopt} | sed 's/server;\?//')
	local opt="?plugin=$(echo "v2ray-plugin;${clientopt}" | sed 's/=/%3d/g; s/;/%3b/g;')"

	local ss="ss://${cipherstr}@${ip}:${ssport}#v2ray6.com_ss_${ip}"
	local ssplugin="ss://${cipherstr}@${ssray_domain}:${ssrayport}/${opt}#v2ray6.com_ssv2_${ssray_domain}"

	echo
	echo "---------- Shadowsocks 配置信息 -------------"
	echo
	echo -e "$yellow 服务器地址 = $cyan${ip}$none"
	echo
	echo -e "$yellow 服务器端口 = $cyan$ssport$none"
	echo
	echo -e "$yellow 密码 = $cyan$sspass$none"
	echo
	echo -e "$yellow 加密协议 = $cyan${ssciphers}$none"
	echo
	echo -e "$yellow SS 链接 = ${cyan}$ss$none"
	echo
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
