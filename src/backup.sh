## backup config
_bakcup() {
    for keys in $*; do
        case $keys in
        v2ray_transport)
            sed -i "/v2ray_transport=$v2ray_transport/v2ray_transport=$v2ray_transport_opt/" $backup
            ;;
        v2ray_port)
            sed -i "/v2ray_port=$v2ray_port/v2ray_port=$v2ray_port_opt/" $backup
            ;;
        uuid)
            sed -i "/v2ray_id=$v2ray_id/v2ray_id=$uuid/" $backup
            ;;
        alterId)
            sed -i "/alterId=$alterId/alterId=$new_alterId/" $backup
            ;;
        v2ray_dynamicPort_start)
            sed -i "/v2ray_dynamicPort_start=$v2ray_dynamicPort_start/v2ray_dynamicPort_start=$v2ray_dynamic_port_start_input/" $backup
            ;;
        v2ray_dynamicPort_end)
            sed -i "/v2ray_dynamicPort_end=$v2ray_dynamicPort_end/v2ray_dynamicPort_end=$v2ray_dynamic_port_end_input/" $backup
            ;;
        domain)
            sed -i "/domain=$domain/domain=$new_domain/" $backup
            ;;
        caddy)
            sed -i "/caddy=/caddy=true/" $backup
            ;;
        +ss)
            sed -i "/shadowsocks=/shadowsocks=true/; /ssport=$ssport/ssport=$new_ssport/; /sspass=$sspass/sspass=$new_sspass/; /ssciphers=$ssciphers/ssciphers=$new_ssciphers/" $backup
            ;;
        -ss)
            sed -i "/shadowsocks=true/shadowsocks=/" $backup
            ;;
        ssport)
            sed -i "/ssport=$ssport/ssport=$new_ssport/" $backup
            ;;
        sspass)
            sed -i "/sspass=$sspass/sspass=$new_sspass/" $backup
            ;;
        ssciphers)
            sed -i "/ssciphers=$ssciphers/ssciphers=$new_ssciphers/" $backup
            ;;
        +ad)
            sed -i "/ban_ad=/ban_ad=true/" $backup
            ;;
        -ad)
            sed -i "/ban_ad=true/ban_ad=/" $backup
            ;;
        +path)
            sed -i "/path_status=/path_status=true/; /path=$path/path=$new_path/; #proxy_site=$proxy_site#proxy_site=$new_proxy_site#" $backup
            ;;
        -path)
            sed -i "/path_status=true/path_status=/" $backup
            ;;
        path)
            sed -i "/path=$path/path=$new_path/" $backup
            ;;
        proxy_site)
            sed -i "#proxy_site=$proxy_site#proxy_site=$new_proxy_site#" $backup
            ;;
        +socks)
            sed -i "/socks=/socks=true/; /socks_port=$socks_port/socks_port=$new_socks_port/; /socks_username=$socks_username/socks_username=$new_socks_username/; /socks_userpass=$socks_userpass/socks_userpass=$new_socks_userpass/;" $backup
            ;;
        -socks)
            sed -i "/socks=true/socks=/" $backup
            ;;
        socks_port)
            sed -i "/socks_port=$socks_port/socks_port=$new_socks_port/" $backup
            ;;
        socks_username)
            sed -i "/socks_username=$socks_username/socks_username=$new_socks_username/" $backup
            ;;
        socks_userpass)
            sed -i "/socks_userpass=$socks_userpass/socks_userpass=$new_socks_userpass/" $backup
            ;;
        +mtproto)
            sed -i "/mtproto=/mtproto=true/; /mtproto_port=$mtproto_port/mtproto_port=$new_mtproto_port/; /mtproto_secret=$mtproto_secret/mtproto_secret=$new_mtproto_secret/" $backup
            ;;
        -mtproto)
            sed -i "/mtproto=true/mtproto=/" $backup
            ;;
        mtproto_port)
            sed -i "/mtproto_port=$mtproto_port/mtproto_port=$new_mtproto_port/" $backup
            ;;
        mtproto_secret)
            sed -i "/mtproto_secret=$mtproto_secret/mtproto_secret=$new_mtproto_secret/" $backup
            ;;
        +bt)
            sed -i "/ban_bt=/ban_bt=true/" $backup
            ;;
        -bt)
            sed -i "/ban_bt=true/ban_bt=/" $backup
            ;;
        esac
    done
}
