_download_caddy_file() {
	caddy_tmp="/tmp/install_caddy/"
	caddy_tmp_file="/tmp/install_caddy/caddy.tar.gz"
	[[ -d $caddy_tmp ]] && rm -rf $caddy_tmp
	if [[ ! ${caddy_arch} ]]; then
		echo -e "$red 获取 Caddy 下载参数失败！$none" && exit 1
	fi
	# local caddy_download_link="https://caddyserver.com/download/linux/${caddy_arch}?license=personal"
	local caddy_download_link="https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_${caddy_arch}.tar.gz"

	mkdir -p $caddy_tmp

	if ! wget --no-check-certificate -O "$caddy_tmp_file" $caddy_download_link; then
		echo -e "$red 下载 Caddy 失败！$none" && exit 1
	fi

	tar zxf $caddy_tmp_file -C $caddy_tmp
	cp -f ${caddy_tmp}caddy /usr/local/bin/

	# wget -qO- https://getcaddy.com | bash -s personal

	if [[ ! -f /usr/local/bin/caddy ]]; then
		echo -e "$red 安装 Caddy 出错！$none" && exit 1
	fi
}
_install_caddy_service() {
	# setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/caddy

	if [[ $systemd ]]; then
		cp -f ${caddy_tmp}init/linux-systemd/caddy.service /lib/systemd/system/
		# if ! wget https://raw.githubusercontent.com/caddyserver/caddy/master/dist/init/linux-systemd/caddy.service -O /lib/systemd/system/caddy.service; then
		# 	echo -e "$red 下载 caddy.service 失败！$none" && exit 1
		# fi
		# sed -i "s/-log-timestamps=false//g" /lib/systemd/system/caddy.service
		if [[ ! $(grep "ReadWriteDirectories" /lib/systemd/system/caddy.service) ]]; then
			sed -i "/ReadWritePaths/a ReadWriteDirectories=/etc/ssl/caddy" /lib/systemd/system/caddy.service
		fi
		sed -i "s/www-data/root/g" /lib/systemd/system/caddy.service
		# sed -i "/on-abnormal/a RestartSec=3" /lib/systemd/system/caddy.service
		# sed -i "s/on-abnormal/always/" /lib/systemd/system/caddy.service

		#### 。。。。。 Warning.....Warning.......Warning........Warning......
		#### 。。。。。 use root user run caddy...

		# cat >/lib/systemd/system/caddy.service <<-EOF
		# 	[Unit]
		# 	Description=Caddy HTTP/2 web server
		# 	Documentation=https://caddyserver.com/docs
		# 	After=network.target
		# 	Wants=network.target

		# 	[Service]
		# 	Restart=always
		# 	RestartSec=3
		# 	Environment=CADDYPATH=/root/.caddy
		# 	ExecStart=/usr/local/bin/caddy -log stdout -agree=true -conf=/etc/caddy/Caddyfile -root=/var/tmp
		# 	ExecReload=/bin/kill -USR1 $MAINPID
		# 	KillMode=mixed
		# 	KillSignal=SIGQUIT
		# 	TimeoutStopSec=5s
		# 	LimitNOFILE=1048576
		# 	LimitNPROC=512

		# 	[Install]
		# 	WantedBy=multi-user.target
		# EOF
		systemctl enable caddy
	else
		cp -f ${caddy_tmp}init/linux-sysvinit/caddy /etc/init.d/caddy
		sed -i "s/www-data/root/g" /etc/init.d/caddy
		chmod +x /etc/init.d/caddy
		update-rc.d -f caddy defaults
	fi

	# if [ -z "$(grep www-data /etc/passwd)" ]; then
	# 	useradd -M -s /usr/sbin/nologin www-data
	# fi
	# chown -R www-data.www-data /etc/ssl/caddy

	# ref https://github.com/caddyserver/caddy/tree/master/dist/init/linux-systemd

	mkdir -p /etc/caddy
	# chown -R root:root /etc/caddy
	mkdir -p /etc/ssl/caddy
	# chown -R root:www-data /etc/ssl/caddy
	# chmod 0770 /etc/ssl/caddy

	## create sites dir
	mkdir -p /etc/caddy/sites
}
