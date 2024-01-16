#!/usr/bin/env nu

# Decrypt and mount a gocryptfs directory onto a plain directory.
# 2020-08-31: Added -sharedstorage option to prevent inode collisions
# 2018-09-23: KeePass is no longer encrypted.

# Get the mountpoints as a table.
# Original is in functions.nu
def "get-mountpoints" []: nothing -> table {
	if (which mount | is-empty) {
		print $"The 'mount' command is not found. Please install 'mount' and try again."
        exit 1
	}
	^mount
		| from ssv --minimum-spaces 1
		| rename proc on_word mountpoint type_word options
		| select proc mountpoint options
}


# Mount a gocryptfs encrypted directory, creating the mountpoint if necessary.
#   mount gocryptfs my-files
# will mount $"($crypt_dir)/my-files-crypt" to $"($mount_dir)/my-files-plain"
def gocryptfs-mount [
	--crypt-dir: string,	# Encrypted directory to mount
	--mount-dir: string,	# Unencrypted (Plain) mountpoint
	--password: string,		# Encryption password
]: nothing -> nothing {
	let crypt_dir = $crypt_dir | path expand
	let mount_dir = $mount_dir | path expand

	if not ($crypt_dir | path join "gocryptfs.conf" | path exists) {
		print $"gocryptfs.conf file not found in the crypt_dir: '($crypt_dir)'"
		print $"crypt_dir: ($crypt_dir)"
		return
	}
	print $"crypt_dir: ($crypt_dir)"
	print $"mount_dir: ($mount_dir)"

	# This prevents an error due to inode conflicts
	# https://github.com/rfjakob/gocryptfs/blob/master/Documentation/MANPAGE.md#-sharedstorage
	# More than likely this was caused by Syncthing and may be fixed in gocryptfs v2.0.
	# https://github.com/rfjakob/gocryptfs/issues/549
	let options = '-sharedstorage'

	# Create the mount point if it doesn't exist.
	if not ($mount_dir | path exists) {
		print $"Creating directory: ($mount_dir)"
		mkdir $mount_dir
	}

	if (get-mountpoints | where mountpoint == $mount_dir | is-empty) {
		# Directory is not mounted. Mount it
		print $"Running command: gocryptfs ($options) ($crypt_dir) ($mount_dir)"
		$password | ^gocryptfs $options $crypt_dir $mount_dir
	}
}

if (which gocryptfs | is-empty) {
	print $"The command 'gocryptfs' is not available. Please install 'gocryptfs' and try again."
	exit 1
}

let age_key_file = ($"($env.HOME)/.config/sops/age/keys.txt" | path expand)
let gocryptfs_sops_file = ($"($env.HOME)/.config/sops/gocryptfs-config.sops.json" | path expand)

# Decrypt the gocryptfs config and then use it to mount the gocryptfs directories.
$env.SOPS_AGE_KEY_FILE = $age_key_file
let cfg = (^sops --decrypt $gocryptfs_sops_file | from json)
print $"$env.SOPS_AGE_KEY_FILE = ($env.SOPS_AGE_KEY_FILE)"
print $"age_key_file: ($age_key_file)"
print $"gocryptfs_sops_file: ($gocryptfs_sops_file)"
$cfg

$cfg.gocryptfs | each {|it|
	let crypt_dir = ($cfg.defaults.crypt_dir | path join $"($it.name)-crypt" | path join $it.subdir)
	let mount_dir = ($cfg.defaults.mount_dir | path join $"($it.name)-plain")
	print $"($it.name): Decrypting crypt_dir '($crypt_dir)' to mount_dir '($mount_dir)'"
	#print $"($it.name): crypt_dir '($crypt_dir)'"
	#print $"($it.name): mount_dir '($mount_dir)'"
	gocryptfs-mount --crypt-dir $crypt_dir --mount-dir $mount_dir --password $it.password
	print "----"
	{name: $it.name mount: $mount_dir}
}
