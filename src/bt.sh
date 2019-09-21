_ban_bt_main() {
	if [[ $ban_bt ]]; then
		local _info="$green已开启$none"
	else
		local _info="$red已关闭$none"
	fi
	_opt=''
	while :; do
		echo
		echo -e "$yellow 1. $none开启 BT 屏蔽"
		echo
		echo -e "$yellow 2. $none关闭 BT 屏蔽"
		echo
		echo -e "当前 BT 屏蔽状态: $_info"
		echo
		read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" _opt
		if [[ -z $_opt ]]; then
			error
		else
			case $_opt in
			1)
				if [[ $ban_bt ]]; then
					echo
					echo -e " 大胸弟...难不成你没有看到 (当前 BT 屏蔽状态: $_info) 这个帅帅的提示么.....还开启个鸡鸡哦"
					echo
				else
					echo
					echo
					echo -e "$yellow  BT 屏蔽 = $cyan开启$none"
					echo "----------------------------------------------------------------"
					echo
					pause
					backup_config +bt
					ban_bt=true
					config
					echo
					echo
					echo -e "$green  BT 屏蔽已开启...如果出现异常..那就关闭它咯$none"
					echo
				fi
				break
				;;
			2)
				if [[ $ban_bt ]]; then
					echo
					echo
					echo -e "$yellow  BT 屏蔽 = $cyan关闭$none"
					echo "----------------------------------------------------------------"
					echo
					pause
					backup_config -bt
					ban_bt=''
					config
					echo
					echo
					echo -e "$red  BT 屏蔽已关闭...不过你也可以随时重新开启 ...只要你喜欢$none"
					echo
				else
					echo
					echo -e " 大胸弟...难不成你没有看到 (当前 BT 屏蔽状态: $_info) 这个帅帅的提示么.....还关闭个鸡鸡哦"
					echo
				fi
				break
				;;
			*)
				error
				;;
			esac
		fi
	done
}
