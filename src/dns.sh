is_dns_list=(
    1.1.1.1
    8.8.8.8
    https://dns.google/dns-query
    https://cloudflare-dns.com/dns-query
    https://family.cloudflare-dns.com/dns-query
    set
    none
)
dns_set() {
    if [[ $1 ]]; then
        case ${1,,} in
        11 | 1111)
            is_dns_use=${is_dns_list[0]}
            ;;
        88 | 8888)
            is_dns_use=${is_dns_list[1]}
            ;;
        gg | google)
            is_dns_use=${is_dns_list[2]}
            ;;
        cf | cloudflare)
            is_dns_use=${is_dns_list[3]}
            ;;
        nosex | family)
            is_dns_use=${is_dns_list[4]}
            ;;
        set)
            if [[ $2 ]]; then
                is_dns_use=${2,,}
            else
                ask string is_dns_use "请输入 DNS: "
            fi
            ;;
        none)
            is_dns_use=none
            ;;
        *)
            err "无法识别 DNS 参数: $@"
            ;;
        esac
    else
        is_tmp_list=(${is_dns_list[@]})
        ask list is_dns_use null "\n请选择 DNS:\n"
        if [[ $is_dns_use == "set" ]]; then
            ask string is_dns_use "请输入 DNS: "
        fi
    fi
    if [[ $is_dns_use == "none" ]]; then
        cat <<<$(jq '.dns={}' $is_config_json) >$is_config_json
    else
        cat <<<$(jq '.dns.servers=["'${is_dns_use/https/https+local}'"]' $is_config_json) >$is_config_json
    fi
    manage restart &
    msg "\n已更新 DNS 为: $(_green $is_dns_use)\n"
}