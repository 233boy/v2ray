
_V2CTL=/usr/bin/v2ray/v2ctl
_APISERVER=127.0.0.1:10086

v2_inbound() {
    local inbound=$1
    local direct=$2
    $_V2CTL api --server=$_APISERVER StatsService.GetStats "name: \"inbound>>>${inbound}>>>traffic>>>${direct}\"" \
    | awk '{
        if (match($1, /name:/)){ f=1; gsub(/"$/, "", $2); split($2, p,  ">>>"); print p[2]":"p[4] }
        else if (match($1, /value:/)){ f=0; print $2}
        else if (match($0, /^>$/) && f == 1) print "0"
        else {}
    }' \
    | sed '$!N;s/\n/ /; s/link//' \
    | numfmt --field=2 --suffix=B --to=iec \
    | sort \
    | column -t
}

v2_query_all () {
    $_V2CTL api --server=$_APISERVER StatsService.QueryStats '' \
    | awk '{
        if (match($1, /name:/)){ f=1; gsub(/"$/, "", $2); split($2, p,  ">>>"); print p[2]":"p[4] }
        else if (match($1, /value:/)){ f=0; print $2}
        else if (match($0, /^>$/) && f == 1) print "0"
        else {}
    }' \
    | sed '$!N;s/\n/ /; s/link//' \
    | numfmt --field=2 --suffix=B --to=iec \
    | sort \
    | column -t
}
