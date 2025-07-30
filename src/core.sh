#!/bin/bash

protocol_list=(
    VMess-TCP
    VMess-mKCP
    VMess-QUIC
    VMess-H2-TLS
    VMess-WS-TLS
    VMess-gRPC-TLS
    VLESS-H2-TLS
    VLESS-WS-TLS
    VLESS-gRPC-TLS
    # VLESS-XTLS-uTLS-REALITY
    Trojan-H2-TLS
    Trojan-WS-TLS
    Trojan-gRPC-TLS
    Shadowsocks
    # Dokodemo-Door
    VMess-TCP-dynamic-port
    VMess-mKCP-dynamic-port
    VMess-QUIC-dynamic-port
    Socks
)
ss_method_list=(
    aes-128-gcm
    aes-256-gcm
    chacha20-ietf-poly1305
    # xchacha20-ietf-poly1305
    # 2022-blake3-aes-128-gcm
    # 2022-blake3-aes-256-gcm
    # 2022-blake3-chacha20-poly1305
)
header_type_list=(
    none
    srtp
    utp
    wechat-video
    dtls
    wireguard
)
mainmenu=(
    "添加配置"
    "更改配置"
    "查看配置"
    "删除配置"
    "运行管理"
    "更新"
    "卸载"
    "帮助"
    "其他"
    "关于"
)
info_list=(
    "协议 (protocol)"
    "地址 (address)"
    "端口 (port)"
    "用户ID (id)"
    "传输协议 (network)"
    "伪装类型 (type)"
    "伪装域名 (host)"
    "路径 (path)"
    "传输层安全 (TLS)"
    "mKCP seed"
    "密码 (password)"
    "加密方式 (encryption)"
    "链接 (URL)"
    "目标地址 (remote addr)"
    "目标端口 (remote port)"
    "流控 (flow)"
    "SNI (serverName)"
    "指纹 (Fingerprint)"
    "公钥 (Public key)"
    "用户名 (Username)"
)
change_list=(
    "更改协议"
    "更改端口"
    "更改域名"
    "更改路径"
    "更改密码"
    "更改 UUID"
    "更改加密方式"
    "更改伪装类型"
    "更改目标地址"
    "更改目标端口"
    "更改密钥"
    "更改 SNI (serverName)"
    "更改动态端口"
    "更改伪装网站"
    "更改 mKCP seed"
    "更改用户名 (Username)"
)
servername_list=(
    www.amazon.com
    www.microsoft.com
    www.apple.com
    dash.cloudflare.com
    dl.google.com
    aws.amazon.com
)

is_random_ss_method=${ss_method_list[$(shuf -i 0-${#ss_method_list[@]} -n1) - 1]}
is_random_header_type=${header_type_list[$(shuf -i 1-5 -n1)]} # random dont use none
is_random_servername=${servername_list[$(shuf -i 0-${#servername_list[@]} -n1) - 1]}

msg() {
    echo -e "$@"
}

msg_ul() {
    echo -e "\e[4m$@\e[0m"
}

# pause
pause() {
    echo
    echo -ne "按 $(_green Enter 回车键) 继续, 或按 $(_red Ctrl + C) 取消."
    read -rs -d $'\n'
    echo
}

get_uuid() {
    tmp_uuid=$(cat /proc/sys/kernel/random/uuid)
}

get_ip() {
    [[ $ip || $is_no_auto_tls || $is_gen || $is_dont_get_ip ]] && return
    export "$(_wget -4 -qO- https://one.one.one.one/cdn-cgi/trace | grep ip=)" &>/dev/null
    [[ ! $ip ]] && export "$(_wget -6 -qO- https://one.one.one.one/cdn-cgi/trace | grep ip=)" &>/dev/null
    [[ ! $ip ]] && {
        err "获取服务器 IP 失败.."
    }
}

get_port() {
    is_count=0
    while :; do
        ((is_count++))
        if [[ $is_count -ge 233 ]]; then
            err "自动获取可用端口失败次数达到 233 次, 请检查端口占用情况."
        fi
        tmp_port=$(shuf -i 445-65535 -n 1)
        [[ ! $(is_test port_used $tmp_port) && $tmp_port != $port ]] && break
    done
}

get_pbk() {
    is_tmp_pbk=($($is_core_bin x25519 | sed 's/.*://'))
    is_private_key=${is_tmp_pbk[0]}
    is_public_key=${is_tmp_pbk[1]}
}

show_list() {
    PS3=''
    COLUMNS=1
    select i in "$@"; do echo; done &
    wait
    # i=0
    # for v in "$@"; do
    #     ((i++))
    #     echo "$i) $v"
    # done
    # echo

}

is_test() {
    case $1 in
    number)
        echo $2 | grep -E '^[1-9][0-9]?+$'
        ;;
    port)
        if [[ $(is_test number $2) ]]; then
            [[ $2 -le 65535 ]] && echo ok
        fi
        ;;
    port_used)
        [[ $(is_port_used $2) && ! $is_cant_test_port ]] && echo ok
        ;;
    domain)
        echo $2 | grep -E -i '^\w(\w|\-|\.)?+\.\w+$'
        ;;
    path)
        echo $2 | grep -E -i '^\/\w(\w|\-|\/)?+\w$'
        ;;
    uuid)
        echo $2 | grep -E -i '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
        ;;
    esac

}

is_port_used() {
    if [[ $(type -P netstat) ]]; then
        [[ ! $is_used_port ]] && is_used_port="$(netstat -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)"
        echo $is_used_port | sed 's/ /\n/g' | grep ^${1}$
        return
    fi
    if [[ $(type -P ss) ]]; then
        [[ ! $is_used_port ]] && is_used_port="$(ss -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)"
        echo $is_used_port | sed 's/ /\n/g' | grep ^${1}$
        return
    fi
    is_cant_test_port=1
    msg "$is_warn 无法检测端口是否可用."
    msg "请执行: $(_yellow "${cmd} update -y; ${cmd} install net-tools -y") 来修复此问题."
}

# ask input a string or pick a option for list.
ask() {
    case $1 in
    set_ss_method)
        is_tmp_list=(${ss_method_list[@]})
        is_default_arg=$is_random_ss_method
        is_opt_msg="\n请选择加密方式:\n"
        is_opt_input_msg="(默认\e[92m $is_default_arg\e[0m):"
        is_ask_set=ss_method
        ;;
    set_header_type)
        is_tmp_list=(${header_type_list[@]})
        is_default_arg=$is_random_header_type
        [[ $(grep -i tcp <<<"$is_new_protocol-$net") ]] && {
            is_tmp_list=(none http)
            is_default_arg=none
        }
        is_opt_msg="\n请选择伪装类型:\n"
        is_opt_input_msg="(默认\e[92m $is_default_arg\e[0m):"
        is_ask_set=header_type
        [[ $is_use_header_type ]] && return
        ;;
    set_protocol)
        is_tmp_list=(${protocol_list[@]})
        [[ $is_no_auto_tls ]] && {
            unset is_tmp_list
            for v in ${protocol_list[@]}; do
                [[ $(grep -i tls$ <<<$v) ]] && is_tmp_list=(${is_tmp_list[@]} $v)
            done
        }
        is_opt_msg="\n请选择协议:\n"
        is_ask_set=is_new_protocol
        ;;
    set_change_list)
        is_tmp_list=()
        for v in ${is_can_change[@]}; do
            is_tmp_list+=("${change_list[$v]}")
        done
        is_opt_msg="\n请选择更改:\n"
        is_ask_set=is_change_str
        is_opt_input_msg=$3
        ;;
    string)
        is_ask_set=$2
        is_opt_input_msg=$3
        ;;
    list)
        is_ask_set=$2
        [[ ! $is_tmp_list ]] && is_tmp_list=($3)
        is_opt_msg=$4
        is_opt_input_msg=$5
        ;;
    get_config_file)
        is_tmp_list=("${is_all_json[@]}")
        is_opt_msg="\n请选择配置:\n"
        is_ask_set=is_config_file
        ;;
    mainmenu)
        is_tmp_list=("${mainmenu[@]}")
        is_ask_set=is_main_pick
        is_emtpy_exit=1
        ;;
    esac
    msg $is_opt_msg
    [[ ! $is_opt_input_msg ]] && is_opt_input_msg="请选择 [\e[91m1-${#is_tmp_list[@]}\e[0m]:"
    [[ $is_tmp_list ]] && show_list "${is_tmp_list[@]}"
    while :; do
        echo -ne $is_opt_input_msg
        read REPLY
        [[ ! $REPLY && $is_emtpy_exit ]] && exit
        [[ ! $REPLY && $is_default_arg ]] && export $is_ask_set=$is_default_arg && break
        [[ "$REPLY" == "${is_str}2${is_get}3${is_opt}3" && $is_ask_set == 'is_main_pick' ]] && {
            msg "\n${is_get}2${is_str}3${is_msg}3b${is_tmp}o${is_opt}y\n" && exit
        }
        if [[ ! $is_tmp_list ]]; then
            [[ $(grep port <<<$is_ask_set) ]] && {
                [[ ! $(is_test port "$REPLY") ]] && {
                    msg "$is_err 请输入正确的端口, 可选(1-65535)"
                    continue
                }
                if [[ $(is_test port_used $REPLY) && $is_ask_set != 'door_port' ]]; then
                    msg "$is_err 无法使用 ($REPLY) 端口."
                    continue
                fi
            }
            [[ $(grep path <<<$is_ask_set) && ! $(is_test path "$REPLY") ]] && {
                [[ ! $tmp_uuid ]] && get_uuid
                msg "$is_err 请输入正确的路径, 例如: /$tmp_uuid"
                continue
            }
            [[ $(grep uuid <<<$is_ask_set) && ! $(is_test uuid "$REPLY") ]] && {
                [[ ! $tmp_uuid ]] && get_uuid
                msg "$is_err 请输入正确的 UUID, 例如: $tmp_uuid"
                continue
            }
            [[ $(grep ^y$ <<<$is_ask_set) ]] && {
                [[ $(grep -i ^y$ <<<"$REPLY") ]] && break
                msg "请输入 (y)"
                continue
            }
            [[ $REPLY ]] && export $is_ask_set=$REPLY && msg "使用: ${!is_ask_set}" && break
        else
            [[ $(is_test number "$REPLY") ]] && is_ask_result=${is_tmp_list[$REPLY - 1]}
            [[ $is_ask_result ]] && export $is_ask_set="$is_ask_result" && msg "选择: ${!is_ask_set}" && break
        fi

        msg "输入${is_err}"
    done
    unset is_opt_msg is_opt_input_msg is_tmp_list is_ask_result is_default_arg is_emtpy_exit
}

