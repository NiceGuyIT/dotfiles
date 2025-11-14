#!/usr/bin/env bash

get_info() {

	# Gather system configuration information
	hostname="$(hostnamectl --transient)"
	config_dir="${HOME}/sysinfo/${hostname}"
	mkdir --parents "${config_dir}"
	cd "${config_dir}" || exit 1

	echo "Gathering basic system info"
	ulimit -a > "${config_dir}/ulimit-${hostname}.txt"
	sysctl -a > "${config_dir}/sysctl-${hostname}.txt"
	cp /etc/os-release "${config_dir}/os-release-${hostname}.txt"
	cp /etc/fstab "${config_dir}/fstab-${hostname}.txt"

	ip addr > "${config_dir}/ip-addr-${hostname}.txt"
	ip --color=always addr > "${config_dir}/ip-addr-${hostname}-color.txt"
	ip route > "${config_dir}/ip-route-${hostname}.txt"
	ip --color=always route > "${config_dir}/ip-route-${hostname}-color.txt"
	systemctl list-unit-files > "${config_dir}/systemctl-list-unit-files-${hostname}.txt"
	SYSTEMD_COLORS=true systemctl list-unit-files > "${config_dir}/systemctl-list-unit-files-${hostname}-color.txt"

    if [[ "$(systemd-detect-virt)" == "systemd-nspawn" ]]
    then
        # nspawn info
        echo "Nothing to do for nspawn"
    else
        # host info
        inxi --full --color 2 > "${config_dir}/inxi-${hostname}-color.txt"
        inxi --full > "${config_dir}/inxi-${hostname}.txt"
        lsblk --fs > "${config_dir}/lsblk-fs-${hostname}.txt"
    	machinectl list-images > "${config_dir}/machinectl-images-${hostname}.txt"

        echo "Gathering firewall info"
        firewall-cmd --list-all-zones > "${config_dir}/firewall-zones-${hostname}.txt"

        echo "Gathering smartctl info"
        for drive in $(cd /dev && echo sd?)
        do
            smartctl -a "/dev/${drive}" > "${config_dir}/smartctl-${hostname}-${drive}.txt"
            smartctl -a --json "/dev/${drive}" > "${config_dir}/smartctl-${hostname}-${drive}.json"
        done
    fi

	echo "Gathering package info"
	[[ -d "repos.d" ]] && rm -r "repos.d"
	cp -r --preserve=timestamps /etc/zypp/repos.d/ "${config_dir}/repos.d/"
	zypper search --installed-only --details > "${config_dir}/installed-${hostname}-all-$(datestamp).txt"
	zypper repos --priority --uri > "${config_dir}/zypper-repos-${hostname}.txt"

	# Get list of packages installed
	zypper search --type package -si > "${config_dir}/installed-${hostname}-package-$(datestamp).txt"
	zypper search --type patch -si > "${config_dir}/installed-${hostname}-patch-$(datestamp).txt"
	zypper search --type pattern -si > "${config_dir}/installed-${hostname}-pattern-$(datestamp).txt"
	zypper search --type product -si > "${config_dir}/installed-${hostname}-product-$(datestamp).txt"

}

if [[ "$1" == "desktop" ]]
then
    echo "Checking desktop"
    exit 1

	#config_dir="${HOME}/NiceGuyIT/sysinfo/sysinfo/smartctl"
	#cd "${project_dir}"

	for host in sns4 sns5 sns6 sns7 sns8 sns9 katala pc-support01
	do
		#ssh ${host} grep '^DEVICESCAN' /etc/smartd.conf
		#ssh ${host} sudo systemctl status smartd.service

		drives=$(ssh ${host} "cd /dev; echo sd?")
		for drive in ${drives}
		do
			echo ${host} ${drive}
			ssh "${host}" sudo smartctl -a --json "/dev/${drive}" > "smartctl-${host}-${drive}.json"
		done

	done
	exit

else
    get_info
fi




