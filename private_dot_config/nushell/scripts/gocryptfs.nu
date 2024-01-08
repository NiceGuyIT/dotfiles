#!/usr/bin/env nu

# Mount the encrypted containers for KeePassXC and the Vault (KeePassXC file).
# 2020-08-31: Added -sharedstorage option to prevent inode collisions
# 2018-09-23: KeePass is no longer encrypted.
# See https://github.com/keepassxreboot/keepassxc/issues/2312

#crypt_dir="${HOME}/gocryptfs"
#cd "${crypt_dir}"

#read -p "Please enter the password: " -s password
#echo
#
#keyfile="/tmp/keyfile.luks"
#touch "${keyfile}"
#chmod go-rwx "${keyfile}"
#echo -n $password > "${keyfile}"

# This prevents an error due to inode conflicts
#options="-sharedstorage"

#for mountpoint in niceguyit.biz-vault-crypt
#do
#	name="${mountpoint%-*}"
#	echo "==================== ${mountpoint} ===================="
#	mkdir --parents "${crypt_dir}/${name}-plain"
#	if [[ `uname -s` = 'Darwin' ]]
#	then
#		# MacOS does not have `mountpoint`. Assume it is not mounted.
#		if ! mount | grep -q "${crypt_dir}/${name}-plain"
#		then
#			echo "Mounting ${name}"
#			gocryptfs ${options} "${crypt_dir}/${name}-crypt" "${crypt_dir}/${name}-plain"
#		fi
#	else
#		if ! mountpoint "${crypt_dir}/${name}-plain"
#		then
#			echo "Mounting ${name}"
#			gocryptfs ${options} "${crypt_dir}/${name}-crypt" "${crypt_dir}/${name}-plain"
#		fi
#	fi
#
#done

# TODO: Check if this works for macOS.
# Get the mountpoints as a table.
export def "get mountpoints" []: nothing -> table {
	^mount
		| from ssv --minimum-spaces 1
		| rename proc on_word mountpoint type_word options
		| select proc mountpoint options
}

# Mount a gocryptfs encrypted directory, creating the mountpoint if necessary.
#   mount gocryptfs my-files
# will mount $"($crypt_dir)/my-files-crypt" to $"($mount_dir)/my-files-plain"
export def "mount gocryptfs" [
	--name: string,												# Directory to mount
	--crypt-dir: string = "/srv/c1/app-data/syncthing/data",	# Encrypted directory to mount
	--mount-dir: string = "~/gocryptfs",						# Mount directory
]: nothing -> nothing {
	let crypt_dir = $crypt_dir | path expand
	let mount_dir = $mount_dir | path expand

	# This prevents an error due to inode conflicts
	# https://github.com/rfjakob/gocryptfs/blob/master/Documentation/MANPAGE.md#-sharedstorage
	# More than likely this was caused by Syncthing and may be fixed in gocryptfs v2.0.
	# https://github.com/rfjakob/gocryptfs/issues/549
	let options = '-sharedstorage'

	let $crypt_path = ($crypt_dir | path join ([$name, 'crypt'] | str join '-'))
	let $mount_path = ($mount_dir | path join ([$name, 'plain'] | str join '-'))
	print $"mount_path: ($mount_path)"
	print $"crypt_path: ($crypt_path)"

	# Create the mount point if it doesn't exist.
	if not ($mount_path | path exists) {
		mkdir $mount_path
	}

	if (get mountpoints | where mountpoint == $mount_path | is-empty) {
		# Directory is not mounted. Mount it
		^gocryptfs $options $crypt_path $mount_path
	}
}

