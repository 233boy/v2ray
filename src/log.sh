is_log_level_list=(
    debug
    info
    warning
    error
    none
    del
)
log_set() {
    if [[ $2 ]]; then
        for v in ${is_log_level_list[@]}; do
            [[ $(grep -E -i "^${2,,}$" <<<$v) ]] && is_log_level_use=$v && break
        done
        [[ ! $is_log_level_use ]] && {
            err "无法识别 log 参数: $@ \n请使用 $is_core log [${is_log_level_list[@]}] 进行相关设定.\n备注: del 参数仅临时删除 log 文件; none 参数将不会生成 log 文件."
        }
        case $is_log_level_use in
        del)
            rm -rf $is_log_dir/*.log
            msg "\n $(_green 已临时删除 log 文件, 如果你想要完全禁止生成 log 文件请使用: $is_core log none)\n"
            ;;
        none)
            rm -rf $is_log_dir/*.log
            cat <<<$(jq '.log={"loglevel":"none"}' $is_config_json) >$is_config_json
            ;;
        *)
            cat <<<$(jq '.log={access:"/var/log/'$is_core'/access.log",error:"/var/log/'$is_core'/error.log",loglevel:"'$is_log_level_use'"}' $is_config_json) >$is_config_json
            ;;
        esac

        manage restart &
        [[ $2 != 'del' ]] && msg "\n已更新 Log 设定为: $(_green $is_log_level_use)\n"
    else
        case $1 in
        log)
            if [[ -f $is_log_dir/access.log ]]; then
                msg "\n 提醒: 按 $(_green Ctrl + C) 退出\n"
                tail -f $is_log_dir/access.log
            else
                err "无法找到 log 文件."
            fi
            ;;
        *)
            if [[ -f $is_log_dir/error.log ]]; then
                msg "\n 提醒: 按 $(_green Ctrl + C) 退出\n"
                tail -f $is_log_dir/error.log
            else
                err "无法找到 log 文件."
            fi
            ;;
        esac

    fi
}