# create file
create() {
    case $1 in
    server)
        is_tls=none
        get new

        # file name
        if [[ $host ]]; then
            is_config_name=$2-${host}.json
        else
            is_config_name=$2-${port}.json
        fi
        is_json_file=$is_conf_dir/$is_config_name
        # get json
        [[ $is_change || ! $json_str ]] && get protocol $2
        case $net in
        ws | h2 | grpc | http)
            is_listen='"listen": "127.0.0.1"'
            ;;
        *)
            is_listen='"listen": "0.0.0.0"'
            ;;
        esac
        is_sniffing='sniffing:{enabled:true,destOverride:["http","tls"]}'
        is_new_json=$(jq '{inbounds:[{tag:'\"$is_config_name\"',port:'"$port"','"$is_listen"',protocol:'\"$is_protocol\"','"$json_str"','"$is_sniffing"'}]}' <<<{})
        if [[ $is_dynamic_port ]]; then
            [[ ! $is_dynamic_port_range ]] && get dynamic-port
            is_new_dynamic_port_json=$(jq '{inbounds:[{tag:'\"$is_config_name-link.json\"',port:'\"$is_dynamic_port_range\"','"$is_listen"',protocol:"vmess",'"$is_stream"','"$is_sniffing"',allocate:{strategy:"random"}}]}' <<<{})
        fi
        [[ $is_test_json ]] && return # tmp test
        # only show json, dont save to file.
        [[ $is_gen ]] && {
            msg
            jq <<<$is_new_json
            msg
            [[ $is_new_dynamic_port_json ]] && jq <<<$is_new_dynamic_port_json && msg
            return
        }
        # del old file
        [[ $is_config_file ]] && is_no_del_msg=1 && del $is_config_file
        # save json to file
        cat <<<$is_new_json >$is_json_file
        [[ $is_new_dynamic_port_json ]] && {
            is_dynamic_port_link_file=$is_json_file-link.json
            cat <<<$is_new_dynamic_port_json >$is_dynamic_port_link_file
        }
        if [[ $is_new_install ]]; then
            # config.json
            create config.json
        else
            # use api add config
            api add $is_json_file $is_dynamic_port_link_file &>/dev/null
        fi
        # caddy auto tls
        [[ $is_caddy && $host && ! $is_no_auto_tls ]] && {
            create caddy $net
        }
        # restart core
        [[ $is_api_fail ]] && manage restart &
        ;;
    client)
        is_tls=tls
        is_client=1
        get info $2
        [[ ! $is_client_id_json ]] && err "($is_config_name) 不支持生成客户端配置."
        is_new_json=$(jq '{outbounds:[{tag:'\"$is_config_name\"',protocol:'\"$is_protocol\"','"$is_client_id_json"','"$is_stream"'}]}' <<<{})
        if [[ $is_full_client ]]; then
            is_dns='dns:{servers:[{address:"223.5.5.5",domain:["geosite:cn","geosite:geolocation-cn"],expectIPs:["geoip:cn"]},"1.1.1.1","8.8.8.8"]}'
            is_route='routing:{rules:[{type:"field",outboundTag:"direct",ip:["geoip:cn","geoip:private"]},{type:"field",outboundTag:"direct",domain:["geosite:cn","geosite:geolocation-cn"]}]}'
            is_inbounds='inbounds:[{port:2333,listen:"127.0.0.1",protocol:"socks",settings:{udp:true},sniffing:{enabled:true,destOverride:["http","tls"]}}]'
            is_outbounds='outbounds:[{tag:'\"$is_config_name\"',protocol:'\"$is_protocol\"','"$is_client_id_json"','"$is_stream"'},{tag:"direct",protocol:"freedom"}]'
            is_new_json=$(jq '{'$is_dns,$is_route,$is_inbounds,$is_outbounds'}' <<<{})
        fi
        msg
        jq <<<$is_new_json
        msg
        ;;
    caddy)
        load caddy.sh
        [[ $is_install_caddy ]] && caddy_config new
        [[ ! $(grep "$is_caddy_conf" $is_caddyfile) ]] && {
            msg "import $is_caddy_conf/*.conf" >>$is_caddyfile
        }
        [[ ! -d $is_caddy_conf ]] && mkdir -p $is_caddy_conf
        caddy_config $2
        manage restart caddy &
        ;;
    config.json)
        get_port
        is_log='log:{access:"/var/log/'"$is_core"'/access.log",error:"/var/log/'"$is_core"'/error.log",loglevel:"warning"}'
        is_dns='dns:{}'
        is_api='api:{tag:"api",services:["HandlerService","LoggerService","StatsService"]}'
        is_stats='stats:{}'
        is_policy_system='system:{statsInboundUplink:true,statsInboundDownlink:true,statsOutboundUplink:true,statsOutboundDownlink:true}'
        is_policy='policy:{levels:{"0":{handshake:'"$((${tmp_port:0:1} + 1))"',connIdle:'"${tmp_port:0:3}"',uplinkOnly:'"$((${tmp_port:2:1} + 1))"',downlinkOnly:'"$((${tmp_port:3:1} + 3))"',statsUserUplink:true,statsUserDownlink:true}},'"$is_policy_system"'}'
        is_ban_ad='{type:"field",domain:["geosite:category-ads-all"],marktag:"ban_ad",outboundTag:"block"}'
        is_ban_bt='{type:"field",protocol:["bittorrent"],marktag:"ban_bt",outboundTag:"block"}'
        is_ban_cn='{type:"field",ip:["geoip:cn"],marktag:"ban_geoip_cn",outboundTag:"block"}'
        is_openai='{type:"field",domain:["domain:openai.com"],marktag:"fix_openai",outboundTag:"direct"}'
        is_routing='routing:{domainStrategy:"IPIfNonMatch",rules:[{type:"field",inboundTag:["api"],outboundTag:"api"},'"$is_ban_bt"','"$is_ban_cn"','"$is_openai"',{type:"field",ip:["geoip:private"],outboundTag:"block"}]}'
        is_inbounds='inbounds:[{tag:"api",port:'"$tmp_port"',listen:"127.0.0.1",protocol:"dokodemo-door",settings:{address:"127.0.0.1"}}]'
        is_outbounds='outbounds:[{tag:"direct",protocol:"freedom"},{tag:"block",protocol:"blackhole"}]'
        is_server_config_json=$(jq '{'"$is_log"','"$is_dns"','"$is_api"','"$is_stats"','"$is_policy"','"$is_routing"','"$is_inbounds"','"$is_outbounds"'}' <<<{})
        cat <<<$is_server_config_json >$is_config_json
        manage restart &
        ;;
    esac
}

