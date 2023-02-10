#!/usr/bin/env bash

# This script performs a small set of actions on all local repos
# located in ~/projects.

project_dir="${HOME}/projects"
repos=$( cd "${project_dir}"; echo * */*; )

case $1 in
	pull)
		command="-c color.ui=always pull"
		;;
	status)
		command="-c color.status=always status --short"
		;;
	check)
		command="-c color.ui=always fetch --dry-run"
		;;
	*)
		command="-c color.status=always status"
		;;
esac

for repo in ${repos[*]}
do
	[[ ! -d "${project_dir}/${repo}/.git" && ! -f "${project_dir}/${repo}/.git" ]] && continue
	echo "============================== ${repo} =============================="
	cd "${project_dir}/${repo}"
	stdout=$(git -c color.ui=always $command)
	[[ -n "$stdout" ]] && echo -e "$stdout\n"
done

