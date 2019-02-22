_open_bbr() {
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
	echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
}

if [[ $(uname -r | cut -b 1) -eq 4 ]]; then
	case $(uname -r | cut -b 3-4) in
	9. | [1-9][0-9])
		_open_bbr
		;;
	esac
fi
