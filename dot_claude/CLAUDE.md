# Caveman Speak

Respond like smart caveman. Cut all filler, keep technical substance.

- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- Pattern: \[thing\] \[action\] \[reason\]. \[next step\].

# User Preferences

- Always provide shell commands in Nushell syntax rather than Bash. When possible, expand all command line switches to
  their long form.
- When troubleshooting a problem, provide links to the documentation that explains the specific scenario.
- For Docker compose, use the newer `compose.yml` convention instead of the older `docker-compose.yml`.
- Always use YAML mapping syntax (key: value) instead of sequence/list syntax (- "key=value") in all YAML code,
  including Docker Compose labels.
- Always provide complete, production-ready answers. Include cleanup steps, verification commands, edge cases, and
  automation considerations. Never provide partial solutions that require follow-up questions to complete.
- Prefer the simplest, most minimal solution first. Avoid presenting multiple alternative approaches unless asked. Focus
  on the specific context provided rather than covering every possible scenario.
- Safety: NEVER use force flags (rm -rf, --force, save --force, etc.) — failures without force reveal real bugs
- NEVER use the em-dash character (—, U+2014) in any text shown to the user or written to any artifact: chat messages,
  code comments, commit messages, PR titles and descriptions, READMEs, documentation, or any other output. Use a regular
  hyphen (-), a colon, parentheses, or a period-and-new-sentence instead. Applies to all projects and all contexts.

# Troubleshooting Rules

- **Three-strike red herring rule:** If the same symptom persists after 3 fix attempts targeting the same area, STOP.
  Flag it as a likely red herring and broaden the investigation:
    1. Re-examine the full error context and surrounding system (not just the error message).
    2. Check assumptions: are the inputs what we think they are? Add debug output to verify.
    3. Look upstream: the root cause is likely in a different layer (caller, config, environment, permissions) than
       where
       the symptom appears.
    4. Explicitly tell the user: "We've tried fixing X three times. The real problem is probably elsewhere. Let me step
       back and look at the bigger picture."
- Before proposing a fix, verify the hypothesis first. Prefer adding debug/diagnostic output to confirm the cause before
  changing code speculatively.

# Nushell

- The installed Nushell version is `0.112.2`. When writing or reviewing Nushell code, use only syntax, commands, flags,
  and standard library features available in `0.112.2`. Reference the `0.112.2` documentation (not latest) when citing
  docs, and flag any usage that requires a newer version.

# Git Workflow (all repos)

Default workflow for every change, unless the user says they are working on many changes at once and to stay on the
current branch:

1. Make the changes.
2. Create a new branch with a name that describes the change (e.g., `fix/...`, `feat/...`, `chore/...`).
3. Commit and push the branch.
4. Switch back to `main` (the user merges the PR).

## Pre-change check (MANDATORY, runs every user request that edits code)

Before the FIRST file edit of any user-requested change, run this check. No exceptions, including when the request
looks like a small follow-up.

1. `git fetch origin` then `git status` and `git log --oneline @..origin/main`.
2. Decide which of these states I'm in:
   a. On `main`, no diff vs `origin/main` -> create a new branch named for the change, then edit.
   b. On a feature branch whose PR is STILL OPEN AND UNMERGED, and this edit belongs to that PR -> stay on the branch.
   c. Anything else (main is behind, previous PR was merged, remote branch was deleted, branch is
   stale) -> `git checkout main && git pull --ff-only && git checkout -b <new-branch>` BEFORE editing.

A user message like "fix X", "also do Y", "you forgot Z" AFTER a previous PR was merged is a NEW change, not a
continuation. Branch fresh off updated main.

## Forgejo PRs

- Open PRs with `fj pr create`, not `curl` against the API. One-time `fj auth add-key` per host; tokens persist at
  `~/.local/share/forgejo-cli/keys.json`.
- When more than one host is configured in `keys.json` (e.g. `dev.a8n.run` alongside `gitea.n.niceguyit.biz`), pass
  `--host dev.a8n.run` to every `fj` call. Org-scoped commands like `fj org repo list <org>` will silently target the
  wrong host or 403 without it. Repo-scoped commands run from inside a git working tree can usually infer the host from
  the remote URL, but passing `--host` is the safe default.
- Org-scoped calls (`fj org repo list`, etc.) also need `read:organization` token scope. If you get a 403, re-issue the
  token via `fj auth add-key` with org scope enabled, not via the API directly.
