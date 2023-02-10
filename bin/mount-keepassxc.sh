#!/usr/bin/env bash

# Mount the encrypted containers for KeePassXC and the Vault (KeePassXC file).
# 2020-08-31: Added -sharedstorage option to prevent inode collisions
# 2018-09-23: KeePass is no longer encrypted.
# See https://github.com/keepassxreboot/keepassxc/issues/2312

crypt_dir="${HOME}/cryptfs"
cd "${crypt_dir}"

#read -p "Please enter the password: " -s password
#echo
#
#keyfile="/tmp/keyfile.luks"
#touch "${keyfile}"
#chmod go-rwx "${keyfile}"
#echo -n $password > "${keyfile}"

# This prevents an error due to inode conflicts
options="-sharedstorage"

for mountpoint in niceguyit.biz-vault-crypt
do
	name="${mountpoint%-*}"
	echo "==================== ${mountpoint} ===================="
	mkdir --parents "${crypt_dir}/${name}-plain"
	if [[ `uname -s` = 'Darwin' ]]
	then
		# MacOS does not have `mountpoint`. Assume it is not mounted.
		if ! mount | grep -q "${crypt_dir}/${name}-plain"
		then
			echo "Mounting ${name}"
			gocryptfs ${options} "${crypt_dir}/${name}-crypt" "${crypt_dir}/${name}-plain"
		fi
	else
		if ! mountpoint "${crypt_dir}/${name}-plain"
		then
			echo "Mounting ${name}"
			gocryptfs ${options} "${crypt_dir}/${name}-crypt" "${crypt_dir}/${name}-plain"
		fi
	fi

done

