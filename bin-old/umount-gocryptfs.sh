#!/usr/bin/env bash

crypt_dir="${HOME}/cryptfs"
cd "${crypt_dir}"

for mountpoint in *-plain
do
	name="${mountpoint%-*}"
	echo "==================== ${mountpoint} ===================="
	if [[ `uname -s` = 'Darwin' ]]
	then
		# MacOS does not have `mountpoint`. Assume it is not mounted.
		if mount | grep -q "${crypt_dir}/${mountpoint}"
		then
			echo "Unmounting ${mountpoint}"
			umount "${crypt_dir}/${mountpoint}"
		fi
	else
		if mountpoint "${crypt_dir}/${mountpoint}"
		then
			echo "Unmounting ${mountpoint}"
			fusermount -u "${crypt_dir}/${mountpoint}"
		fi
	fi

done

