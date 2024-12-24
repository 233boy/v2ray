show_help() {
    case $1 in
    api | convert | tls | run | uuid | version)
        $is_core_bin help $1 ${@:2}
        ;;
    *)
        [[ $1 ]] && warn "未知选项 '$1'"
        msg "$is_core_name script $is_sh_ver by $author"
        msg "Usage: $is_core [options]... [args]... "
        msg
        help_info=(
            "基本:"
            "   v, version                                      显示当前版本"
            "   ip                                              返回当前主机的 IP"
            # "   pbk                                             同等于 $is_core x25519"
            "   get-port                                        返回一个可用的端口\n"
            # "   ss2022                                          返回一个可用于 Shadowsocks 2022 的密码\n"
            "一般:"
            "   a, add [protocol] [args... | auto]              添加配置"
            "   c, change [name] [option] [args... | auto]      更改配置"
            "   d, del [name]                                   删除配置**"
            "   i, info [name]                                  查看配置"
            "   qr [name]                                       二维码信息"
            "   url [name]                                      URL 信息"
            "   log                                             查看日志"
            "   logerr                                          查看错误日志\n"
            "更改:"
            "   dp, dynamicport [name] [start | auto] [end]     更改动态端口"
            "   full [name] [...]                               更改多个参数"
            "   id [name] [uuid | auto]                         更改 UUID"
            "   host [name] [domain]                            更改域名"
            "   port [name] [port | auto]                       更改端口"
            "   path [name] [path | auto]                       更改路径"
            "   passwd [name] [password | auto]                 更改密码"
            # "   key [name] [Private key | atuo] [Public key]    更改密钥"
            "   type [name] [type | auto]                       更改伪装类型"
            "   method [name] [method | auto]                   更改加密方式"
            # "   sni [name] [ ip | domain]                       更改 serverName"
            "   seed [name] [seed | auto]                       更改 mKCP seed"
            "   new [name] [...]                                更改协议"
            "   web [name] [domain]                             更改伪装网站\n"
            "进阶:"
            "   dns [...]                                       设置 DNS"
            "   dd, ddel [name...]                              删除多个配置**"
            "   fix [name]                                      修复一个配置"
            "   fix-all                                         修复全部配置"
            "   fix-caddyfile                                   修复 Caddyfile"
            "   fix-config.json                                 修复 config.json\n"
            "管理:"
            "   un, uninstall                                   卸载"
            "   u, update [core | sh | dat | caddy] [ver]       更新"
            "   U, update.sh                                    更新脚本"
            "   s, status                                       运行状态"
            "   start, stop, restart [caddy]                    启动, 停止, 重启"
            "   t, test                                         测试运行"
            "   reinstall                                       重装脚本\n"
            "测试:"
            "   client [name]                                   显示用于客户端 JSON, 仅供参考"
            "   debug [name]                                    显示一些 debug 信息, 仅供参考"
            "   gen [...]                                       同等于 add, 但只显示 JSON 内容, 不创建文件, 测试使用"
            "   genc [name]                                     显示用于客户端部分 JSON, 仅供参考"
            "   no-auto-tls [...]                               同等于 add, 但禁止自动配置 TLS, 可用于 *TLS 相关协议"
            "   xapi [...]                                      同等于 $is_core api, 但 API 后端使用当前运行的 $is_core_name 服务\n"
            "其他:"
            "   bbr                                             启用 BBR, 如果支持"
            "   bin [...]                                       运行 $is_core_name 命令, 例如: $is_core bin help"
            "   api, convert, tls, run, uuid  [...]             兼容 $is_core_name 命令"
            "   h, help                                         显示此帮助界面\n"
        )
        for v in "${help_info[@]}"; do
            msg "$v"
        done
        msg "谨慎使用 del, ddel, 此选项会直接删除配置; 无需确认"
        msg "反馈问题) $(msg_ul https://github.com/${is_sh_repo}/issues) "
        msg "文档(doc) $(msg_ul https://233boy.com/$is_core/$is_core-script/)"
        ;;

    esac
}

about() {
    ####### 要点13脸吗只会改我链接的小人 #######
    unset c n m s b
    msg
    msg "网站: $(msg_ul https://233boy.com)"
    msg "频道: $(msg_ul https://t.me/tg2333)"
    msg "群组: $(msg_ul https://t.me/tg233boy)"
    msg "Github: $(msg_ul https://github.com/${is_sh_repo})"
    msg "Twitter: $(msg_ul https://twitter.com/ai233boy)"
    msg "$is_core_name site: $(msg_ul https://www.v2fly.org)"
    msg "$is_core_name core: $(msg_ul https://github.com/${is_core_repo})"
    msg
    ####### 要点13脸吗只会改我链接的小人 #######
}