# change config file
change() {
    is_change=1
    is_dont_show_info=1
    if [[ $2 ]]; then
        case ${2,,} in
        full)
            is_change_id=full
            ;;
        new)
            is_change_id=0
            ;;
        port)
            is_change_id=1
            ;;
        host)
            is_change_id=2
            ;;
        path)
            is_change_id=3
            ;;
        pass | passwd | password)
            is_change_id=4
            ;;
        id | uuid)
            is_change_id=5
            ;;
        ssm | method | ss-method | ss_method)
            is_change_id=6
            ;;
        type | header | header-type | header_type)
            is_change_id=7
            ;;
        dda | door-addr | door_addr)
            is_change_id=8
            ;;
        ddp | door-port | door_port)
            is_change_id=9
            ;;
        key | publickey | privatekey)
            is_change_id=10
            ;;
        sni | servername | servernames)
            is_change_id=11
            ;;
        dp | dyp | dynamic | dynamicport | dynamic-port)
            is_change_id=12
            ;;
        web | proxy-site)
            is_change_id=13
            ;;
        seed | kcpseed | kcp-seed | kcp_seed)
            is_change_id=14
            ;;
        *)
            [[ $is_try_change ]] && return
            err "无法识别 ($2) 更改类型."
            ;;
        esac
    fi
    [[ $is_try_change ]] && return
    [[ $is_dont_auto_exit ]] && {
        get info $1
    } || {
        [[ $is_change_id ]] && {
            is_change_msg=${change_list[$is_change_id]}
            [[ $is_change_id == 'full' ]] && {
                [[ $3 ]] && is_change_msg="更改多个参数" || is_change_msg=
            }
            [[ $is_change_msg ]] && _green "\n快速执行: $is_change_msg"
        }
        info $1
        [[ $is_auto_get_config ]] && msg "\n自动选择: $is_config_file"
    }
    is_old_net=$net
    [[ $is_protocol == 'vless' && ! $is_reality ]] && net=v$net
    [[ $is_protocol == 'trojan' ]] && net=t$net
    [[ $is_dynamic_port ]] && net=${net}d
    [[ $3 == 'auto' ]] && is_auto=1
    # if is_dont_show_info exist, cant show info.
    is_dont_show_info=
    # if not prefer args, show change list and then get change id.
    [[ ! $is_change_id ]] && {
        ask set_change_list
        is_change_id=${is_can_change[$REPLY - 1]}
    }
    case $is_change_id in
    full)
        add $net ${@:3}
        ;;
    0)
        # new protocol
        is_set_new_protocol=1
        add ${@:3}
        ;;
    1)
        # new port
        is_new_port=$3
        [[ $host && ! $is_caddy || $is_no_auto_tls ]] && err "($is_config_file) 不支持更改端口, 因为没啥意义."
        if [[ $is_new_port && ! $is_auto ]]; then
            [[ ! $(is_test port $is_new_port) ]] && err "请输入正确的端口, 可选(1-65535)"
            [[ $is_new_port != 443 && $(is_test port_used $is_new_port) ]] && err "无法使用 ($is_new_port) 端口"
        fi
        [[ $is_auto ]] && get_port && is_new_port=$tmp_port
        [[ ! $is_new_port ]] && ask string is_new_port "请输入新端口:"
        if [[ $is_caddy && $host ]]; then
            net=$is_old_net
            is_https_port=$is_new_port
            load caddy.sh
            caddy_config $net
            manage restart caddy &
            info
        else
            add $net $is_new_port
        fi
        ;;
    2)
        # new host
        is_new_host=$3
        [[ ! $host ]] && err "($is_config_file) 不支持更改域名."
        [[ ! $is_new_host ]] && ask string is_new_host "请输入新域名:"
        old_host=$host # del old host
        add $net $is_new_host
        ;;
    3)
        # new path
        is_new_path=$3
        [[ ! $path ]] && err "($is_config_file) 不支持更改路径."
        [[ $is_auto ]] && get_uuid && is_new_path=/$tmp_uuid
        [[ ! $is_new_path ]] && ask string is_new_path "请输入新路径:"
        add $net auto auto $is_new_path
        ;;
    4)
        # new password
        is_new_pass=$3
        if [[ $net == 'ss' || $is_trojan || $is_socks_pass ]]; then
            [[ $is_auto ]] && get_uuid && is_new_pass=$tmp_uuid
        else
            err "($is_config_file) 不支持更改密码."
        fi
        [[ ! $is_new_pass ]] && ask string is_new_pass "请输入新密码:"
        trojan_password=$is_new_pass
        ss_password=$is_new_pass
        is_socks_pass=$is_new_pass
        add $net
        ;;
    5)
        # new uuid
        is_new_uuid=$3
        [[ ! $uuid ]] && err "($is_config_file) 不支持更改 UUID."
        [[ $is_auto ]] && get_uuid && is_new_uuid=$tmp_uuid
        [[ ! $is_new_uuid ]] && ask string is_new_uuid "请输入新 UUID:"
        add $net auto $is_new_uuid
        ;;
    6)
        # new method
        is_new_method=$3
        [[ $net != 'ss' ]] && err "($is_config_file) 不支持更改加密方式."
        [[ $is_auto ]] && is_new_method=$is_random_ss_method
        [[ ! $is_new_method ]] && {
            ask set_ss_method
            is_new_method=$ss_method
        }
        add $net auto auto $is_new_method
        ;;
    7)
        # new header type
        is_new_header_type=$3
        [[ ! $header_type ]] && err "($is_config_file) 不支持更改伪装类型."
        [[ $is_auto ]] && {
            is_new_header_type=$is_random_header_type
            if [[ $net == 'tcp' ]]; then
                is_tmp_header_type=(none http)
                is_new_header_type=${is_tmp_header_type[$(shuf -i 0-1 -n1)]}
            fi
        }
        [[ ! $is_new_header_type ]] && {
            ask set_header_type
            is_new_header_type=$header_type
        }
        add $net auto auto $is_new_header_type
        ;;
    8)
        # new remote addr
        is_new_door_addr=$3
        [[ $net != 'door' ]] && err "($is_config_file) 不支持更改目标地址."
        [[ ! $is_new_door_addr ]] && ask string is_new_door_addr "请输入新的目标地址:"
        door_addr=$is_new_door_addr
        add $net
        ;;
    9)
        # new remote port
        is_new_door_port=$3
        [[ $net != 'door' ]] && err "($is_config_file) 不支持更改目标端口."
        [[ ! $is_new_door_port ]] && {
            ask string door_port "请输入新的目标端口:"
            is_new_door_port=$door_port
        }
        add $net auto auto $is_new_door_port
        ;;
    10)
        # new is_private_key is_public_key
        is_new_private_key=$3
        is_new_public_key=$4
        [[ ! $is_reality ]] && err "($is_config_file) 不支持更改密钥."
        if [[ $is_auto ]]; then
            get_pbk
            add $net
        else
            [[ $is_new_private_key && ! $is_new_public_key ]] && {
                err "无法找到 Public key."
            }
            [[ ! $is_new_private_key ]] && ask string is_new_private_key "请输入新 Private key:"
            [[ ! $is_new_public_key ]] && ask string is_new_public_key "请输入新 Public key:"
            if [[ $is_new_private_key == $is_new_public_key ]]; then
                err "Private key 和 Public key 不能一样."
            fi
            is_private_key=$is_new_private_key
            is_test_json=1
            # create server $is_protocol-$net | $is_core_bin -test &>/dev/null
            create server $is_protocol-$net
            $is_core_bin -test <<<"$is_new_json" &>/dev/null
            if [[ $? != 0 ]]; then
                err "Private key 无法通过测试."
            fi
            is_private_key=$is_new_public_key
            # create server $is_protocol-$net | $is_core_bin -test &>/dev/null
            create server $is_protocol-$net
            $is_core_bin -test <<<"$is_new_json" &>/dev/null
            if [[ $? != 0 ]]; then
                err "Public key 无法通过测试."
            fi
            is_private_key=$is_new_private_key
            is_public_key=$is_new_public_key
            is_test_json=
            add $net
        fi
        ;;
    11)
        # new serverName
        is_new_servername=$3
        [[ ! $is_reality ]] && err "($is_config_file) 不支持更改 serverName."
        [[ $is_auto ]] && is_new_servername=$is_random_servername
        [[ ! $is_new_servername ]] && ask string is_new_servername "请输入新的 serverName:"
        is_servername=$is_new_servername
        [[ $(grep -i "^233boy.com$" <<<$is_servername) ]] && {
            err "你干嘛～哎呦～"
        }
        add $net
        ;;
    12)
        # new dynamic-port
        is_new_dynamic_port_start=$3
        is_new_dynamic_port_end=$4
        [[ ! $is_dynamic_port ]] && err "($is_config_file) 不支持更改动态端口."
        if [[ $is_auto ]]; then
            get dynamic-port
            add $net
        else
            [[ $is_new_dynamic_port_start && ! $is_new_dynamic_port_end ]] && {
                err "无法找到动态结束端口."
            }
            [[ ! $is_new_dynamic_port_start ]] && ask string is_new_dynamic_port_start "请输入新的动态开始端口:"
            [[ ! $is_new_dynamic_port_end ]] && ask string is_new_dynamic_port_end "请输入新的动态结束端口:"
            add $net auto auto auto $is_new_dynamic_port_start $is_new_dynamic_port_end
        fi
        ;;
    13)
        # new proxy site
        is_new_proxy_site=$3
        [[ ! $is_caddy && ! $host ]] && {
            err "($is_config_file) 不支持更改伪装网站."
        }
        [[ ! -f $is_caddy_conf/${host}.conf.add ]] && err "无法配置伪装网站."
        [[ ! $is_new_proxy_site ]] && ask string is_new_proxy_site "请输入新的伪装网站 (例如 example.com):"
        proxy_site=$(sed 's#^.*//##;s#/$##' <<<$is_new_proxy_site)
        [[ $(grep -i "^233boy.com$" <<<$proxy_site) ]] && {
            err "你干嘛～哎呦～"
        } || {
            load caddy.sh
            caddy_config proxy
            manage restart caddy &
        }
        msg "\n已更新伪装网站为: $(_green $proxy_site) \n"
        ;;
    14)
        # new kcp seed
        is_new_kcp_seed=$3
        [[ ! $kcp_seed ]] && err "($is_config_file) 不支持更改 mKCP seed."
        [[ $is_auto ]] && get_uuid && is_new_kcp_seed=$tmp_uuid
        [[ ! $is_new_kcp_seed ]] && ask string is_new_kcp_seed "请输入新 mKCP seed:"
        kcp_seed=$is_new_kcp_seed
        add $net
        ;;
    15)
        # new socks user
        [[ ! $is_socks_user ]] && err "($is_config_file) 不支持更改用户名 (Username)."
        ask string is_socks_user "请输入新用户名 (Username):"
        add $net
        ;;
    esac
}

