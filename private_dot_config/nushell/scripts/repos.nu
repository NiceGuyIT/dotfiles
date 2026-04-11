#!/usr/bin/env nu

def highlight [value: int]: nothing -> string {
	if $value == 0 { $"($value)" } else { $"(ansi yellow_bold)($value)(ansi reset)" }
}

export def "repos status" [--list, --remote] {
	glob **/.git --depth 10
	| each {|it| $it | path dirname}
	| each {|it|
		let relative = ($it | path relative-to (pwd))
		cd $it

		let branch = (git branch --show-current)
		let origin = (git remote get-url origin | complete)
		let remote_url = if ($origin.exit_code == 0) { $origin.stdout | str trim | str replace --regex '^\w+://' '' | str replace --regex '^[^@]+@' '' } else { "" }
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
			let row = {
				repo: $relative
				branch: (if $branch == "main" { $branch } else { $"(ansi yellow_bold)($branch)(ansi reset)" })
				ahead: (highlight $ahead)
				behind: (highlight $behind)
				staged: (highlight ($staged | length))
				unstaged: (highlight ($unstaged | length))
				untracked: (highlight ($untracked | length))
			}
			if $remote {
				$row | insert remote $remote_url
			} else {
				$row
			}
		}
	}
}

export def "repos pull" [] {
	glob **/.git --depth 10
	| each {|it| $it | path dirname}
	| each {|it|
		let relative = ($it | path relative-to (pwd))
		cd $it

		let porcelain = (git status --porcelain)
		if ($porcelain | is-empty) {
			let result = (git pull | complete)
			if $result.exit_code == 0 {
				{ repo: $relative, status: ($result.stdout | str trim) }
			} else {
				{ repo: $relative, status: $"(ansi red_bold)error: ($result.stderr | str trim)(ansi reset)" }
			}
		} else {
			{ repo: $relative, status: $"(ansi yellow_bold)skipped \(has changes\)(ansi reset)" }
		}
	}
}

def main [command: string, --list, --remote] {
	match $command {
		"status" => { repos status --list=$list --remote=$remote }
		"pull" => { repos pull }
		_ => { print $"Unknown command: ($command)" }
	}
}
