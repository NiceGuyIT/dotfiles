# No Internal Names (MANDATORY, every issue, commit, PR, and code change)

Never write an internal name, resource, or identity into anything that leaves the working session: YouTrack issue
summaries, descriptions and comments; commit messages and branch names; PR titles, descriptions and review comments;
code, code comments, tests, fixtures, examples, and docs. Describe the thing by its role, or use a reserved placeholder.

## What counts as internal

- Infrastructure: hostnames, server/VM/runner names, internal domains and subdomains, IPs and subnets, overlay or VPN
  names, container/service/network/volume names of private deployments, cloud project/account/org ids, bucket, queue
  and secret-store paths.
- Organization: internal repo, org and team names, tracker/registry/CI URLs, private package names, runner labels.
- People and customers: names, usernames, emails, handles, customer/client/tenant names. Refer to people by role.
- Credentials: never, in any form.

## Write instead

- A role: "the production database host", "the CI runner", "the mail server".
- A reserved placeholder: `example.com` / `example.org` / `example.net` (RFC 2606), `192.0.2.0/24`,
  `198.51.100.0/24`, `203.0.113.0/24` (RFC 5737), `2001:db8::/32` (RFC 3849), `<host>`, `<org>/<repo>`.
- Quoted errors and logs are sanitized the same way. Keep the message text, replace the name.

## Not covered

- The tracker key `#KEY-N` that `youtrack-workflow.md` section 7 requires.
- Public names: upstream projects, public registries, public images.
- Chat with the user, and commands run locally against live systems (verification per
  `verify-source-of-truth.md` needs the real name). Only the text that leaves the session is sanitized.
- An identifier code needs to function (a path, config key or resource name that must be exact for it to work). It
  stays where it is functionally required and is never copied into prose, comments, tests-as-examples, messages, or
  docs.

## Blocking sweep, before ANY issue, commit, or PR is filed

1. Grep the full text and the diff for the categories above, plus every line of `~/.claude/internal-names.txt` if it
   exists (a private local denylist, one literal per line, never committed anywhere).
2. Print a table: hit, location, classification (replaced / required identifier with reason / public name), verdict.
3. Fix every violation in the same change. Commits and PRs already pushed are never amended or force-pushed: correct
   forward with a new commit, and edit issue text with `yt`.
4. A leak found in older work outside the current change gets a linked issue per the no-orphan-notes rule.

**Why:** issue, commit and PR text is copied, indexed, mirrored and shown to people without access to the systems it
names. A hostname or tenant name in a PR title is a disclosure that cannot be taken back, and it adds nothing a role
description would not.
