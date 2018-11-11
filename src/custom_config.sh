# custom config
if [[ -f /etc/v2ray/custom/config.json ]]; then
	custom_config_file="/etc/v2ray/custom/config.json"
	sed -i "/\/\/include_config/r $custom_config_file" $v2ray_server_config
	sed -i "s#//include_config#,#" $v2ray_server_config
fi
