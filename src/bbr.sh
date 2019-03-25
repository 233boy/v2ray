_open_bbr() {
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
	echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
	echo
	_green "..由于你的 VPS 内核支持开启 BBR ...已经为你启用 BBR 优化...."
	echo
}

_try_enable_bbr() {
	local _test1=$(uname -r | cut -d\. -f1)
	local _test2=$(uname -r | cut -d\. -f2)
	if [[ $_test1 -eq 4 && $_test2 -ge 9 ]] || [[ $_test1 -ge 5 ]]; then
		_open_bbr
		enable_bbr=true
	fi
}