# delete config.
del() {
    # dont get ip
    is_dont_get_ip=1
    [[ $is_conf_dir_empty ]] && return # not found any json file.
    # get a config file
    [[ ! $is_config_file ]] && get info $1
    if [[ $is_config_file ]]; then
        if [[ $is_main_start && ! $is_no_del_msg ]]; then
            msg "\n是否删除配置文件?: $is_config_file"
            pause
        fi
        api del $is_conf_dir/"$is_config_file" $is_dynamic_port_file &>/dev/null
        rm -rf $is_conf_dir/"$is_config_file" $is_dynamic_port_file
        [[ $is_api_fail && ! $is_new_json ]] && manage restart &
        [[ ! $is_no_del_msg ]] && _green "\n已删除: $is_config_file\n"

        [[ $is_caddy ]] && {
            is_del_host=$host
            [[ $is_change ]] && {
                [[ ! $old_host ]] && return # no host exist or not set new host;
                is_del_host=$old_host
            }
            [[ $is_del_host && $host != $old_host && ! $is_no_auto_tls ]] && {
                rm -rf $is_caddy_conf/$is_del_host.conf $is_caddy_conf/$is_del_host.conf.add
                [[ ! $is_new_json ]] && manage restart caddy &
            }
        }
    fi
    if [[ ! $(ls $is_conf_dir | grep .json) && ! $is_change ]]; then
        warn "当前配置目录为空! 因为你刚刚删除了最后一个配置文件."
        is_conf_dir_empty=1
    fi
    unset is_dont_get_ip
    [[ $is_dont_auto_exit ]] && unset is_config_file
}

# uninstall
uninstall() {
    if [[ $is_caddy ]]; then
        is_tmp_list=("卸载 $is_core_name" "卸载 ${is_core_name} & Caddy")
        ask list is_do_uninstall
    else
        ask string y "是否卸载 ${is_core_name}? [y]:"
    fi
    manage stop &>/dev/null
    manage disable &>/dev/null
    rm -rf $is_core_dir $is_log_dir $is_sh_bin /lib/systemd/system/$is_core.service
    sed -i "/alias $is_core=/d" /root/.bashrc
    # uninstall caddy; 2 is ask result
    if [[ $REPLY == '2' ]]; then
        manage stop caddy &>/dev/null
        manage disable caddy &>/dev/null
        rm -rf $is_caddy_dir $is_caddy_bin /lib/systemd/system/caddy.service
    fi
    [[ $is_install_sh ]] && return # reinstall
    _green "\n卸载完成!"
    msg "脚本哪里需要完善? 请反馈"
    msg "反馈问题) $(msg_ul https://github.com/${is_sh_repo}/issues)\n"
}

# manage run status
manage() {
    [[ $is_dont_auto_exit ]] && return
    case $1 in
    1 | start)
        is_do=start
        is_do_msg=启动
        is_test_run=1
        ;;
    2 | stop)
        is_do=stop
        is_do_msg=停止
        ;;
    3 | r | restart)
        is_do=restart
        is_do_msg=重启
        is_test_run=1
        ;;
    *)
        is_do=$1
        is_do_msg=$1
        ;;
    esac
    case $2 in
    caddy)
        is_do_name=$2
        is_run_bin=$is_caddy_bin
        is_do_name_msg=Caddy
        ;;
    *)
        is_do_name=$is_core
        is_run_bin=$is_core_bin
        is_do_name_msg=$is_core_name
        ;;
    esac
    systemctl $is_do $is_do_name
    [[ $is_test_run && ! $is_new_install ]] && {
        sleep 2
        if [[ ! $(pgrep -f $is_run_bin) ]]; then
            is_run_fail=${is_do_name_msg,,}
            [[ ! $is_no_manage_msg ]] && {
                msg
                warn "($is_do_msg) $is_do_name_msg 失败"
                _yellow "检测到运行失败, 自动执行测试运行."
                get test-run
                _yellow "测试结束, 请按 Enter 退出."
            }
        fi
    }
}

# use api add or del inbounds
api() {
    [[ $is_core_ver_lt_5 ]] && {
        warn "$is_core_ver 版本不支持使用 API 操作. 请升级内核版本: $is_core update core"
        is_api_fail=1
        return
    }
    [[ ! $1 ]] && err "无法识别 API 的参数."
    [[ $is_core_stop ]] && {
        warn "$is_core_name 当前处于停止状态."
        is_api_fail=1
        return
    }
    case $1 in
    add)
        is_api_do=adi
        ;;
    del)
        is_api_do=rmi
        ;;
    s)
        is_api_do=stats
        ;;
    t | sq)
        is_api_do=statsquery
        ;;
    esac
    [[ ! $is_api_do ]] && is_api_do=$1
    [[ ! $is_api_port ]] && {
        is_api_port=$(jq '.inbounds[] | select(.tag == "api") | .port' $is_config_json)
        [[ $? != 0 ]] && {
            warn "读取 API 端口失败, 无法使用 API 操作."
            return
        }
    }
    $is_core_bin api $is_api_do --server=127.0.0.1:$is_api_port ${@:2}
    [[ $? != 0 ]] && {
        is_api_fail=1
    }
}

