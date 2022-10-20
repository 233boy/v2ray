# vmess
_load vmess-config.sh
_get_client_file() {
    local _link="$(cat $v2ray_client_config | tr -d [:space:] | base64 -w0)"
    local link="https://233boy.github.io/tools/json.html#${_link}"
    echo
    echo "---------- Link do arquivo de configuração do cliente V2Ray -------------"
    echo
    echo -e ${cyan}$link${none}
    echo
    echo " Tutorial do cliente V2Ray: https://233v2.com/post/4/"
    echo
    echo
}
