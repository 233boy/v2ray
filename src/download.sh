get_latest_version() {
    case $1 in
    core)
        name=$is_core_name
        url="https://api.github.com/repos/${is_core_repo}/releases/latest?v=$RANDOM"
        ;;
    sh)
        name="$is_core_name 脚本"
        url="https://api.github.com/repos/$is_sh_repo/releases/latest?v=$RANDOM"
        ;;
    caddy)
        name="Caddy"
        url="https://api.github.com/repos/$is_caddy_repo/releases/latest?v=$RANDOM"
        ;;
    esac
    latest_ver=$(_wget -qO- $url | grep tag_name | egrep -o 'v([0-9.]+)')
    [[ ! $latest_ver ]] && {
        err "Obtain ${name} Latest version failed."
    }
    unset name url
}
download() {
    latest_ver=$2
    [[ ! $latest_ver ]] && get_latest_version $1
    # tmp dir
    tmpdir=$(mktemp -u)
    [[ ! $tmpdir ]] && {
        tmpdir=/tmp/tmp-$RANDOM
    }
    mkdir -p $tmpdir
    case $1 in
    core)
        name=$is_core_name
        tmpfile=$tmpdir/$is_core.zip
        link="https://github.com/${is_core_repo}/releases/download/${latest_ver}/${is_core}-linux-${is_core_arch}.zip"
        download_file
        unzip -qo $tmpfile -d $is_core_dir/bin
        chmod +x $is_core_bin
        ;;
    sh)
        name="$is_core_name Script"
        tmpfile=$tmpdir/sh.zip
        link="https://github.com/${is_sh_repo}/releases/download/${latest_ver}/code.zip"
        download_file
        unzip -qo $tmpfile -d $is_sh_dir
        chmod +x $is_sh_bin
        ;;
    caddy)
        name="Caddy"
        tmpfile=$tmpdir/caddy.tar.gz
        # https://github.com/caddyserver/caddy/releases/download/v2.6.4/caddy_2.6.4_linux_amd64.tar.gz
        link="https://github.com/${is_caddy_repo}/releases/download/${latest_ver}/caddy_${latest_ver:1}_linux_${caddy_arch}.tar.gz"
        download_file
        [[ ! $(type -P tar) ]] && {
            rm -rf $tmpdir
            err "Please install tar"
        }
        tar zxf $tmpfile -C $tmpdir
        cp -f $tmpdir/caddy $is_caddy_bin
        chmod +x $is_caddy_bin
        ;;
    esac
    rm -rf $tmpdir
    unset latest_ver
}
download_file() {
    if ! _wget -t 5 -c $link -O $tmpfile; then
        rm -rf $tmpdir
        err "\n download ${name} failed.\n"
    fi
}
