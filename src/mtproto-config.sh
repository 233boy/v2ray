# shadowsocks config
if [[ $mtproto ]]; then
	mtproto_file="/etc/v2ray/233boy/v2ray/config/server/include/mtproto.json"
	mtproto_file_tmp="/tmp/ss.json.tmp"
	cp -f $mtproto_file $mtproto_file_tmp
	sed -i "s/6666/$mtproto_port/; s/bb8a7fbd7190e345024845f07373ec48/$mtproto_secret/" $mtproto_file_tmp
	sed -i "/\/\/include_mtproto/r $mtproto_file_tmp" $v2ray_server_config
	sed -i "s#//include_mtproto#,#" $v2ray_server_config
	rm -rf $mtproto_file_tmp
fi
