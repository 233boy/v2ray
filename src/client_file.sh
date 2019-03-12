_get_client_file() {
    local _link="$(cat $v2ray_client_config | tr -d [:space:] | base64 -w0)"
    local link="https://233boy.github.io/tools/json.html#${_link}"
    echo
    echo "---------- V2Ray 客户端配置文件链接 -------------"
    echo
    echo -e ${cyan}$link${none}
    echo
    echo " V2Ray 客户端使用教程: https://v2ray6.com/post/4/"
    echo
    echo
}
