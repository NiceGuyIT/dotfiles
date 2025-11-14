#!/usr/bin/env nu

use std log

# Decrypt and mount a LUKS partition

# Get the mountpoints as a table.
# Original is in functions.nu
def "get-mountpoints" []: nothing -> table {
	^mount
		| from ssv --minimum-spaces 1
		| rename proc on_word mountpoint type_word options
		| select proc mountpoint options
}


# Decrypt and mount a LUKS encrypted partition
def mount-luks [
	--uuid: string,					# UUID of the LUKS partition
	--mount-prefix: string,			# Mount directory without the volume name; dirname of the mountpoint
	--volume-name: string,			# Volume name to mount the partition
	--passphrase: string,			# Encryption passphrase
	--mount-options: string = ""	# Mount options
]: nothing -> nothing {
	let mapper_dir = ('/dev/mapper' | path join $volume_name)
	let mount_dir = ($mount_prefix | path join $volume_name)
	let mount_options = ($mount_options | split words)
	if not (get-mountpoints | where mountpoint == $mount_dir | is-empty) {
		log info $"Partition is already mounted on '($mount_dir)'"
		return
	}

	if not ($mount_dir | path exists) {
		log info $"Creating mountpoint '($mount_dir)'"
		mkdir $mount_dir
		chmod go-w $mount_dir
	}

	log info $"^cryptsetup open --type luks UUID=($uuid) ($volume_name)"
	$passphrase | ^cryptsetup ...[
		open
			--type luks
			...$mount_options
			$"UUID=($uuid)"
			$volume_name
	]
	^mount $mapper_dir $mount_dir

}

if (which cryptsetup | is-empty) {
	log error $"The 'cryptsetup' command is not available. Please install 'cryptsetup' and try again."
	exit 1
}
if (which mount | is-empty) {
	log error $"The 'mount' command is not found. Please install 'mount' and try again."
	exit 1
}

$env.SOPS_AGE_KEY_FILE = ($"($env.HOME)/.config/sops/age/keys.txt" | path expand)
let luks_sops_file = ($"($env.HOME)/.config/sops/luks-config.sops.json" | path expand)

if not ($env.SOPS_AGE_KEY_FILE | path exists) {
	log error $"The age key file does not exist: '($env.SOPS_AGE_KEY_FILE)'"
	exit 1
}
if not ($luks_sops_file | path exists) {
	log error $"The LUKS config does not exist: '($luks_sops_file)'"
    exit 1
}

# Decrypt the config file
let cfg = (^sops --decrypt $luks_sops_file | from json)

log info $"$env.SOPS_AGE_KEY_FILE = ($env.SOPS_AGE_KEY_FILE)"
log info $"luks_sops_file: ($luks_sops_file)"
log info "====="

$cfg

$cfg.luks | each {|it|
	log info $"($it.uuid): Decrypting and mounting '($it.volume)'"
	mut mount_options = ""
	if $it.allow-discards {
		$mount_options = "--allow-discards"
	}
	mount-luks --uuid $it.uuid --mount-prefix $cfg.defaults.mount-prefix --volume-name $it.volume --passphrase $it.passphrase --mount-options $mount_options
	log info "----"
	{uuid: $it.uuid volume: $it.volume}
}
