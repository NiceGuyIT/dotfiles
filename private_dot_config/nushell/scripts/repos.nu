#!/usr/bin/env nu

export def "repo status" [--list] {
	glob **/.git --depth 10
	| each {|it| $it | path dirname}
	| each {|it|
		let relative = ($it | path relative-to (pwd))
		cd $it

		let branch = (git branch --show-current)
		let remote = (git remote get-url origin | complete)
		let remote_url = if ($remote.exit_code == 0) { $remote.stdout | str trim | str replace --regex '^\w+://' '' | str replace --regex '^[^@]+@' '' } else { "" }
		let ahead_behind = (git rev-list --left-right --count $"origin/($branch)...HEAD" | complete)
		let ahead = if ($ahead_behind.exit_code == 0) {
			$ahead_behind.stdout | split row "\t" | get 1 | str trim | into int
		} else { 0 }
		let behind = if ($ahead_behind.exit_code == 0) {
			$ahead_behind.stdout | split row "\t" | get 0 | str trim | into int
		} else { 0 }

		let porcelain = (git status --porcelain | parse --regex '(?P<index>.)(?P<worktree>.) (?P<file>.+)')
		let staged = ($porcelain | where {|row| $row.index != " " and $row.index != "?"} | get file)
		let unstaged = ($porcelain | where {|row| $row.worktree != " " and $row.worktree != "?"} | get file)
		let untracked = ($porcelain | where {|row| $row.index == "?" and $row.worktree == "?"} | get file)

		if $list {
			{
				repo: $relative
				branch: $branch
				staged: $staged
				unstaged: $unstaged
				untracked: $untracked
			}
		} else {
			{
				repo: $relative
				branch: $branch
				remote: $remote_url
				ahead: $ahead
				behind: $behind
				staged: ($staged | length)
				unstaged: ($unstaged | length)
				untracked: ($untracked | length)
			}
		}
	}
}

def main [command: string, --list] {
	match $command {
		"status" => { repo status --list=$list }
		_ => { print $"Unknown command: ($command)" }
	}
}
