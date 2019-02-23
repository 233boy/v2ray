# config file
case $v2ray_transport in
1)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/tcp.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/tcp.json"
	;;
2)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/http.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/http.json"
	;;
3)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/ws.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/ws.json"
	;;
4)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/ws.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/ws_tls.json"
	;;
5)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/h2.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/h2.json"
	;;
[6-9] | 10 | 11)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/kcp.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/kcp.json"
	;;
1[2-7])
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/quic.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/quic.json"
	;;
18)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/dynamic/tcp.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/tcp.json"
	;;
19)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/dynamic/http.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/http.json"
	;;
20)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/dynamic/ws.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/ws.json"
	;;
2[1-6])
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/dynamic/kcp.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/kcp.json"
	;;
*)
	v2ray_server_config_file="/etc/v2ray/233boy/v2ray/config/server/dynamic/quic.json"
	v2ray_client_config_file="/etc/v2ray/233boy/v2ray/config/client/quic.json"
	;;
esac

# copy config file
cp -f $v2ray_server_config_file $v2ray_server_config
cp -f $v2ray_client_config_file $v2ray_client_config

# change port, uuid, alterId
sed -i "s/__VMPORT__/$v2ray_port/; s/__VMUSERID__/$v2ray_id/; s/__VMALTID__/$alterId/" $v2ray_server_config

# change dynamic port
if [[ $v2ray_transport -ge 18 ]]; then
	local multi_port="${v2ray_dynamicPort_start}-${v2ray_dynamicPort_end}"
	sed -i "s/10000-20000/$multi_port/" $v2ray_server_config
fi

# change domain and path, or header type
case $v2ray_transport in
5)
	sed -i "s/__H2DOMAIN__/$domain/" $v2ray_server_config
	if [[ $is_path ]]; then
		sed -i "s/__H2PATH__/$path/" $v2ray_server_config
	else
		sed -i "s/__H2PATH__//" $v2ray_server_config
	fi
	;;
7 | 13 | 22 | 28)
	sed -i "s/none/utp/" $v2ray_server_config
	sed -i "s/none/utp/" $v2ray_client_config
	;;
8 | 14 | 23 | 29)
	sed -i "s/none/srtp/" $v2ray_server_config
	sed -i "s/none/srtp/" $v2ray_client_config
	;;
9 | 15 | 24 | 30)
	sed -i "s/none/wechat-video/" $v2ray_server_config
	sed -i "s/none/wechat-video/" $v2ray_client_config
	;;
10 | 16 | 25 | 31)
	sed -i "s/none/dtls/" $v2ray_server_config
	sed -i "s/none/dtls/" $v2ray_client_config
	;;
11 | 17 | 26 | 32)
	sed -i "s/none/wireguard/" $v2ray_server_config
	sed -i "s/none/wireguard/" $v2ray_client_config
	;;
esac

# change client config file
[[ -z $ip ]] && get_ip
sed -i "s/__VMADDR__/$ip/; s/__VMPORT__/$v2ray_port/; s/__VMUSERID__/$v2ray_id/; s/__VMALTID__/$alterId/" $v2ray_client_config
if [[ $v2ray_transport == [45] ]]; then
	sed -i "s/__H2DOMAIN__/$domain/" $v2ray_client_config
	if [[ $is_path ]]; then
		sed -i "s/__H2PATH__/$path/" $v2ray_client_config
	else
		sed -i "s/__H2PATH__//" $v2ray_client_config
	fi
fi

# zip -q -r -j --password "233blog.com" /etc/v2ray/233blog_v2ray.zip $v2ray_client_config
