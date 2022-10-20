_ban_bt_main() {
	if [[ $ban_bt ]]; then
		local _info="$green ativado$none"
	else
		local _info="$red desativado$none"
	fi
	_opt=''
	while :; do
		echo
		echo -e "$yellow 1. $none Ative o bloqueio de BT"
		echo
		echo -e "$yellow 2. $none Desligue o bloqueio de BT"
		echo
		echo -e "Status atual de bloqueio de BT: $_info"
		echo
		read -p "$(echo -e "por favor escolha [${magenta}1-2$none]:")" _opt
		if [[ -z $_opt ]]; then
			error
		else
			case $_opt in
			1)
				if [[ $ban_bt ]]; then
					echo
					echo -e " Peitos grandes... É possível que você não tenha visto (status atual de BT bloqueado: $_info) este belo lembrete...
					echo
				else
					echo
					echo
					echo -e "$yellow  escudo BT = $cyan ligar$none"
					echo "----------------------------------------------------------------"
					echo
					pause
					backup_config +bt
					ban_bt=true
					config
					echo
					echo
					echo -e "$green O bloqueio de BT está ativado... se algo der errado... desligue-o$none"
					echo
				fi
				break
				;;
			2)
				if [[ $ban_bt ]]; then
					echo
					echo
					echo -e "$yellow  escudo BT = $cyan desligar$none"
					echo "----------------------------------------------------------------"
					echo
					pause
					backup_config -bt
					ban_bt=''
					config
					echo
					echo
					echo -e "$red  O bloqueio de BT está desativado... mas você sempre pode ativá-lo novamente... se quiser$none"
					echo
				else
					echo
					echo -e " Peitos grandes... Será que você não viu (status atual de BT bloqueado: $_info) este belo lembrete... e feche o pau."
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