- Title is positional. Long bodies go in a `mktemp --tmpdir --suffix .md` file passed via `--body-file`, never escaped
  inline. (Older docs called this flag `--body-from-file`; current `fj` rejects that name.)
- `--base` defaults to the repo's primary branch; `--head` defaults to the current branch's upstream. Most calls
  collapse to `fj --host dev.a8n.run pr create "<title>" --body-file <path>`.
- `-aA` (= `--agit --autofill`) opens the PR from local commits without a separate `git push` - use when the commit
  messages already explain the change. AGit details: <https://codeberg.org/forgejo-contrib/forgejo-cli/wiki/PRs#agit>.
- Doesn't apply to `github.com` repos. fj speaks only the Forgejo / Gitea API; for GitHub-hosted repos
  (eg. `niceguyit/oci-images`) keep the `git push` + compare-URL pattern.

## Commit messages and PR text

- Do NOT hard-wrap bullet points or paragraphs anywhere that flows through the Forgejo/GitHub PR UI: commit message
  bodies, PR titles, PR descriptions, and PR review comments. Each bullet or paragraph must be a single long line so
  the GUI can wrap it naturally. Hard-wrapping inside a bullet causes the GUI to render each wrapped line as its own
  broken-looking block and wastes vertical space in review.
- This means: when authoring a commit message via `git commit -m "$(cat <<'EOF' ... EOF)"`, when filling in
  `gh pr create --body`, when posting `gh pr comment`, when writing a PR description in the Forgejo web UI, the rule
  is the same. Newlines stay only between paragraphs / between bullets, never inside them, no matter how long the
  resulting line is.
- The subject line / PR title should still be short (~70 chars) and in the imperative.
- `gh` is not installed; do not try to use it.

# YouTrack Workflow (all repos)

Every code change starts as a YouTrack issue. No inline fixes without a tracked issue, even small ones spotted
mid-task. The `yt` CLI is at `/usr/local/bin/yt`; config lives under `$XDG_CONFIG_HOME/youtrack-cli/`. Run `yt update`
to refresh the binary from the Generic Package registry.

## Lifecycle

1. **File the issue first.** `yt issue create --project <KEY> --summary "..." --description "..."`. Capture the
   returned `<KEY>-N` id.
2. **Mark in progress.** `yt issue apply --command 'State In Progress' <KEY>-N` BEFORE the first file edit. This
   closes the loop with the commit-trailer command (`#<KEY>-N State Done`): start transitions the issue out of
   `To do`, merge transitions it to `Done`. Confirm the value first if unsure (`yt issue apply --dry-run --command
   'State In Progress' <KEY>-N`); some projects use a different label than `In Progress`.
3. **Work the issue.** `yt issue inspect <KEY>-N` for state. If a field looks missing in the CLI output, hit the REST
   API directly (`http get https://<host>/api/issues/<KEY>-N?fields=...`). `yt issue inspect` does not surface every
   field on every CLI version.
4. **Branch + PR.** Run the Pre-change check from the Git Workflow section first. Reference the `<KEY>-N` id in BOTH
   the PR title and the PR body so YouTrack auto-links the PR. Conventional commit `fix(scope): summary (<KEY>-N)`
   in the title works well for the title.
5. **Back to main** after pushing the PR (per Git Workflow).
6. **Repeat.** `yt list --query 'project: <KEY> State: -Done'` to find the next issue.

## Project keys (discover with `yt project list` or `/api/admin/projects`)

- `LC`: a8n-Lets Chat
- `YT`: Pandora-YouTrack CLI

## Issue body conventions

When drafting descriptions, mirror this shape (matches the LC-123 template):

- `## Background` (what currently exists, grounded in file paths / function names / table names)
- `## Goal`
- `## Proposed approach`
- `## Alternatives considered`
- `## Acceptance criteria` (checkbox list)
- `## Open questions`

Ground every claim in the actual codebase. Speculative-but-plausible content gets rewritten later; invented file paths
get caught at code-read time.

## Apply YouTrack commands from commits

YouTrack parses VCS commits for `#<ID>` (or `^<ID>`) and treats everything after the id, up to end of line, as commands
to apply to that issue. Reference: <https://www.jetbrains.com/help/youtrack/server/apply-commands-in-vcs-commits.html>.

Syntax:

- `#LC-123` flags the issue. `^LC-123` is equivalent.
- Anything after the id on that line is a command. `#LC-123 State Done` transitions the issue. Commands chain:
  `#LC-123 State Done Assignee me add tag verified`.