# add a config
add() {
    is_lower=${1,,}
    if [[ $is_lower ]]; then
        case $is_lower in
        tcp | kcp | quic | tcpd | kcpd | quicd)
            is_new_protocol=VMess-$(sed 's/^K/mK/;s/D$/-dynamic-port/' <<<${is_lower^^})
            ;;
        ws | h2 | grpc | vws | vh2 | vgrpc | tws | th2 | tgrpc)
            is_new_protocol=$(sed -E "s/^V/VLESS-/;s/^T/Trojan-/;/^(W|H|G)/{s/^/VMess-/};s/G/g/" <<<${is_lower^^})-TLS
            ;;
        # r | reality)
        #     is_new_protocol=VLESS-XTLS-uTLS-REALITY
        #     ;;
        ss)
            is_new_protocol=Shadowsocks
            ;;
        door)
            is_new_protocol=Dokodemo-Door
            ;;
        socks)
            is_new_protocol=Socks
            ;;
        http)
            is_new_protocol=local-$is_lower
            ;;
        *)
            for v in ${protocol_list[@]}; do
                [[ $(grep -E -i "^$is_lower$" <<<$v) ]] && is_new_protocol=$v && break
            done

            [[ ! $is_new_protocol ]] && err "无法识别 ($1), 请使用: $is_core add [protocol] [args... | auto]"
            ;;
        esac
    fi

    # no prefer protocol
    [[ ! $is_new_protocol ]] && ask set_protocol

    case ${is_new_protocol,,} in
    *-tls)
        is_use_tls=1
        is_use_host=$2
        is_use_uuid=$3
        is_use_path=$4
        is_add_opts="[host] [uuid] [/path]"
        ;;
    vmess*)
        is_use_port=$2
        is_use_uuid=$3
        is_use_header_type=$4
        is_use_dynamic_port_start=$5
        is_use_dynamic_port_end=$6
        [[ $(grep dynamic-port <<<$is_new_protocol) ]] && is_dynamic_port=1
        if [[ $is_dynamic_port ]]; then
            is_add_opts="[port] [uuid] [type] [start_port] [end_port]"
        else
            is_add_opts="[port] [uuid] [type]"
        fi
        ;;
    # *reality*)
    #     is_reality=1
    #     is_use_port=$2
    #     is_use_uuid=$3
    #     is_use_servername=$4
    #     ;;
    shadowsocks)
        is_use_port=$2
        is_use_pass=$3
        is_use_method=$4
        is_add_opts="[port] [password] [method]"
        ;;
    *door)
        is_use_port=$2
        is_use_door_addr=$3
        is_use_door_port=$4
        is_add_opts="[port] [remote_addr] [remote_port]"
        ;;
    socks)
        is_socks=1
        is_use_port=$2
        is_use_socks_user=$3
        is_use_socks_pass=$4
        is_add_opts="[port] [username] [password]"
        ;;
    *http)
        is_use_port=$2
        is_add_opts="[port]"
        ;;
    esac

    [[ $1 && ! $is_change ]] && {
        msg "\n使用协议: $is_new_protocol"
        # err msg tips
        is_err_tips="\n\n请使用: $(_green $is_core add $1 $is_add_opts) 来添加 $is_new_protocol 配置"
    }

    # remove old protocol args
    if [[ $is_set_new_protocol ]]; then
        case $is_old_net in
        tcp)
            unset header_type net
            ;;
        kcp | quic)
            kcp_seed=
            [[ $(grep -i tcp <<<$is_new_protocol) ]] && header_type=
            ;;
        h2 | ws | grpc)
            old_host=$host
            if [[ ! $is_use_tls ]]; then
                unset host is_no_auto_tls
            else
                [[ $is_old_net == 'grpc' ]] && {
                    path=/$path
                }
            fi
            [[ ! $(grep -i trojan <<<$is_new_protocol) ]] && is_trojan=
            ;;
        reality)
            [[ ! $(grep -i reality <<<$is_new_protocol) ]] && is_reality=
            ;;
        ss)
            [[ $(is_test uuid $ss_password) ]] && uuid=$ss_password
            ;;
        esac
        [[ $is_dynamic_port && ! $(grep dynamic-port <<<$is_new_protocol) ]] && {
            is_dynamic_port=
        }

        [[ ! $(is_test uuid $uuid) ]] && uuid=
    fi

    # no-auto-tls only use h2,ws,grpc
    if [[ $is_no_auto_tls && ! $is_use_tls ]]; then
        err "$is_new_protocol 不支持手动配置 tls."
    fi

    # prefer args.
    if [[ $2 ]]; then
        for v in is_use_port is_use_uuid is_use_header_type is_use_host is_use_path is_use_pass is_use_method is_use_door_addr is_use_door_port is_use_dynamic_port_start is_use_dynamic_port_end; do
            [[ ${!v} == 'auto' ]] && unset $v
        done

        if [[ $is_use_port ]]; then
            [[ ! $(is_test port ${is_use_port}) ]] && {
                err "($is_use_port) 不是一个有效的端口. $is_err_tips"
            }
            [[ $(is_test port_used $is_use_port) ]] && {
                err "无法使用 ($is_use_port) 端口. $is_err_tips"
            }
            port=$is_use_port
        fi
        if [[ $is_use_door_port ]]; then
            [[ ! $(is_test port ${is_use_door_port}) ]] && {
                err "(${is_use_door_port}) 不是一个有效的目标端口. $is_err_tips"
            }
            door_port=$is_use_door_port
        fi
        if [[ $is_use_uuid ]]; then
            [[ ! $(is_test uuid $is_use_uuid) ]] && {
                err "($is_use_uuid) 不是一个有效的 UUID. $is_err_tips"
            }
            uuid=$is_use_uuid
        fi
        if [[ $is_use_path ]]; then
            [[ ! $(is_test path $is_use_path) ]] && {
                err "($is_use_path) 不是有效的路径. $is_err_tips"
            }
            path=$is_use_path
        fi
        if [[ $is_use_header_type || $is_use_method ]]; then
            is_tmp_use_name=加密方式
            is_tmp_list=${ss_method_list[@]}
            [[ ! $is_use_method ]] && {
                is_tmp_use_name=伪装类型
                ask set_header_type
            }
            for v in ${is_tmp_list[@]}; do
                [[ $(grep -E -i "^${is_use_header_type}${is_use_method}$" <<<$v) ]] && is_tmp_use_type=$v && break
            done
            [[ ! ${is_tmp_use_type} ]] && {
                warn "(${is_use_header_type}${is_use_method}) 不是一个可用的${is_tmp_use_name}."
                msg "${is_tmp_use_name}可用如下: "
                for v in ${is_tmp_list[@]}; do
                    msg "\t\t$v"
                done
                msg "$is_err_tips\n"
                exit 1
            }
            ss_method=$is_tmp_use_type
            header_type=$is_tmp_use_type
        fi
        if [[ $is_dynamic_port && $is_use_dynamic_port_start ]]; then
            get dynamic-port-test
        fi
        [[ $is_use_pass ]] && ss_password=$is_use_pass
        [[ $is_use_host ]] && host=$is_use_host
        [[ $is_use_door_addr ]] && door_addr=$is_use_door_addr
        [[ $is_use_servername ]] && is_servername=$is_use_servername
        [[ $is_use_socks_user ]] && is_socks_user=$is_use_socks_user
        [[ $is_use_socks_pass ]] && is_socks_pass=$is_use_socks_pass
    fi

    if [[ $is_use_tls ]]; then
        if [[ ! $is_no_auto_tls && ! $is_caddy && ! $is_gen ]]; then
            # test auto tls
            [[ $(is_test port_used 80) || $(is_test port_used 443) ]] && {
                get_port
                is_http_port=$tmp_port
                get_port
                is_https_port=$tmp_port
                warn "端口 (80 或 443) 已经被占用, 你也可以考虑使用 no-auto-tls"
                msg "\e[41m no-auto-tls 帮助(help)\e[0m: $(msg_ul https://233boy.com/$is_core/no-auto-tls/)\n"
                msg "\n Caddy 将使用非标准端口实现自动配置 TLS, HTTP:$is_http_port HTTPS:$is_https_port\n"
                msg "请确定是否继续???"
                pause
            }
            is_install_caddy=1
        fi
        # set host
        [[ ! $host ]] && ask string host "请输入域名:"
        # test host dns
        get host-test
    else
        # for main menu start, dont auto create args
        if [[ $is_main_start ]]; then

            # set port
            [[ ! $port ]] && ask string port "请输入端口:"

            case ${is_new_protocol,,} in
            *tcp* | *kcp* | *quic*)
                [[ ! $header_type ]] && ask set_header_type
                ;;
            socks)
                # set user
                [[ ! $is_socks_user ]] && ask string is_socks_user "请设置用户名:"
                # set password
                [[ ! $is_socks_pass ]] && ask string is_socks_pass "请设置密码:"
                ;;
            shadowsocks)
                # set method
                [[ ! $ss_method ]] && ask set_ss_method
                # set password
                [[ ! $ss_password ]] && ask string ss_password "请设置密码:"
                ;;
            esac
            # set dynamic port
            [[ $is_dynamic_port && ! $is_dynamic_port_range ]] && {
                ask string is_use_dynamic_port_start "请输入动态开始端口:"
                ask string is_use_dynamic_port_end "请输入动态结束端口:"
                get dynamic-port-test
            }
        fi
    fi

    # Dokodemo-Door
    if [[ $is_new_protocol == 'Dokodemo-Door' ]]; then
        # set remote addr
        [[ ! $door_addr ]] && ask string door_addr "请输入目标地址:"
        # set remote port
        [[ ! $door_port ]] && ask string door_port "请输入目标端口:"
    fi

    # Shadowsocks 2022
    if [[ $(grep 2022 <<<$ss_method) ]]; then
        # test ss2022 password
        [[ $ss_password ]] && {
            is_test_json=1
            # create server Shadowsocks | $is_core_bin -test &>/dev/null
            create server Shadowsocks
            $is_core_bin -test <<<"$is_new_json" &>/dev/null
            if [[ $? != 0 ]]; then
                warn "Shadowsocks 协议 ($ss_method) 不支持使用密码 ($(_red_bg $ss_password))\n\n你可以使用命令: $(_green $is_core ss2022) 生成支持的密码.\n\n脚本将自动创建可用密码:)"
                ss_password=
                # create new json.
                json_str=
            fi
            is_test_json=
        }

    fi

    # install caddy
    if [[ $is_install_caddy ]]; then
        get install-caddy
    fi

    # create json
    create server $is_new_protocol

    # show config info.
    info
}

