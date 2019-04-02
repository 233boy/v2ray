__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

_jqArch="linux32"
if [[ $sys_bit == "x86_64" ]]; then
    _jqArch="linux64"
fi

if [[ ! $(command -v jq) ]]; then
    echo
    _green "检测到没有 jq 命令，正在自动安装..."
    echo

    if [[ $cmd == "apt-get" ]]; then
        $cmd install -y jq
    else
        pushd /tmp
        if curl -sL -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-${_jqArch}; then
            install -m 755 jq /usr/local/bin/
            rm -f jq
        else
            echo
            _red "安装 jq 失败..."
            echo
            exit 1
        fi
        popd
    fi
fi

if [[ ! $(command -v patch) && $(command -v diff) ]]; then
    echo
    _green "检测到没有patch命令，正在自动安装..."
    echo
    $cmd install -y patch diffutils
fi

if [[ ! $(command -v patch) && $(command -v diff) ]]; then
    echo
    _red "diff/patch not found"
    echo
    exit 1
fi

TMP_ORIG_JSON=$(mktemp --suffix=.json)
TMP_UPDT_JSON=$(mktemp --suffix=.json)
CMPATCH=$(mktemp --suffix=.patch)

jq_gen_json() {
    sed '/ *\/\//d' $v2ray_server_config >$TMP_ORIG_JSON
}

jq_gen_jsonpatch() {
    jq_gen_json
    diff -u $TMP_ORIG_JSON $v2ray_server_config >$CMPATCH
}

jq_clear_tmp() {
    rm -f $TMP_ORIG_JSON $TMP_UPDT_JSON $CMPATCH
}

jq_vmess_adduser() {
    local uuid=$1
    local alterId=${2:-64}
    local email=${3:-${uuid:30}@233}
    local level=1
    local client='{"id":"'${uuid}'","level":'${level}',"alterId":'${alterId}',"email":"'${email}'"}'
    local len_inbounds=$(jq '(.inbounds|length) - 1' $TMP_ORIG_JSON)
    local _IDX
    for _IDX in $(seq 0 ${len_inbounds}); do
        if [[ $(jq ".inbounds[${_IDX}].protocol" $TMP_ORIG_JSON) == '"vmess"' ]]; then
            break
        fi
    done

    if [[ $(jq ".inbounds[${_IDX}].protocol" $TMP_ORIG_JSON) != '"vmess"' ]]; then
        _red "vmess not found"
        return 1
    fi

    jq --tab ".inbounds[${_IDX}].settings.clients += [${client}]" $TMP_ORIG_JSON >$TMP_UPDT_JSON
}

jq_patchback() {
    if patch --ignore-whitespace $TMP_UPDT_JSON <$CMPATCH; then
        mv $v2ray_server_config "${v2ray_server_config}.bak.${RANDOM}"
        install -m 644 $TMP_UPDT_JSON $v2ray_server_config
    fi
}

jq_printvmess() {
    local ADDRESS=${1:-SERVER_IP}
    local _MAKPREFIX=${2:-233}
    local INPUT=$TMP_ORIG_JSON
    [[ -s $TMP_UPDT_JSON ]] && INPUT=$TMP_UPDT_JSON

    local INBS=$(jq -c '.inbounds[] | select(.protocol == "vmess" )' $INPUT)
    for IN in $INBS; do
        local _TYPE="\"none\""
        local _HOST=\"\"
        local _PATH=\"\"
        local _TLS=\"\"
        local _NET=$(echo $IN | jq 'if (.streamSettings.network | length) > 0 then .streamSettings.network else "tcp" end')
        local _PORT=$(echo $IN | jq '.port')
        local _NETTRIM=${_NET//\"/}
        echo
        echo "--------------------------  Server: ${ADDRESS}:${_PORT}/${_NETTRIM}   --------------------------"
        echo
        case $_NETTRIM in
        kcp)
            _TYPE='.streamSettings.kcpSettings.header.type'
            ;;
        ws)
            _HOST='.streamSettings.wsSettings.headers.Host'
            _PATH='.streamSettings.wsSettings.path'
            ;;
        h2 | http)
            _HOST='.streamSettings.httpSettings.host|join(,)'
            _PATH='.streamSettings.httpSettings.path'
            _TLS="tls"
            ;;
        tcp)
            _TYPE='.streamSettings.tcpSettings.header.type|"none"'
            ;;
        quic)
            _TYPE='.streamSettings.quicSettings.header.type|"none"'
            _HOST='.streamSettings.quicSettings.security'
            _PATH='.streamSettings.quicSettings.key'
            ;;
        esac
        local CLTLEN=$(echo $IN | jq '.settings.clients|length - 1')
        for CLINTIDX in $(seq 0 $CLTLEN); do
            local EMAIL=$(echo $IN | jq 'if .settings.clients['${CLINTIDX}'].email then .settings.clients['${CLINTIDX}'].email else "DEFAULT" end')
            local _ps="${_MAKPREFIX}${ADDRESS}/${_NETTRIM}"
            local _VMESS=$(echo "vmess://"$(echo $IN | jq -c '{"v":"2","ps":"'${_ps}'","add":"'${ADDRESS}'","port":.port,"id":.settings.clients['${CLINTIDX}'].id,"aid":.settings.clients['${CLINTIDX}'].alterId,"net":'${_NET}',"type":'${_TYPE}',"host":'${_HOST}',"path":'${_PATH}',"tls":'${_TLS}'}' | base64 -w0))
            _green "VMESS链接（v2rayN/v2rayNG）: ${EMAIL//\"/}"
            echo
            _cyan "${_VMESS}"
            echo
            _green "二维码链接【浏览器打开】（v2rayN/v2rayNG）"
            echo
            _cyan "https://233boy.github.io/tools/qr.html#${_VMESS}"
            echo
        done
    done
}
