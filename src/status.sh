_check_status() {
    sleep 2
    if [[ ! $(pgrep -f /usr/bin/v2ray/v2ray) ]]; then
        _err_msg
    fi
    if [[ $v2ray_transport == [45] && $caddy ]] && [[ ! $(pgrep -f /usr/bin/v2ray/v2ray) ]]; then
        _err_msg "Caddy"
    fi
}
_err_msg() {
    local str=$1
    [[ -z $1 ]] && local str="V2Ray"
    echo
    _red "警告!!! $str 运行出错!!!! 请检查端口是否冲突!!! 配置是否正确!!!!"
    _red "警告!!! $str 运行出错!!!! 请检查端口是否冲突!!! 配置是否正确!!!!"
    _red "警告!!! $str 运行出错!!!! 请检查端口是否冲突!!! 配置是否正确!!!!"
    echo
    exit 1
}
