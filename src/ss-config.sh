# shadowsocks config
if [[ $shadowsocks ]]; then
	ss_file="/usr/local/etc/v2ray/sagasw/v2ray/config/server/include/ss.json"
	ss_file_tmp="/tmp/ss.json.tmp"
	cp -f $ss_file $ss_file_tmp
	sed -i "s/6666/$ssport/; s/chacha20-ietf/$ssciphers/; s/sagasw.com/$sspass/" $ss_file_tmp
	sed -i "/\/\/include_ss/r $ss_file_tmp" $v2ray_server_config
	sed -i "s#//include_ss#,#" $v2ray_server_config
	rm -rf $ss_file_tmp
fi
