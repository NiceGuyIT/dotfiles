#!/usr/bin/env nu

# Decrypt and mount a LUKS partition

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


# Decrypt and mount a LUKS encrypted partition
def mount-luks [
	--uuid: string,					# UUID of the LUKS partition
	--mount-prefix: string,			# Mount directory without the volume name; dirname of the mountpoint
	--volume-name: string,			# Volume name to mount the partition
	--passphrase: string,			# Encryption passphrase
	--mount-options: string = ""	# Mount options
] {
	let mapper_dir = ('/dev/mapper' | path join $volume_name)
	let mount_dir = ($mount_prefix | path join $volume_name)
	let mount_options = ($mount_options | split words)
	if not (get-mountpoints | where mountpoint == $mount_dir | is-empty) {
		print $"Partition is already mounted on '($mount_dir)'"
		return
	}

	if not ($mount_dir | path exists) {
		print $"Creating mountpoint '($mount_dir)'"
		mkdir $mount_dir
	}

	print $"^cryptsetup open --type luks UUID=($uuid) ($volume_name)"
	$passphrase | ^sudo ...[
		cryptsetup open
			--type luks
			...$mount_options
			$"UUID=($uuid)"
			$volume_name
	]
	if not ($mount_dir | path exists) {
		^sudo mkdir $mount_dir
	}
	^sudo mount $mapper_dir $mount_dir

}

if (which cryptsetup | is-empty) {
	print $"The command 'cryptsetup' is not available. Please install 'cryptsetup' and try again."
	exit 1
}

let age_key_file = ($"($env.HOME)/.config/sops/age/keys.txt" | path expand)
let gocryptfs_sops_file = ($"($env.HOME)/.config/sops/luks-config.sops.json" | path expand)

# Decrypt the config file
$env.SOPS_AGE_KEY_FILE = $age_key_file
let cfg = (^sops --decrypt $gocryptfs_sops_file | from json)

print $"$env.SOPS_AGE_KEY_FILE = ($env.SOPS_AGE_KEY_FILE)"
print $"age_key_file: ($age_key_file)"
print $"gocryptfs_sops_file: ($gocryptfs_sops_file)"
print "====="

$cfg

$cfg.luks | each {|it|
	print $"($it.uuid): Decrypting and mounting '($it.volume)'"
	mut mount_options = ""
	if $it.allow-discards {
		$mount_options = "--allow-discards"
	}
	mount-luks --uuid $it.uuid --mount-prefix $cfg.defaults.mount-prefix --volume-name $it.volume --passphrase $it.passphrase --mount-options $mount_options
	print "----"
	{uuid: $it.uuid volume: $it.volume}
}