# get config info
# or somes required args
get() {
    case $1 in
    addr)
        is_addr=$host
        [[ ! $is_addr ]] && {
            get_ip
            is_addr=$ip
            [[ $(grep ":" <<<$ip) ]] && is_addr="[$ip]"
        }
        ;;
    new)
        [[ ! $host ]] && get_ip
        [[ ! $port ]] && get_port && port=$tmp_port
        [[ ! $uuid ]] && get_uuid && uuid=$tmp_uuid
        ;;
    file)
        is_file_str=$2
        [[ ! $is_file_str ]] && is_file_str='.json$'
        # is_all_json=("$(ls $is_conf_dir | grep -E $is_file_str)")
        readarray -t is_all_json <<<"$(ls $is_conf_dir | grep -E -i "$is_file_str" | sed '/dynamic-port-.*-link/d' | head -233)" # limit max 233 lines for show.
        [[ ! $is_all_json ]] && err "无法找到相关的配置文件: $2"
        [[ ${#is_all_json[@]} -eq 1 ]] && is_config_file=$is_all_json && is_auto_get_config=1
        [[ ! $is_config_file ]] && {
            [[ $is_dont_auto_exit ]] && return
            ask get_config_file
        }
        ;;
    info)
        get file $2
        if [[ $is_config_file ]]; then
            is_json_str=$(cat $is_conf_dir/"$is_config_file")
            is_json_data_base=$(jq '.inbounds[0]|.protocol,.port,.settings.clients[0].id,.settings.clients[0].password,.settings.method,.settings.password,.settings.address,.settings.port,.settings.detour.to,.settings.accounts[0].user,.settings.accounts[0].pass' <<<$is_json_str)
            [[ $? != 0 ]] && err "无法读取此文件: $is_config_file"
            is_json_data_more=$(jq '.inbounds[0]|.streamSettings|.network,.security,.tcpSettings.header.type,.kcpSettings.seed,.kcpSettings.header.type,.quicSettings.header.type,.wsSettings.path,.httpSettings.path,.grpcSettings.serviceName' <<<$is_json_str)
            is_json_data_host=$(jq '.inbounds[0]|.streamSettings|.grpc_host,.wsSettings.headers.Host,.httpSettings.host[0]' <<<$is_json_str)
            is_json_data_reality=$(jq '.inbounds[0]|.streamSettings|.realitySettings.serverNames[0],.realitySettings.publicKey,.realitySettings.privateKey' <<<$is_json_str)
            is_up_var_set=(null is_protocol port uuid trojan_password ss_method ss_password door_addr door_port is_dynamic_port is_socks_user is_socks_pass net is_reality tcp_type kcp_seed kcp_type quic_type ws_path h2_path grpc_path grpc_host ws_host h2_host is_servername is_public_key is_private_key)
            [[ $is_debug ]] && msg "\n------------- debug: $is_config_file -------------"
            i=0
            for v in $(sed 's/""/null/g;s/"//g' <<<"$is_json_data_base $is_json_data_more $is_json_data_host $is_json_data_reality"); do
                ((i++))
                [[ $is_debug ]] && msg "$i-${is_up_var_set[$i]}: $v"
                export ${is_up_var_set[$i]}="${v}"
            done
            for v in ${is_up_var_set[@]}; do
                [[ ${!v} == 'null' ]] && unset $v
            done

            path="${ws_path}${h2_path}${grpc_path}"
            host="${ws_host}${h2_host}${grpc_host}"
            header_type="${tcp_type}${kcp_type}${quic_type}"
            if [[ $is_reality == 'reality' ]]; then
                net=reality
            else
                is_reality=
            fi
            [[ ! $kcp_seed ]] && is_no_kcp_seed=1
            is_config_name=$is_config_file
            if [[ $is_dynamic_port ]]; then
                is_dynamic_port_file=$is_conf_dir/$is_dynamic_port
                is_dynamic_port_range=$(jq -r '.inbounds[0].port' $is_dynamic_port_file)
                [[ $? != 0 ]] && err "无法读取动态端口文件: $is_dynamic_port"
            fi
            if [[ $is_caddy && $host && -f $is_caddy_conf/$host.conf ]]; then
                is_tmp_https_port=$(grep -E -o "$host:[1-9][0-9]?+" $is_caddy_conf/$host.conf | sed s/.*://)
            fi
            if [[ $host && ! -f $is_caddy_conf/$host.conf ]]; then
                is_no_auto_tls=1
            fi
            [[ $is_tmp_https_port ]] && is_https_port=$is_tmp_https_port
            [[ $is_client && $host ]] && port=$is_https_port
            get protocol $is_protocol-$net
        fi
        ;;
    protocol)
        get addr # get host or server ip
        is_lower=${2,,}
        net=
        case $is_lower in
        vmess*)
            is_protocol=vmess
            if [[ $is_dynamic_port ]]; then
                is_server_id_json='settings:{clients:[{id:'\"$uuid\"'}],detour:{to:'\"$is_config_name-link.json\"'}}'
            else
                is_server_id_json='settings:{clients:[{id:'\"$uuid\"'}]}'
            fi
            is_client_id_json='settings:{vnext:[{address:'\"$is_addr\"',port:'"$port"',users:[{id:'\"$uuid\"'}]}]}'
            ;;
        vless*)
            is_protocol=vless
            is_server_id_json='settings:{clients:[{id:'\"$uuid\"'}],decryption:"none"}'
            is_client_id_json='settings:{vnext:[{address:'\"$is_addr\"',port:'"$port"',users:[{id:'\"$uuid\"',encryption:"none"}]}]}'
            if [[ $is_reality ]]; then
                is_server_id_json='settings:{clients:[{id:'\"$uuid\"',flow:"xtls-rprx-vision"}],decryption:"none"}'
                is_client_id_json='settings:{vnext:[{address:'\"$is_addr\"',port:'"$port"',users:[{id:'\"$uuid\"',encryption:"none",flow:"xtls-rprx-vision"}]}]}'
            fi
            ;;
        trojan*)
            is_protocol=trojan
            [[ ! $trojan_password ]] && trojan_password=$uuid
            is_server_id_json='settings:{clients:[{password:'\"$trojan_password\"'}]}'
            is_client_id_json='settings:{servers:[{address:'\"$is_addr\"',port:'"$port"',password:'\"$trojan_password\"'}]}'
            is_trojan=1
            ;;
        shadowsocks*)
            is_protocol=shadowsocks
            net=ss
            [[ ! $ss_method ]] && ss_method=$is_random_ss_method
            [[ ! $ss_password ]] && {
                ss_password=$uuid
                [[ $(grep 2022 <<<$ss_method) ]] && ss_password=$(get ss2022)
            }
            is_client_id_json='settings:{servers:[{address:'\"$is_addr\"',port:'"$port"',method:'\"$ss_method\"',password:'\"$ss_password\"',}]}'
            json_str='settings:{method:'\"$ss_method\"',password:'\"$ss_password\"',network:"tcp,udp"}'
            ;;
        dokodemo-door*)
            is_protocol=dokodemo-door
            net=door
            json_str='settings:{port:'"$door_port"',address:'\"$door_addr\"',network:"tcp,udp"}'
            ;;
        *http*)
            is_protocol=http
            net=http
            json_str='settings:{"timeout": 233}'
            ;;
        *socks*)
            is_protocol=socks
            net=socks
            [[ ! $is_socks_user ]] && is_socks_user=233boy
            [[ ! $is_socks_pass ]] && is_socks_pass=$uuid
            json_str='settings:{auth:"password",accounts:[{user:'\"$is_socks_user\"',pass:'\"$is_socks_pass\"'}],udp:true,ip:"0.0.0.0"}'
            ;;
        *)
            err "无法识别协议: $is_config_file"
            ;;
        esac
        [[ $net ]] && return # if net exist, dont need more json args
        case $is_lower in
        *tcp*)
            net=tcp
            [[ ! $header_type ]] && header_type=none
            is_stream='streamSettings:{network:"tcp",tcpSettings:{header:{type:'\"$header_type\"'}}}'
            json_str=''"$is_server_id_json"','"$is_stream"''
            ;;
        *kcp* | *mkcp)
            net=kcp
            [[ ! $header_type ]] && header_type=$is_random_header_type
            [[ ! $is_no_kcp_seed && ! $kcp_seed ]] && kcp_seed=$uuid
            is_stream='streamSettings:{network:"kcp",kcpSettings:{seed:'\"$kcp_seed\"',header:{type:'\"$header_type\"'}}}'
            json_str=''"$is_server_id_json"','"$is_stream"''
            ;;
        *quic*)
            net=quic
            [[ ! $header_type ]] && header_type=$is_random_header_type
            is_stream='streamSettings:{network:"quic",quicSettings:{header:{type:'\"$header_type\"'}}}'
            json_str=''"$is_server_id_json"','"$is_stream"''
            ;;
        *ws* | *websocket)
            net=ws
            [[ ! $path ]] && path="/$uuid"
            is_stream='streamSettings:{network:"ws",security:'\"$is_tls\"',wsSettings:{path:'\"$path\"',headers:{Host:'\"$host\"'}}}'
            json_str=''"$is_server_id_json"','"$is_stream"''
            ;;
        *grpc* | *gun)
            net=grpc
            [[ ! $path ]] && path="$uuid"
            [[ $path ]] && path=$(sed 's#/##g' <<<$path)
            is_stream='streamSettings:{network:"grpc",grpc_host:'\"$host\"',security:'\"$is_tls\"',grpcSettings:{serviceName:'\"$path\"'}}'
            json_str=''"$is_server_id_json"','"$is_stream"''
            ;;
        *h2* | *http*)
            net=h2
            [[ ! $path ]] && path="/$uuid"
            is_stream='streamSettings:{network:"h2",security:'\"$is_tls\"',httpSettings:{path:'\"$path\"',host:['\"$host\"']}}'
            json_str=''"$is_server_id_json"','"$is_stream"''
            ;;
        *reality*)
            net=reality
            [[ ! $is_servername ]] && is_servername=$is_random_servername
            [[ ! $is_private_key ]] && get_pbk
            is_stream='streamSettings:{network:"tcp",security:"reality",realitySettings:{dest:'\"${is_servername}\:443\"',serverNames:['\"${is_servername}\"',""],publicKey:'\"$is_public_key\"',privateKey:'\"$is_private_key\"',shortIds:[""]}}'
            if [[ $is_client ]]; then
                is_stream='streamSettings:{network:"tcp",security:"reality",realitySettings:{serverName:'\"${is_servername}\"',"fingerprint": "ios",publicKey:'\"$is_public_key\"',"shortId": "","spiderX": "/"}}'
            fi
            json_str=''"$is_server_id_json"','"$is_stream"''
            ;;
        *)
            err "无法识别传输协议: $is_config_file"
            ;;
        esac
        ;;
    dynamic-port) # create random dynamic port
        if [[ $port -ge 60000 ]]; then
            is_dynamic_port_end=$(shuf -i $(($port - 2333))-$port -n1)
            is_dynamic_port_start=$(shuf -i $(($is_dynamic_port_end - 2333))-$is_dynamic_port_end -n1)
        else
            is_dynamic_port_start=$(shuf -i $port-$(($port + 2333)) -n1)
            is_dynamic_port_end=$(shuf -i $is_dynamic_port_start-$(($is_dynamic_port_start + 2333)) -n1)
        fi
        is_dynamic_port_range="$is_dynamic_port_start-$is_dynamic_port_end"
        ;;
    dynamic-port-test) # test dynamic port
        [[ ! $(is_test port ${is_use_dynamic_port_start}) || ! $(is_test port ${is_use_dynamic_port_end}) ]] && {
            err "无法正确处理动态端口 ($is_use_dynamic_port_start-$is_use_dynamic_port_end) 范围."
        }
        [[ $(is_test port_used $is_use_dynamic_port_start) ]] && {
            err "动态端口 ($is_use_dynamic_port_start-$is_use_dynamic_port_end), 但 ($is_use_dynamic_port_start) 端口无法使用."
        }
        [[ $(is_test port_used $is_use_dynamic_port_end) ]] && {
            err "动态端口 ($is_use_dynamic_port_start-$is_use_dynamic_port_end), 但 ($is_use_dynamic_port_end) 端口无法使用."
        }
        [[ $is_use_dynamic_port_end -le $is_use_dynamic_port_start ]] && {
            err "无法正确处理动态端口 ($is_use_dynamic_port_start-$is_use_dynamic_port_end) 范围."
        }
        [[ $is_use_dynamic_port_start == $port || $is_use_dynamic_port_end == $port ]] && {
            err "动态端口 ($is_use_dynamic_port_start-$is_use_dynamic_port_end) 范围和主端口 ($port) 冲突."
        }
        is_dynamic_port_range="$is_use_dynamic_port_start-$is_use_dynamic_port_end"
        ;;
    host-test) # test host dns record; for auto *tls required.
        [[ $is_no_auto_tls || $is_gen ]] && return
        get_ip
        get ping
        if [[ ! $(grep $ip <<<$is_host_dns) ]]; then
            msg "\n请将 ($(_red_bg $host)) 解析到 ($(_red_bg $ip))"
            msg "\n如果使用 Cloudflare, 在 DNS 那; 关闭 (Proxy status / 代理状态), 即是 (DNS only / 仅限 DNS)"
            ask string y "我已经确定解析 [y]:"
            get ping
            if [[ ! $(grep $ip <<<$is_host_dns) ]]; then
                _cyan "\n测试结果: $is_host_dns"
                err "域名 ($host) 没有解析到 ($ip)"
            fi
        fi
        ;;
    ssss | ss2022)
        openssl rand -base64 32
        [[ $? != 0 ]] && err "无法生成 Shadowsocks 2022 密码, 请安装 openssl."
        ;;
    ping)
        # is_ip_type="-4"
        # [[ $(grep ":" <<<$ip) ]] && is_ip_type="-6"
        # is_host_dns=$(ping $host $is_ip_type -c 1 -W 2 | head -1)
        is_dns_type="a"
        [[ $(grep ":" <<<$ip) ]] && is_dns_type="aaaa"
        is_host_dns=$(_wget -qO- --header="accept: application/dns-json" "https://one.one.one.one/dns-query?name=$host&type=$is_dns_type")
        ;;
    log | logerr)
        msg "\n 提醒: 按 $(_green Ctrl + C) 退出\n"
        [[ $1 == 'log' ]] && tail -f $is_log_dir/access.log
        [[ $1 == 'logerr' ]] && tail -f $is_log_dir/error.log
        ;;
    install-caddy)
        _green "\n安装 Caddy 实现自动配置 TLS.\n"
        load download.sh
        download caddy
        load systemd.sh
        install_service caddy &>/dev/null
        is_caddy=1
        _green "安装 Caddy 成功.\n"
        ;;
    reinstall)
        is_install_sh=$(cat $is_sh_dir/install.sh)
        uninstall
        bash <<<$is_install_sh
        ;;
    test-run)
        systemctl list-units --full -all &>/dev/null
        [[ $? != 0 ]] && {
            _yellow "\n无法执行测试, 请检查 systemctl 状态.\n"
            return
        }
        is_no_manage_msg=1
        if [[ ! $(pgrep -f $is_core_bin) ]]; then
            _yellow "\n测试运行 $is_core_name ..\n"
            manage start &>/dev/null
            if [[ $is_run_fail == $is_core ]]; then
                _red "$is_core_name 运行失败信息:"
                $is_core_bin $is_with_run_arg -c $is_config_json -confdir $is_conf_dir
            else
                _green "\n测试通过, 已启动 $is_core_name ..\n"
            fi
        else
            _green "\n$is_core_name 正在运行, 跳过测试\n"
        fi
        if [[ $is_caddy ]]; then
            if [[ ! $(pgrep -f $is_caddy_bin) ]]; then
                _yellow "\n测试运行 Caddy ..\n"
                manage start caddy &>/dev/null
                if [[ $is_run_fail == 'caddy' ]]; then
                    _red "Caddy 运行失败信息:"
                    $is_caddy_bin run --config $is_caddyfile
                else
                    _green "\n测试通过, 已启动 Caddy ..\n"
                fi
            else
                _green "\nCaddy 正在运行, 跳过测试\n"
            fi
        fi
        ;;
    esac
}

