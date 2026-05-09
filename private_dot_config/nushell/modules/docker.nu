# Custom Docker functions

# docker volume ls suitable for Nushell
export def "docker volume-ls" []: nothing -> any {
    let cli = $env.docker-cli

	^$cli volume ls --format json
	| lines
	| each {|it| $it | from json} |
	each {|it|
		^$cli volume inspect $it.Name
		| from json
		| each {|i| { name: $i.Name, mount: $i.Options.device? }}
	}
	| flatten

	# Fetch sizes once from the daemon. The 'type=volume' query restricts
	# /system/df to volume usage, which is much faster than computing usage for
	# images, containers, and build cache as well.
	# https://docs.docker.com/reference/api/engine/version/v1.42/#tag/System/operation/SystemDataUsage
	let sizes = (
		# This takes several seconds.
		http get --unix-socket /var/run/docker.sock 'http://localhost/system/df?type=volume'
		| get Volumes
		| reduce --fold {} {|v, acc| $acc | insert $v.Name $v.UsageData.Size }
	)

	^$cli volume ls --format json
	| lines
	| each {|it| $it | from json}
	| each {|it|
		^$cli volume inspect $it.Name
		| from json
		| update CreatedAt {into datetime --format "%Y-%m-%dT%H:%M:%S%:z"}
		| each {|i|
			{
				created_at: $i.CreatedAt,
				name: $i.Name,
				mount: $i.Options.device?,
				size: ($sizes | get --optional $i.Name | default 0 | into filesize),
			}
		}
	}
	| flatten
	| sort-by size

}

# docker network ls suitable for Nushell
export def "docker network-ls" []: nothing -> any {
    let cli = $env.docker-cli
	^$cli network ls --no-trunc --format json
	| lines
	| each {|it| $it | from json}
	| update CreatedAt {into datetime --format "%Y-%m-%d %H:%M:%S%.f %z %Z"}
	| reject Internal Labels Scope
}

# docker ps --all suitable for Nushell
export def "docker ps-all" []: nothing -> any {
    let cli = $env.docker-cli
	^$cli ps --all --no-trunc --format json
	| lines
	| each {|it| $it | from json}
	| update CreatedAt {into datetime --format "%Y-%m-%d %H:%M:%S%.f %z %Z"}
	| update Ports {
		if ($in | is-not-empty) {$in | split column ', ' | transpose | get column1}
	}
	| update Labels {
		# This does not handle the case where commas are in the values.
		if ($in | is-not-empty) {$in | split column ',' | transpose | get column1}
	}
	| update Mounts {
		if ($in | is-not-empty) {$in | split column ',' | transpose | get column1}
	}
	| update Networks {
		if ($in | is-not-empty) {$in | split column ',' | transpose | get column1}
	}
	| reject Labels
}

# docker ps suitable for Nushell
export def "docker ps" [
	--image     # Include the Image column
	--networks  # Include the Networks column
	--ports     # Include the Ports column
]: nothing -> any {
	let cols = (
		[Command ID LocalVolumes Mounts]
		| append (if not $image { [Image] } else { [] })
		| append (if not $networks { [Networks] } else { [] })
		| append (if not $ports { [Ports] } else { [] })
	)
	docker ps-all | reject Platform? ...$cols
}

# docker container ls suitable for Nushell
export def "docker container-ls" []: nothing -> any {
    let cli = $env.docker-cli
	^$cli container ls --all --no-trunc --format json
	| lines
	| each {|it| $it | from json}
	| update CreatedAt {into datetime --format "%Y-%m-%d %H:%M:%S%.f %z %Z"}
	| update Ports {
		if ($in | is-not-empty) {$in | split column ', ' | transpose | get column1}
	}
	| update Labels {
		# This does not handle the case where commas are in the values.
		if ($in | is-not-empty) {$in | split column ',' | transpose | get column1}
	}
	| update Mounts {
		if ($in | is-not-empty) {$in | split column ',' | transpose | get column1}
	}
	| update Networks {
		if ($in | is-not-empty) {$in | split column ',' | transpose | get column1}
	}
	| reject Labels
}

# "docker image ls" suitable for Nushell
export def "docker image-ls" []: nothing -> any {
	docker image-list
}
