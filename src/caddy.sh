caddy_config() {
    is_caddy_site_file=$is_caddy_conf/${host}.conf
    case $1 in
    new)
        mkdir -p $is_caddy_dir $is_caddy_dir/sites $is_caddy_conf
        cat >$is_caddyfile <<-EOF
# don't edit this file #
# for more info, see https://233boy.com/$is_core/caddy-auto-tls/
# 不要编辑这个文件 #
# 更多相关请阅读此文章: https://233boy.com/$is_core/caddy-auto-tls/
# https://caddyserver.com/docs/caddyfile/options
{
  admin off
  http_port $is_http_port
  https_port $is_https_port
}
import $is_caddy_conf/*.conf
import $is_caddy_dir/sites/*.conf
EOF
        ;;
    *ws*)
        cat >${is_caddy_site_file} <<<"
${host}:${is_https_port} {
    reverse_proxy ${path} 127.0.0.1:${port}
    import ${is_caddy_site_file}.add
}"
        ;;
    *h2*)
        cat >${is_caddy_site_file} <<<"
${host}:${is_https_port} {
    reverse_proxy ${path} h2c://127.0.0.1:${port}
    import ${is_caddy_site_file}.add
}"
        ;;
    *grpc*)
        cat >${is_caddy_site_file} <<<"
${host}:${is_https_port} {
    reverse_proxy /${path}/* h2c://127.0.0.1:${port}
    import ${is_caddy_site_file}.add
}"
        ;;
    proxy)
        
        cat >${is_caddy_site_file}.add <<<"
reverse_proxy https://$proxy_site {
        header_up Host {upstream_hostport}
}"
        ;;
    ip)
        # site block only used to trigger ACME for this host's IP.
        # IP certificates are only issued under Let's Encrypt's "shortlived"
        # profile (Caddy >= 2.10.0).
        is_caddy_addr=$host
        [[ $(grep : <<<$host) ]] && is_caddy_addr="[$host]"
        cat >${is_caddy_site_file} <<<"
${is_caddy_addr}:${is_https_port} {
    tls {
        issuer acme {
            profile shortlived
        }
    }
    respond \"233boy IP\"
}"
        ;;
    esac
    [[ $1 != "new" && $1 != 'proxy' && $1 != 'ip' ]] && {
        [[ ! -f ${is_caddy_site_file}.add ]] && echo "# see https://233boy.com/$is_core/caddy-auto-tls/" >${is_caddy_site_file}.add
    }
}
