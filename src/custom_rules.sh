# custom rules
if [[ -f /etc/v2ray/custom/rules.json ]]; then
	custom_rules_file="/etc/v2ray/custom/rules.json"
	sed -i "/\/\/include_rules/r $custom_rules_file" $v2ray_server_config
	sed -i "s#//include_rules#,#" $v2ray_server_config
fi
