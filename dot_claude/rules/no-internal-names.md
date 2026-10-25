# No Internal Names (MANDATORY, every issue, commit, PR, and code change)

Never write an internal name, resource, or identity into anything that leaves the working session: YouTrack issues and
comments; commit messages and branch names; PR titles, descriptions and review comments; code, comments, tests,
fixtures, examples, and docs. Describe it by role or use a reserved placeholder.

**Internal means:**
- Infrastructure: hostnames, server/VM/runner names, internal domains, IPs and subnets, overlay or VPN names, container,
  service, network and volume names of private deployments, cloud project/account/org ids, bucket, queue and
  secret-store paths.
- Organization: internal repo, org and team names, tracker/registry/CI URLs, private package names, runner labels.
- People and customers: names, usernames, emails, handles, customer or tenant names (refer to people by role).
- Credentials: never, in any form.

**Write instead:** a role ("the production database host", "the CI runner") or a reserved placeholder: `example.com` /
`.org` / `.net` (RFC 2606), `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` (RFC 5737), `2001:db8::/32` (RFC 3849),
`<host>`, `<org>/<repo>`. Quoted errors and logs keep the message text with the name replaced.

**Not covered:** the `#KEY-N` tracker key; public names (upstream projects, public registries and images); chat with the
user; commands run locally against live systems (verification needs the real name); an identifier code needs to
function (a path, config key or resource name that must be exact) stays where functionally required and is never copied
into prose, comments, example tests, messages or docs.

## Blocking sweep, before ANY issue, commit, or PR is filed

1. Grep the full text and the diff for the categories above plus every line of `~/.claude/internal-names.txt` if it
   exists (a private local denylist, one literal per line, never committed).
2. Print a table: hit, location, classification (replaced / required identifier with reason / public name), verdict.
3. Fix every violation in the same change. Pushed commits and PRs are never amended or force-pushed: correct forward
   with a new commit, and edit issue text with `yt`.
4. A leak in older work outside the change gets a linked issue (`youtrack-workflow.md` section 3).

**Why:** issue, commit and PR text is copied, indexed and mirrored to people without access to the systems it names; a
hostname in a PR title cannot be taken back.