# show info
info() {
    if [[ ! $is_protocol ]]; then
        get info $1
    fi
    # is_color=$(shuf -i 41-45 -n1)
    is_color=44
    case $net in
    tcp | kcp | quic)
        is_can_change=(0 1 5 7)
        is_info_show=(0 1 2 3 4 5)
        is_vmess_url=$(jq -c '{v:2,ps:'\"233boy-${net}-$is_addr\"',add:'\"$is_addr\"',port:'\"$port\"',id:'\"$uuid\"',aid:"0",net:'\"$net\"',type:'\"$header_type\"',path:'\"$kcp_seed\"'}' <<<{})
        is_url=vmess://$(echo -n $is_vmess_url | base64 -w 0)
        is_tmp_port=$port
        [[ $is_dynamic_port ]] && {
            is_can_change+=(12)
            is_tmp_port="$port & 动态端口: $is_dynamic_port_range"
        }
        [[ $kcp_seed ]] && {
            is_info_show+=(9)
            is_can_change+=(14)
        }
        is_info_str=($is_protocol $is_addr "$is_tmp_port" $uuid $net $header_type $kcp_seed)
        ;;
    ss)
        is_can_change=(0 1 4 6)
        is_info_show=(0 1 2 10 11)
        is_url="ss://$(echo -n ${ss_method}:${ss_password} | base64 -w 0)@${is_addr}:${port}#233boy-$net-${is_addr}"
        is_info_str=($is_protocol $is_addr $port $ss_password $ss_method)
        ;;
    ws | h2 | grpc)
        is_color=45
        is_can_change=(0 1 2 3 5)
        is_info_show=(0 1 2 3 4 6 7 8)
        is_url_path=path
        [[ $net == 'grpc' ]] && {
            path=$(sed 's#/##g' <<<$path)
            is_url_path=serviceName
        }
        [[ $is_protocol == 'vmess' ]] && {
            is_vmess_url=$(jq -c '{v:2,ps:'\"233boy-$net-$host\"',add:'\"$is_addr\"',port:'\"$is_https_port\"',id:'\"$uuid\"',aid:"0",net:'\"$net\"',host:'\"$host\"',path:'\"$path\"',tls:'\"tls\"'}' <<<{})
            is_url=vmess://$(echo -n $is_vmess_url | base64 -w 0)
        } || {
            [[ $is_trojan ]] && {
                uuid=$trojan_password
                is_can_change=(0 1 2 3 4)
                is_info_show=(0 1 2 10 4 6 7 8)
            }
            is_url="$is_protocol://$uuid@$host:$is_https_port?encryption=none&security=tls&type=$net&host=$host&${is_url_path}=$(sed 's#/#%2F#g' <<<$path)#233boy-$net-$host"
        }
        [[ $is_caddy ]] && is_can_change+=(13)
        is_info_str=($is_protocol $is_addr $is_https_port $uuid $net $host $path 'tls')
        ;;
    reality)
        is_color=41
        is_can_change=(0 1 5 10 11)
        is_info_show=(0 1 2 3 15 8 16 17 18)
        is_info_str=($is_protocol $is_addr $port $uuid xtls-rprx-vision reality $is_servername "ios" $is_public_key)
        is_url="$is_protocol://$uuid@$is_addr:$port?encryption=none&security=reality&flow=xtls-rprx-vision&type=tcp&sni=$is_servername&pbk=$is_public_key&fp=ios#233boy-$net-$is_addr"
        ;;
    door)
        is_can_change=(0 1 8 9)
        is_info_show=(0 1 2 13 14)
        is_info_str=($is_protocol $is_addr $port $door_addr $door_port)
        ;;
    socks)
        is_can_change=(0 1 15 4)
        is_info_show=(0 1 2 19 10)
        is_info_str=($is_protocol $is_addr $port $is_socks_user $is_socks_pass)
        is_url="socks://$(echo -n ${is_socks_user}:${is_socks_pass} | base64 -w 0)@${is_addr}:${port}#233boy-$net-${is_addr}"
        ;;
    http)
        is_can_change=(0 1)
        is_info_show=(0 1 2)
        is_info_str=($is_protocol 127.0.0.1 $port)
        ;;
    esac
    [[ $is_dont_show_info || $is_gen || $is_dont_auto_exit ]] && return # dont show info
    msg "-------------- $is_config_name -------------"
    for ((i = 0; i < ${#is_info_show[@]}; i++)); do
        a=${info_list[${is_info_show[$i]}]}
        if [[ ${#a} -eq 11 || ${#a} -ge 13 ]]; then
            tt='\t'
        else
            tt='\t\t'
        fi
        msg "$a $tt= \e[${is_color}m${is_info_str[$i]}\e[0m"
    done
    if [[ $is_new_install ]]; then
        warn "首次安装请查看脚本帮助文档: $(msg_ul https://233boy.com/$is_core/$is_core-script/)"
    fi
    if [[ $is_url ]]; then
        msg "------------- ${info_list[12]} -------------"
        msg "\e[4;${is_color}m${is_url}\e[0m"
    fi
    if [[ $is_no_auto_tls ]]; then
        is_tmp_path=$path
        [[ $net == 'grpc' ]] && is_tmp_path="/$path/*"
        msg "------------- no-auto-tls INFO -------------"
        msg "端口(port): $port"
        msg "路径(path): $is_tmp_path"
        msg "\e[41m帮助(help)\e[0m: $(msg_ul https://233boy.com/$is_core/no-auto-tls/)"
    fi
    footer_msg
}

# footer msg
footer_msg() {
    [[ $is_core_stop && ! $is_new_json ]] && warn "$is_core_name 当前处于停止状态."
    [[ $is_caddy_stop && $host ]] && warn "Caddy 当前处于停止状态."
    ####### 要点13脸吗只会改我链接的小人 #######
    unset c n m s b
    msg "------------- END -------------"
    msg "关注(tg): $(msg_ul https://t.me/tg2333)"
    msg "文档(doc): $(msg_ul https://233boy.com/$is_core/$is_core-script/)"
    msg "推广(ads): 机场推荐($is_core_name services): $(msg_ul https://g${c}e${n}t${m}j${s}m${b}s.com/)\n"
    ####### 要点13脸吗只会改我链接的小人 #######
}

# URL or qrcode
url_qr() {
    is_dont_show_info=1
    info $2
    if [[ $is_url ]]; then
        [[ $1 == 'url' ]] && {
            msg "\n------------- $is_config_name & URL 链接 -------------"
            msg "\n\e[${is_color}m${is_url}\e[0m\n"
            footer_msg
        } || {
            link="https://233boy.github.io/tools/qr.html#${is_url}"
            msg "\n------------- $is_config_name & QR code 二维码 -------------"
            msg
            if [[ $(type -P qrencode) ]]; then
                qrencode -t ANSI "${is_url}"
            else
                msg "请安装 qrencode: $(_green "$cmd update -y; $cmd install qrencode -y")"
            fi
            msg
            msg "如果无法正常显示或识别, 请使用下面的链接来生成二维码:"
            msg "\n\e[4;${is_color}m${link}\e[0m\n"
            footer_msg
        }
    else
        [[ $1 == 'url' ]] && {
            err "($is_config_name) 无法生成 URL 链接."
        } || {
            err "($is_config_name) 无法生成 QR code 二维码."
        }
    fi
}

# update core, sh, caddy
update() {
    case $1 in
    1 | core | $is_core)
        is_update_name=core
        is_show_name=$is_core_name
        is_run_ver=v${is_core_ver##* }
        is_update_repo=$is_core_repo
        ;;
    2 | sh)
        is_update_name=sh
        is_show_name="$is_core_name 脚本"
        is_run_ver=$is_sh_ver
        is_update_repo=$is_sh_repo
        ;;
    3 | caddy)
        [[ ! $is_caddy ]] && err "不支持更新 Caddy."
        is_update_name=caddy
        is_show_name="Caddy"
        is_run_ver=$is_caddy_ver
        is_update_repo=$is_caddy_repo
        ;;
    *)
        err "无法识别 ($1), 请使用: $is_core update [core | sh | caddy] [ver]"
        ;;
    esac
    [[ $2 ]] && is_new_ver=v${2#v}
    [[ $is_run_ver == $is_new_ver ]] && {
        msg "\n自定义版本和当前 $is_show_name 版本一样, 无需更新.\n"
        exit
    }
    load download.sh
    if [[ $is_new_ver ]]; then
        msg "\n使用自定义版本更新 $is_show_name: $(_green $is_new_ver)\n"
    else
        get_latest_version $is_update_name
        [[ $is_run_ver == $latest_ver ]] && {
            msg "\n$is_show_name 当前已经是最新版本了.\n"
            exit
        }
        msg "\n发现 $is_show_name 新版本: $(_green $latest_ver)\n"
        is_new_ver=$latest_ver
    fi
    download $is_update_name $is_new_ver
    msg "更新成功, 当前 $is_show_name 版本: $(_green $is_new_ver)\n"
    msg "$(_green 请查看更新说明: https://github.com/$is_update_repo/releases/tag/$is_new_ver)\n"
    [[ $is_update_name == 'core' ]] && $is_core restart
    [[ $is_update_name == 'caddy' ]] && manage restart $is_update_name &
}

# main menu; if no prefer args.
is_main_menu() {
    msg "\n------------- $is_core_name script $is_sh_ver by $author -------------"
    msg "$is_core_ver: $is_core_status"
    msg "群组 (Chat): $(msg_ul https://t.me/tg233boy)"
    is_main_start=1
    ask mainmenu
    case $REPLY in
    1)
        add
        ;;
    2)
        change
        ;;
    3)
        info
        ;;
    4)
        del
        ;;
    5)
        ask list is_do_manage "启动 停止 重启"
        manage $REPLY &
        msg "\n管理状态执行: $(_green $is_do_manage)\n"
        ;;
    6)
        is_tmp_list=("更新$is_core_name" "更新脚本")
        [[ $is_caddy ]] && is_tmp_list+=("更新Caddy")
        ask list is_do_update null "\n请选择更新:\n"
        update $REPLY
        ;;
    7)
        uninstall
        ;;
    8)
        msg
        load help.sh
        show_help
        ;;
    9)
        ask list is_do_other "启用BBR 查看日志 查看错误日志 测试运行 重装脚本 设置DNS"
        case $REPLY in
        1)
            load bbr.sh
            _try_enable_bbr
            ;;
        2)
            get log
            ;;
        3)
            get logerr
            ;;
        4)
            get test-run
            ;;
        5)
            get reinstall
            ;;
        6)
            load dns.sh
            dns_set
            ;;
        esac
        ;;
    10)
        load help.sh
        about
        ;;
    esac
}

