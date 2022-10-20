_get_latest_version() {
	v2ray_repos_url="https://api.github.com/repos/v2fly/v2ray-core/releases/latest?v=$RANDOM"
	v2ray_latest_ver="$(curl -s $v2ray_repos_url | grep 'tag_name' | cut -d\" -f4)"

	if [[ ! $v2ray_latest_ver ]]; then
		echo
		echo -e " $red Falha ao obter a versão mais recente do V2Ray!!!$none"
		echo
		echo -e "Por favor, tente executar o seguinte comando: $green echo 'nameserver 8.8.8.8' >/etc/resolv.conf $none"
		echo
		echo " Em seguida, execute novamente o script...."
		echo
		exit 1
	fi
}

_download_v2ray_file() {
	[[ ! $v2ray_latest_ver ]] && _get_latest_version
	v2ray_tmp_file="/tmp/v2ray.zip"
	v2ray_download_link="https://github.com/v2fly/v2ray-core/releases/download/$v2ray_latest_ver/v2ray-linux-${v2ray_bit}.zip"

	if ! wget --no-check-certificate -O "$v2ray_tmp_file" $v2ray_download_link; then
		echo -e "
        $red Falha ao baixar o V2Ray.. Talvez sua rede VPS esteja muito quente... Por favor, tente novamente...$none
        " && exit 1
	fi

	unzip -o $v2ray_tmp_file -d "/usr/bin/v2ray/"
	chmod +x /usr/bin/v2ray/v2ray
	if [[ ! $(cat /root/.bashrc | grep v2ray) ]]; then
		echo "alias v2ray=$_v2ray_sh" >>/root/.bashrc
	fi
}

_install_v2ray_service() {
	# cp -f "/usr/bin/v2ray/systemd/v2ray.service" "/lib/systemd/system/"
	# sed -i "s/on-failure/always/" /lib/systemd/system/v2ray.service
	cat >/lib/systemd/system/v2ray.service <<-EOF
[Unit]
Description=V2Ray Service
Documentation=https://www.v2ray.com/ https://www.v2fly.org/
After=network.target nss-lookup.target

[Service]
# If the version of systemd is 240 or above, then uncommenting Type=exec and commenting out Type=simple
#Type=exec
Type=simple
# This service runs as root. You may consider to run it as another user for security concerns.
# By uncommenting User=nobody and commenting out User=root, the service will run as user nobody.
# More discussion at https://github.com/v2ray/v2ray-core/issues/1011
User=root
#User=nobody
Environment="V2RAY_VMESS_AEAD_FORCED=false"
#CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/env v2ray.vmess.aead.forced=false /usr/bin/v2ray/v2ray run -config /etc/v2ray/config.json
Restart=on-failure
StartLimitBurst=0
LimitNOFILE=1048576
LimitNPROC=512
#Restart=always

[Install]
WantedBy=multi-user.target
EOF
	systemctl enable v2ray
}

_update_v2ray_version() {
	_get_latest_version
	if [[ $v2ray_ver != $v2ray_latest_ver ]]; then
		echo
		echo -e " $green Huh... Encontrei uma nova versão.... está desesperadamente atualizando....$none"
		echo
		_download_v2ray_file
		do_service restart v2ray
		echo
		echo -e " $green A atualização foi bem sucedida...a versão atual do V2Ray: ${cyan}$v2ray_latest_ver$none"
		echo
		echo -e " $yellow Lembrete: Para evitar problemas inexplicáveis... A versão do cliente V2Ray deve ser consistente com a versão do servidor$none"
		echo
	else
		echo
		echo -e " $green Nenhuma nova versão encontrada....$none"
		echo
	fi
}

_mkdir_dir() {
	mkdir -p /var/log/v2ray
	mkdir -p /etc/v2ray
}
