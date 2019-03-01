## backup config
_backup() {
    for keys in $*; do
        case $keys in
        v2ray_transport)
            sed -i "s/v2ray_transport=$v2ray_transport/v2ray_transport=$new_v2ray_transport/" $backup
            ;;
        v2ray_port)
            sed -i "s/v2ray_port=$v2ray_port/v2ray_port=$new_v2ray_port/" $backup
            ;;
        uuid)
            sed -i "s/v2ray_id=$v2ray_id/v2ray_id=$uuid/" $backup
            ;;
        alterId)
            sed -i "s/alterId=$alterId/alterId=$new_alterId/" $backup
            ;;
        v2ray_dynamicPort_start)
            sed -i "s/v2ray_dynamicPort_start=$v2ray_dynamicPort_start/v2ray_dynamicPort_start=$v2ray_dynamic_port_start_input/" $backup
            ;;
        v2ray_dynamicPort_end)
            sed -i "s/v2ray_dynamicPort_end=$v2ray_dynamicPort_end/v2ray_dynamicPort_end=$v2ray_dynamic_port_end_input/" $backup
            ;;
        domain)
            sed -i "s/domain=$domain/domain=$new_domain/" $backup
            ;;
        caddy)
            sed -i "s/caddy=/caddy=true/" $backup
            ;;
        +ss)
            sed -i "s/shadowsocks=/shadowsocks=true/; s/ssport=$ssport/ssport=$new_ssport/; s/sspass=$sspass/sspass=$new_sspass/; s/ssciphers=$ssciphers/ssciphers=$new_ssciphers/" $backup
            ;;
        -ss)
            sed -i "s/shadowsocks=true/shadowsocks=/" $backup
            ;;
        ssport)
            sed -i "s/ssport=$ssport/ssport=$new_ssport/" $backup
            ;;
        sspass)
            sed -i "s/sspass=$sspass/sspass=$new_sspass/" $backup
            ;;
        ssciphers)
            sed -i "s/ssciphers=$ssciphers/ssciphers=$new_ssciphers/" $backup
            ;;
        +ad)
            sed -i "s/ban_ad=/ban_ad=true/" $backup
            ;;
        -ad)
            sed -i "s/ban_ad=true/ban_ad=/" $backup
            ;;
        +path)
            sed -i "s/path_status=/path_status=true/; s/path=$path/path=$new_path/; s#proxy_site=$proxy_site#proxy_site=$new_proxy_site#" $backup
            ;;
        -path)
            sed -i "s/path_status=true/path_status=/" $backup
            ;;
        path)
            sed -i "s/path=$path/path=$new_path/" $backup
            ;;
        proxy_site)
            sed -i "s#proxy_site=$proxy_site#proxy_site=$new_proxy_site#" $backup
            ;;
        +socks)
            sed -i "s/socks=/socks=true/; s/socks_port=$socks_port/socks_port=$new_socks_port/; s/socks_username=$socks_username/socks_username=$new_socks_username/; s/socks_userpass=$socks_userpass/socks_userpass=$new_socks_userpass/;" $backup
            ;;
        -socks)
            sed -i "s/socks=true/socks=/" $backup
            ;;
        socks_port)
            sed -i "s/socks_port=$socks_port/socks_port=$new_socks_port/" $backup
            ;;
        socks_username)
            sed -i "s/socks_username=$socks_username/socks_username=$new_socks_username/" $backup
            ;;
        socks_userpass)
            sed -i "s/socks_userpass=$socks_userpass/socks_userpass=$new_socks_userpass/" $backup
            ;;
        +mtproto)
            sed -i "s/mtproto=/mtproto=true/; s/mtproto_port=$mtproto_port/mtproto_port=$new_mtproto_port/; s/mtproto_secret=$mtproto_secret/mtproto_secret=$new_mtproto_secret/" $backup
            ;;
        -mtproto)
            sed -i "s/mtproto=true/mtproto=/" $backup
            ;;
        mtproto_port)
            sed -i "s/mtproto_port=$mtproto_port/mtproto_port=$new_mtproto_port/" $backup
            ;;
        mtproto_secret)
            sed -i "s/mtproto_secret=$mtproto_secret/mtproto_secret=$new_mtproto_secret/" $backup
            ;;
        +bt)
            sed -i "s/ban_bt=/ban_bt=true/" $backup
            ;;
        -bt)
            sed -i "s/ban_bt=true/ban_bt=/" $backup
            ;;
        esac
    done
}
_first_backup(){
        for keys in $*; do
        case $keys in
        v2ray)
            sed -i "s/v2ray_transport=1/v2ray_transport=$v2ray_transport/; s/v2ray_port=2333/v2ray_port=$v2ray_port/; s/v2ray_id=uuid/v2ray_id=$uuid/" $backup
            ;;
        dynamicPort)
            sed -i "s/v2ray_dynamicPort_start=10000/v2ray_dynamicPort_start=$v2ray_dynamic_port_start_input/; s/v2ray_dynamicPort_end=20000/v2ray_dynamicPort_end=$v2ray_dynamic_port_end_input/" $backup
            ;;
        domain)
            sed -i "s/domain=233blog.com/domain=$domain/" $backup
            ;;
        caddy)
            sed -i "s/caddy=/caddy=true/" $backup
            ;;
        +ss)
            sed -i "s/shadowsocks=/shadowsocks=true/; s/ssport=6666/ssport=$ssport/; s/sspass=233blog.com/sspass=$sspass/; s/ssciphers=chacha20-ietf/ssciphers=$ssciphers/" $backup
            ;;
        +ad)
            sed -i "s/ban_ad=/ban_ad=true/" $backup
            ;;
        +path)
            sed -i "s/path_status=/path_status=true/; s/path=233blog/path=$path/; s#proxy_site=https://liyafly.com#proxy_site=$proxy_site#" $backup
            ;;
        esac
    done
}