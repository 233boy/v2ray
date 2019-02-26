_black() { echo -e "$(tput setaf 0)$*$(tput setaf 9)"; }
_red() { echo -e "$(tput setaf 1)$*$(tput setaf 9)"; }
_green() { echo -e "$(tput setaf 2)$*$(tput setaf 9)"; }
_yellow() { echo -e "$(tput setaf 3)$*$(tput setaf 9)"; }
_blue() { echo -e "$(tput setaf 4)$*$(tput setaf 9)"; }
_magenta() { echo -e "$(tput setaf 5)$*$(tput setaf 9)"; }
_cyan() { echo -e "$(tput setaf 6)$*$(tput setaf 9)"; }
_white() { echo -e "$(tput setaf 7)$*$(tput setaf 9)"; }
log () {
  local TMPDIR="/tmp/"
  local LOG="${TMPDIR}/233script.log"
  local TYPE=$1
  local MSG=$2
  local TIME=$(date +%Y-%m-%d\ %H:%M:%S)

  [[ ! -d $TMPDIR ]] && mkdir -p $TMPDIR
  if [[ -z $TERM ]]; then #if in cron
    echo "[$TIME] $MSG" >> $LOG
  else
    case "$TYPE" in
          info)
            _green "[$TIME] $MSG" ;;
          warn)
            _yellow "[$TIME] $MSG" ;;
          err)
            _red "[$TIME] $MSG" ;;
    esac
    echo "[$TIME] $MSG" >> $LOG
  fi
}

error () { log err "$1"; }
info () { log info "$1"; }
warn () { log warn "$1";}
disableselinux () {
  # Configure SELinux
  type selinuxenabled >/dev/null 2>&1 || return 0;
  [[ ! -f /etc/selinux/config ]] && return 0;
  if selinuxenabled; then
    info "disabling SELINUX ..."
    setenforce Permissive # disable selinux needs reboot, set to Permissive
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  fi
}

addtocron () {
  local PROG="$1"
  local CRONLINE="$2"

  # empty crontab
  if ! crontab -l >/dev/null 2>&1; then
    echo "$CRONLINE" | crontab
    info "> crontab empty, added: $CRONLINE"
  else
    # add if $PROG not exists
    if ! crontab -l | grep -q "$PROG";  then
      info "> added: $CRONLINE"
      (crontab -l; echo "$CRONLINE") | crontab
    else
      info "> $PROG exists in cron, skipping."
    fi
  fi
}

removefromcron () {
  local PROG="$1"
  if crontab -l | grep -q "$PROG";  then
    crontab -l | grep -v "$PROG" | crontab
  fi
}

disablecronmail() {
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

	v6ip=$(curl -6 -s https://ifconfig.co/ip)
	[[ -z $v6ip ]] && v6ip=$(curl -6 -s https://api.ip.sb/ip)
	[[ -z $v6ip ]] && v6ip=$(curl -6 -s https://ip.seeip.org)
	[[ -z $v6ip ]] && v6ip=$(curl -6 -s http://icanhazip.com)
	[[ -z $v6ip ]] && v6ip=$(curl -6 -s https://api.myip.com | cut -d\" -f4)
}

error() {

	echo -e "\n$red 输入错误！$none\n"

}

pause() {

	read -rsp "$(echo -e "按$green Enter 回车键 $none继续....或按$red Ctrl + C $none取消.")" -d $'\n'
	echo
}