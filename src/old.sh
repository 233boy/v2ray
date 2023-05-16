is_old_list=(
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

# del old file
del_old_file() {
	# old sh bin
	_v2ray_sh="/usr/local/sbin/v2ray"
	rm -rf $_v2ray_sh $is_old_conf $is_old_dir $is_core_dir/233blog_v2ray_config.json /usr/bin/v2ray
	# del alias
	sed -i "#$_v2ray_sh#d" /root/.bashrc
	exit
}

# read old config
. $is_old_conf
is_old=${is_old_list[$v2ray_transport - 1]}
case $v2ray_transport in
3 | 20)
	is_old_use=
	;;
4)
	is_old_use=ws
	;;
5)
	is_old_use=h2
	;;
33)
	is_old_use=vws
	;;
*)
	is_test_old_use=($(sed 's/_dynamicPort//;s/_/ /' <<<$is_old))
	is_old_use=${is_test_old_use[0]#m}
	is_old_header_type=${is_test_old_use[1]}
	[[ ! $is_old_header_type ]] && is_old_header_type=none
	;;
esac

if [[ $is_old_use && ! $is_old_header_type ]]; then
	# not use caddy auto tls
	[[ ! $caddy ]] && is_old_use=
fi

# add old config
if [[ $is_old_use ]]; then
	is_tmp_list=("删除旧配置" "恢复: $is_old")

	ask list is_do_upgrade null "\n是否恢复旧配置:\n"

	[[ $REPLY == '1' ]] && {
		_green "\n删除完成!\n"
		del_old_file
	}

	_green "\n开始恢复...\n"

	# upgrade caddy
	if [[ $caddy ]]; then
		get install-caddy
		# bak caddy files
		mv -f $is_caddyfile $is_caddyfile.233.bak
		mv -f $is_caddy_dir/sites $is_caddy_dir/sites.233.bak
		load caddy.sh
		caddy_config new
	fi
	is_change=1
	is_dont_auto_exit=1
	is_dont_show_info=1
	if [[ $shadowsocks ]]; then
		for v in ${ss_method_list[@]}; do
			[[ $(egrep -i "^${ssciphers}$" <<<$v) ]] && ss_method=$v && break
		done
		if [[ $ss_method ]]; then
			add ss $ssport $sspass $ss_method
		fi
	fi
	if [[ $socks ]]; then
		add socks $socks_port $socks_username $socks_userpass
	fi
	port=$v2ray_port
	uuid=$v2ray_id
	is_no_kcp_seed=1
	header_type=$is_old_header_type
	[[ $caddy ]] && host=$domain
	path=/$path
	[[ ! $path_status ]] && path=
	if [[ $(grep dynamic <<<$is_old) ]]; then
		is_dynamic_port=1
		is_dynamic_port_range="$v2ray_dynamicPort_start-$v2ray_dynamicPort_end"
		add ${is_old_use}d
	else
		add $is_old_use
	fi

	if [[ $path_status ]]; then
		change $is_config_name web $proxy_site
	fi
	is_dont_auto_exit=
	is_dont_show_info=
	[[ $is_api_fail ]] && manage restart &
	[[ $caddy ]] && manage restart caddy
	info $is_config_name
else
	ask string y "是否删除旧配置? [y]:"
	_green "\n删除完成!\n"
fi

del_old_file