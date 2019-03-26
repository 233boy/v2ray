_check_status() {
    sleep 1.5
    unset v2ray_pid
    if [[ ! $(pgrep -f /usr/bin/v2ray/v2ray) ]]; then
        _err_msg
    else
        v2ray_pid=true
    fi
    unset caddy_pid
    if [[ $v2ray_transport == [45] && $caddy ]] && [[ ! $(pgrep -f /usr/local/bin/caddy) ]]; then
        _err_msg "Caddy"
    else
        caddy_pid=true
    fi
}
_get_status() {
    if [[ ! $v2ray_pid ]]; then
        _err_msg
    fi
    if [[ $v2ray_transport == [45] && $caddy ]] && [[ $1 && ! $caddy_pid ]]; then
        _err_msg "Caddy"
    fi
}
_err_msg() {
    local str=$1
    [[ -z $1 ]] && local str="V2Ray"
    echo
    _red "警告!!! $str 运行出错!!! 或没有在运行!!!! 请检查!!!!"
    _red "警告!!! $str 运行出错!!! 或没有在运行!!!! 请检查!!!!"
    _red "警告!!! $str 运行出错!!! 或没有在运行!!!! 请检查!!!!"
    echo
    exit 1
}
