
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

_red() { echo -e ${red}$*${none}; }
_green()   { echo -e ${green}$*${none}; }
_yellow()  { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan()    { echo -e ${cyan}$*${none}; }


_addtocron () {
  local PROG="$1"
  local CRONLINE="$2"

  # empty crontab
  if ! crontab -l >/dev/null 2>&1; then
    echo "$CRONLINE" | crontab
  else
    # add if $PROG not exists
    if ! crontab -l | grep -q "$PROG";  then
      (crontab -l; echo "$CRONLINE") | crontab
    else
      echo "> $PROG exists in cron, skipping."
    fi
  fi
}

_removefromcron () {
  local PROG="$1"
  if crontab -l | grep -q "$PROG";  then
    crontab -l | grep -v "$PROG" | crontab
  fi
}

_disablecronmail() {
  if [[ ! -f /etc/sysconfig/crond ]]; then
	return 0
  fi
  sed -i '/^CRONDARGS/d' /etc/sysconfig/crond
  if crond -h 2>&1 | grep -- '-s'; then
    sed -i '$aCRONDARGS="-s -m off"' /etc/sysconfig/crond
  else
    sed -i '$aCRONDARGS="-m off"' /etc/sysconfig/crond
  fi
  service crond restart
}

_rm() {
	rm -rf "$@"
}
_cp() {
	cp -f "$@"
}
_sed() {
	sed -i "$@"
}
_mkdir() {
	mkdir -p "$@"
}

_load() {
    local _dir="/etc/v2ray/233boy/v2ray/src/"
    . "${_dir}$@"
}

get_ip() {
	ip=$(curl -4 -s https://ipinfo.io/ip)
	[[ -z $ip ]] && ip=$(curl -4 -s https://api.ip.sb/ip)
	[[ -z $ip ]] && ip=$(curl -4 -s https://api.ipify.org)
	[[ -z $ip ]] && ip=$(curl -4 -s https://ip.seeip.org)
	[[ -z $ip ]] && ip=$(curl -4 -s https://ifconfig.co/ip)
	[[ -z $ip ]] && ip=$(curl -4 -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && ip=$(curl -4 -s icanhazip.com)
	[[ -z $ip ]] && ip=$(curl -4 -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n" && exit

	v6ip=$(curl -m 5 -6 -s https://ifconfig.co/ip)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s https://api.ip.sb/ip)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s https://ip.seeip.org)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s http://icanhazip.com)
	[[ -z $v6ip ]] && v6ip=$(curl -m 5 -6 -s https://api.myip.com | cut -d\" -f4)
}

error() {

	echo -e "\n$red 输入错误！$none\n"

}

pause() {

	read -rsp "$(echo -e "按$green Enter 回车键 $none继续....或按$red Ctrl + C $none取消.")" -d $'\n'
	echo
}