#!/bin/bash
backup="/etc/v2ray/233blog_v2ray_backup.txt"
v2ray_transport=$(sed -n '17p' $backup)
v2ray_port=$(sed -n '19p' $backup)
v2ray_id=$(sed -n '21p' $backup)
v2ray_dynamicPort_start=$(sed -n '23p' $backup)
v2ray_dynamicPort_end=$(sed -n '25p' $backup)
domain=$(sed -n '27p' $backup)
caddy_status=$(sed -n '29p' $backup)
shadowsocks_status=$(sed -n '31p' $backup)
ssport=$(sed -n '33p' $backup)
sspass=$(sed -n '35p' $backup)
ssciphers=$(sed -n '37p' $backup)
blocked_ad_status=$(sed -n '39p' $backup)
ws_path_status=$(sed -n '41p' $backup)
ws_path=$(sed -n '43p' $backup)
proxy_site=$(sed '$!d' $backup)
if [[ $caddy_status == "true" ]]; then
	caddy_installed=true
fi
if [[ $shadowsocks_status == "true" ]]; then
	shadowsocks=true
fi
if [[ $blocked_ad_status == "true" ]]; then
	is_blocked_ad=true
fi
if [[ $ws_path_status == "true" ]]; then
	is_ws_path=true
fi

cat >/etc/v2ray/233blog_v2ray_backup.conf <<-EOF
# -----------------------------------
# 警告...请不要修改或删除这个文件...谢谢
# 警告...请不要修改或删除这个文件...谢谢
# 警告...请不要修改或删除这个文件...谢谢
# -----------------------------------

# ---- 再次提醒 ----
# 大胸弟...如果你看到了这个...记得不要修改或更改这个文件

# ---- 说明 ----
# 嗯……这个文件呢，是用来备份一些设置的
#
#mark=v3
#
#

# ---- V2Ray 传输协议 -----
v2ray_transport=$v2ray_transport

#---- V2Ray 端口 -----
v2ray_port=$v2ray_port

#---- UUID -----
v2ray_id=$v2ray_id

#---- alterId -----
alterId=233

#---- V2Ray 动态端口开始 -----
v2ray_dynamicPort_start=$v2ray_dynamicPort_start

#---- V2Ray 动态端口结束 -----
v2ray_dynamicPort_end=$v2ray_dynamicPort_end

#---- 域名 -----
domain=$domain

#---- caddy -----
caddy_status=$caddy_installed

#---- Shadowsocks -----
shadowsocks_status=$shadowsocks

#---- Shadowsocks 端口 -----
ssport=$ssport

#---- Shadowsocks 密码 -----
sspass=$sspass

#---- Shadowsocks 加密协议 -----
ssciphers=$ssciphers

#---- 屏蔽广告 -----
blocked_ad_status=$is_blocked_ad

#---- 网站伪装 -----
path_status=$is_ws_path

#---- 伪装的路径 -----
path=$ws_path

#---- 伪装的网址 -----
proxy_site=$proxy_site

#---- Socks -----
socks=

#---- Socks 端口-----
socks_port=233

#---- Socks 用户名 -----
socks_username=233blog

#---- Socks 密码 -----
socks_userpass=233blog.com

#---- MTProto -----
mtproto=

#---- MTProto 端口-----
mtproto_port=233

#---- MTProto 用户密钥 -----
mtproto_secret=lalala

#---- 屏蔽 BT -----
ban_bt=true
		EOF
if [[ -f /usr/local/bin/v2ray ]]; then
	cp -f /etc/v2ray/233boy/v2ray/v2ray.sh /usr/local/sbin/v2ray
	chmod +x /usr/local/sbin/v2ray
	rm -rf $backup
	rm -rf /usr/local/bin/v2ray
fi

echo
echo -e " 哇哦...脚本差点就跪了..."
echo
echo -e "\n $yellow 警告: 请重新登录 SSH 以避免出现 v2ray 命令未找到的情况。$none  \n" && exit 1
echo
exit 1
