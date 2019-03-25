_check_status() {
    sleep 2
    if [[ ! $(pgrep -f /usr/bin/v2ray/v2ray) ]]; then
        echo
        _red "警告!!! V2Ray 运行出错!!!! 请检查端口是否冲突!!! 配置是否正确!!!!"
        _red "警告!!! V2Ray 运行出错!!!! 请检查端口是否冲突!!! 配置是否正确!!!!"
        _red "警告!!! V2Ray 运行出错!!!! 请检查端口是否冲突!!! 配置是否正确!!!!"
        echo
    fi
}
