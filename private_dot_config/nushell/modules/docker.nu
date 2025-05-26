# Custom Docker functions

# docker volume ls suitable for Nushell
export def "docker volume-ls" []: nothing -> any {
    let cli = $env.docker-cli
	^$cli volume ls --no-trunc --format json
	| lines
	| each {|it| $it | from json} |
	each {|it|
		^$cli volume inspect $it.Name
		| from json
		| each {|i| { name: $i.Name, mount: $i.Options.device? }}
	}
	| flatten
}

# docker network ls suitable for Nushell
export def "docker network-ls" []: nothing -> any {
    let cli = $env.docker-cli
	^$cli network ls --no-trunc --format json
	| lines
	| each {|it| $it | from json}
	| update CreatedAt {into datetime}
	| reject Internal Labels Scope
}

# docker ps --all suitable for Nushell
export def "docker ps-all" []: nothing -> any {
    let cli = $env.docker-cli
	^$cli ps --all --no-trunc --format json
	| lines
	| each {|it| $it | from json}
	| update CreatedAt {into datetime}
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