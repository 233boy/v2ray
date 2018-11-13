# v2ray
最好用的 V2Ray 一键安装脚本 &amp; 管理脚本

yum update -y && yum install git -y


git clone https://github.com/dghabc/v2ray

cd v2ray

chmod +x install.sh

./install.sh local

v2ray info 查看 V2Ray 配置信息

v2ray config 修改 V2Ray 配置

v2ray link 生成 V2Ray 配置文件链接

v2ray infolink 生成 V2Ray 配置信息链接

v2ray qr 生成 V2Ray 配置二维码链接

v2ray ss 修改 Shadowsocks 配置

v2ray ssinfo 查看 Shadowsocks 配置信息

v2ray ssqr 生成 Shadowsocks 配置二维码链接

v2ray status 查看 V2Ray 运行状态

v2ray start 启动 V2Ray

v2ray stop 停止 V2Ray

v2ray restart 重启 V2Ray

v2ray log 查看 V2Ray 运行日志

v2ray update 更新 V2Ray

v2ray update.sh 更新 V2Ray 管理脚本

v2ray uninstall 卸载 V2Ray



配置文件路径

V2Ray 配置文件路径：/etc/v2ray/config.json

Caddy 配置文件路径：/etc/caddy/Caddyfile

脚本配置文件路径: /etc/v2ray/233blog_v2ray_backup.conf
