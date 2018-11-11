# ban bt
if [[ $ban_bt ]]; then
	ban_bt_file="/etc/v2ray/233boy/v2ray/config/server/include/bt.json"
	sed -i "/\/\/include_ban_bt/r $ban_bt_file" $v2ray_server_config
	sed -i "s#//include_ban_bt#,#" $v2ray_server_config
fi
