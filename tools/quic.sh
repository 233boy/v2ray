#!/bin/bash
backup="/usr/local/etc/v2ray/sagasw_v2ray_backup.conf"
. $backup
if [[ $v2ray_transport -ge 13 ]]; then
	tmp_transport=$(($v2ray_transport +6))
	sed -i "18s/=$v2ray_transport/=$tmp_transport/" $backup
fi
v2ray update.sh