# check prefer args, if not exist prefer args and show main menu
main() {
    case $1 in
    a | add | gen | no-auto-tls)
        [[ $1 == 'gen' ]] && is_gen=1
        [[ $1 == 'no-auto-tls' ]] && is_no_auto_tls=1
        add ${@:2}
        ;;
    api | bin | convert | tls | run | uuid)
        [[ $is_core_ver_lt_5 ]] && {
            warn "$is_core_ver 版本不支持使用命令. 请升级内核版本: $is_core update core"
            return
        }
        is_run_command=$1
        if [[ $1 == 'bin' ]]; then
            $is_core_bin ${@:2}
        else
            # [[ $is_run_command == 'pbk' ]] && is_run_command=x25519
            $is_core_bin $is_run_command ${@:2}
        fi
        ;;
    bbr)
        load bbr.sh
        _try_enable_bbr
        ;;
    c | config | change)
        change ${@:2}
        ;;
    client | genc)
        [[ $1 == 'client' ]] && is_full_client=1
        create client $2
        ;;
    d | del | rm)
        del $2
        ;;
    dd | ddel | fix | fix-all)
        case $1 in
        fix)
            [[ $2 ]] && {
                change $2 full
            } || {
                is_change_id=full && change
            }
            return
            ;;
        fix-all)
            is_dont_auto_exit=1
            msg
            for v in $(ls $is_conf_dir | grep .json$ | sed '/dynamic-port-.*-link/d'); do
                msg "fix: $v"
                change $v full
            done
            _green "\nfix 完成.\n"
            ;;
        *)
            is_dont_auto_exit=1
            [[ ! $2 ]] && {
                err "无法找到需要删除的参数"
            } || {
                for v in ${@:2}; do
                    del $v
                done
            }
            ;;
        esac
        is_dont_auto_exit=
        [[ $is_api_fail ]] && manage restart &
        [[ $is_del_host ]] && manage restart caddy &
        ;;
    dns)
        load dns.sh
        dns_set ${@:2}
        ;;
    debug)
        is_debug=1
        get info $2
        warn "如果需要复制; 请把 *uuid, *password, *host, *key 的值改写, 以避免泄露."
        ;;
    fix-config.json)
        create config.json
        ;;
    fix-caddyfile)
        if [[ $is_caddy ]]; then
            load caddy.sh
            caddy_config new
            manage restart caddy &
            _green "\nfix 完成.\n"
        else
            err "无法执行此操作"
        fi
        ;;
    i | info)
        info $2
        ;;
    ip)
        get_ip
        msg $ip
        ;;
    log | logerr | errlog)
        load log.sh
        log_set $@
        ;;
    url | qr)
        url_qr $@
        ;;
    un | uninstall)
        uninstall
        ;;
    u | up | update | U | update.sh)
        is_update_name=$2
        is_update_ver=$3
        [[ ! $is_update_name ]] && is_update_name=core
        [[ $1 == 'U' || $1 == 'update.sh' ]] && {
            is_update_name=sh
            is_update_ver=
        }
        if [[ $2 == 'dat' ]]; then
            load download.sh
            download dat
            msg "$(_green 更新 geoip.dat geosite.dat 成功.)\n"
            manage restart &
        else
            update $is_update_name $is_update_ver
        fi
        ;;
    ssss | ss2022)
        get $@
        ;;
    s | status)
        msg "\n$is_core_ver: $is_core_status\n"
        [[ $is_caddy ]] && msg "Caddy $is_caddy_ver: $is_caddy_status\n"
        ;;
    start | stop | r | restart)
        [[ $2 && $2 != 'caddy' ]] && err "无法识别 ($2), 请使用: $is_core $1 [caddy]"
        manage $1 $2 &
        ;;
    t | test)
        get test-run
        ;;
    reinstall)
        get $1
        ;;
    get-port)
        get_port
        msg $tmp_port
        ;;
    main)
        is_main_menu
        ;;
    v | ver | version)
        [[ $is_caddy_ver ]] && is_caddy_ver="/ $(_blue Caddy $is_caddy_ver)"
        msg "\n$(_green $is_core_ver) / $(_cyan $is_core_name script $is_sh_ver) $is_caddy_ver\n"
        ;;
    xapi)
        api ${@:2}
        ;;
    h | help | --help)
        load help.sh
        show_help ${@:2}
        ;;
    *)
        is_try_change=1
        change test $1
        if [[ $is_change_id ]]; then
            unset is_try_change
            [[ $2 ]] && {
                change $2 $1 ${@:3}
            } || {
                change
            }
        else
            err "无法识别 ($1), 获取帮助请使用: $is_core help"
        fi
        ;;
    esac
}