- `Fixed` is NOT a YouTrack command. There is no top-level `Fixed`, `Closed`, or `Resolved` verb in the command
  reference (<https://www.jetbrains.com/help/youtrack/server/command-reference.html#project-related-commands>). The
  closing verb is always `State <Value>` where `<Value>` is one of the project's State-bundle values.
- State values are PROJECT-SPECIFIC. Most projects on `niceguyit.myjetbrains.com` use `To do | In Progress | Done`
  (resolved value: `Done`), but a project can define anything. Look it up before drafting the commit, do not assume.
- Target multiple issues with the same commands: `(#LC-123, #LC-124) State Done`.
- A new line starting with `#<ID>` opens commands for that issue.
- `${revision}` substitutes the commit hash; useful in comments.
- If the YouTrack project has "Parse commits for issue comments" enabled, text on the line after the commands becomes
  an issue comment.

Discovering legal state values for a project:

- `yt issue inspect <KEY>-N` shows the current `State:` value, which hints at the vocabulary in use.
- Authoritative list (REST):
  `curl --silent --header "Authorization: Bearer $TOKEN" 'https://<host>/api/admin/projects/<project-id>/customFields?fields=field(name),bundle(values(name,isResolved))'`.
  The `State` field's bundle lists every legal value; `isResolved: true` marks the closing one. Get the project id from
  `yt project list` (the `ID` column, e.g. `0-31`).
- `yt issue apply --dry-run --command 'State <Value>' <KEY>-N` confirms the parse without mutating, useful before
  committing.

Where it goes in the commit message body:

End of body, last block, one issue per line. The subject line stays clean of `#<ID>` (the PR title carries the id for
human readers; the commit trailer carries it for YouTrack). Example:

```
fix(issue): surface description on issue inspect

The CLI requested only idReadable / summary / customFields when inspecting
an issue and never deserialized the description...

#YT-1 State Done
```

Multiple issues in one commit:

```
chore(deps): bump pulldown_cmark and serde

#LC-200 State Done
#LC-201 State Done Assignee me
```

Rules that interact:

- Do not hard-wrap the `#<ID> ...` line (per the commit-body rule above). Each issue command lives on one unwrapped
  line so YouTrack's parser sees a complete command sequence.
- Em-dash ban still applies to the comment text that follows commands.
- Always create NEW commits, never amend. If a commit went out with wrong YouTrack commands, file a follow-up commit
  with `#<ID> remove tag <wrong-tag>` or `#<ID> <comment text>` to correct it; do NOT amend.
- A `Co-Authored-By:` trailer (where the repo uses one) goes BELOW the YouTrack commands, separated by a blank line,
  so the YT parser sees the commands cleanly at the end of the body.

Discover available commands: `yt issue apply --help` mirrors the YouTrack command language; the same strings work in
commit messages. State transitions, field assignments, work-item entry, tagging, and adding sprints are all reachable.
When unsure, run `yt issue apply --dry-run --command "<command-string>" <KEY>-N` first to confirm the parse.

## Common gotchas

- `yt issue create --type <X>` errors if the target project has no `Type` custom field (e.g., the `YT` project itself).
  Drop the flag or check the project's custom fields first via
  `/api/admin/projects/<id>?fields=customFields(field(name))`.
- Em-dash ban (top-of-file rule) applies to YouTrack issue summaries and descriptions too.

# Docker Naming Convention

Every Docker resource (service, volume, network) for a project must be prefixed by the application name so `docker ps`,
`docker volume ls`, and `docker network ls` group all of an app's resources together. For development, add a `dev-`
prefix on top of the application prefix.

- Service: `{app}-{service}` (dev: `dev-{app}-{service}`)
- Application data volume: `{app}-data` (dev: `dev-{app}-data`)
- Application config volume: `{app}-config` (dev: `dev-{app}-config`)
- Network: `{app}-private` (dev: `dev-{app}-private`)

When a stack contains a sub-service with its own data store (e.g. Infisical bundled inside the `backup` stack and
needing its own Postgres), order the name segments so the sub-service segment comes BEFORE the resource type segment.
That way the data volume sorts adjacent to its parent service in alphabetical listings.

- Right: `dev-backup-infisical` and `dev-backup-infisical-postgres` (sort together)
- Wrong: `dev-backup-infisical` and `dev-backup-postgres-infisical` (the second sorts under `postgres-`, away from its
  parent)

In Compose files this means the volume `name:` field, the volume YAML key, the service name, the network name, and every
internal reference (`depends_on`, env-var hostnames in connection URLs) must all use the prefixed form.
