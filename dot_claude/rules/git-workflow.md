# Git Workflow (all repos)

Default workflow for every change, unless the user says they are working on many changes at once and to stay on the
current branch:

1. Make the changes.
2. Create a new branch named for the change (`fix/...`, `feat/...`, `chore/...`).
3. Commit and push the branch.
4. Switch back to `main` (the user merges the PR).

## Pre-change check (MANDATORY, before the FIRST file edit of every user-requested change)

1. `git fetch origin`, then `git status` and `git log --oneline @..origin/main`.
2. Decide the state:
   a. On `main`, no diff vs `origin/main` -> create a new branch named for the change, then edit.
   b. On a feature branch whose PR is STILL OPEN AND UNMERGED and the edit belongs to that PR -> stay on it.
   c. Anything else (main behind, previous PR merged, remote branch deleted, stale branch) ->
      `git checkout main && git pull --ff-only && git checkout -b <new-branch>` BEFORE editing.

A message like "fix X", "also do Y", "you forgot Z" AFTER a previous PR was merged is a NEW change: branch fresh off
updated main.

## Pre-commit check (MANDATORY, before EVERY commit)

Run the project's full check suite and block the commit on any failure. Never use `git commit --no-verify`.

1. Entrypoint, in order: `justfile` `pre-commit` recipe (`just pre-commit`), else `check` recipe (`just check`), else the
   repo's documented checks (e.g. `cargo fmt --check`, `cargo clippy ... -D warnings`, `cargo check`).
2. Fix failures (`just fmt` / `cargo fmt`) and re-run until green BEFORE committing.
3. In a fresh clone with an `install-hooks` recipe and no `.git/hooks/pre-commit`, run `just install-hooks`.

## Commit messages and PR text

- Do NOT hard-wrap bullets or paragraphs in anything flowing through the Forgejo/GitHub UI (commit bodies, PR titles
  and descriptions, review comments, `gh pr create --body`, `gh pr comment`). Newlines only between paragraphs and
  bullets, however long the line.
- No internal names (`no-internal-names.md`). The `#<KEY>-N` block is the only required identifier.
- Subject line / PR title: imperative, about 70 characters.
- EVERY commit body and PR description ends with the bare `#<KEY>-N` block, one line per issue worked
  (`youtrack-workflow.md` section 7). Check it before `fj pr create`.

## Forgejo PRs

Use the `fj` CLI for ALL Forgejo operations (PRs, issues, repos, releases, actions, wiki, packages, orgs). The Forgejo
MCP (`mcp__forgejo__*`) is the FALLBACK, only when `fj` fails or lacks the capability: load schemas with ToolSearch and
say which was used and why. Never hit the REST API directly (`tooling-gap-discipline.md`). Discover syntax with
`fj <command> --help`.

- Pass `--host <host>` to every `fj` call when `keys.json` holds more than one host.
- Branch-backed PR by default: `git push --set-upstream origin <branch>`, then `fj pr create "<title>" --body-file <path>`
  (title positional; body in a `mktemp --tmpdir --suffix .md` file). `-A` (`--autofill`) is fine.
- AVOID `-a` (`--agit`): it leaves no server branch, so "Update Branch" never appears and a PR behind a protected base
  becomes unmergeable. Token scopes, AGit recovery and other detail: `forgejo-pr-workflow` skill.
- `github.com` repos: `git push` plus `gh pr create`; if `gh` fails, assume it is not installed and use the compare URL.
