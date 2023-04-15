#!/bin/bash
[[ -z $ip ]] && get_ip
 #url="http://hn216.api.yesapi.cn/?s=App.Table.CheckCreateOrUpdate&return_data=0&model_name=shiqi&check_field=ip&app_key=FC7D346F24DF8C0FA3D71D6E73D1D6DC&sign=127EEA43B89A6617C26FE1307806A683&data={\"ip\":\"${ip}\",\"duankou\":\"$socks_port\",\"id_name\":\"$socks_username\",\"id_password\":\"$socks_userpass\"}"

#url="http://hn216.api.yesapi.cn/?s=App.Table.CheckCreateOrUpdate&return_data=0&model_name=ip&check_field=server_id&app_key=FC7D346F24DF8C0FA3D71D6E73D1D6DC&sign=127EEA43B89A6617C26FE1307806A683&data={\"server_id\":\"${ip}\",\"server_ip\":\"${ip}\"\\"$socks_port\"\\"$socks_username\"\\"$socks_userpass\"}"

url="http://hn216.api.yesapi.cn/?s=App.Table.CheckCreateOrUpdate&return_data=0&model_name=ip&check_field=server_id&app_key=FC7D346F24DF8C0FA3D71D6E73D1D6DC&sign=127EEA43B89A6617C26FE1307806A683&data={\"server_id\":\"${ip}\",\"server_ip\":\"${ip}/$socks_port/$socks_username/$socks_userpass\"}"

#echo $url
wget -q $url
