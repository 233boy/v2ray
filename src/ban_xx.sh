# ban domain
ban_xx_file="/etc/v2ray/233boy/v2ray/config/server/include/ban.json"
sed -i "/\/\/include_ban_xx/r $ban_xx_file" $v2ray_server_config
sed -i "s#//include_ban_xx#,#" $v2ray_server_config
