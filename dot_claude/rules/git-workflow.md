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

## Checks: the git hooks run them (MANDATORY, before the FIRST commit or push of every change)

The repo's git hooks are the check gate. When they are active, do NOT also run the suite by hand: that doubles a slow
run. Never use `git commit --no-verify` or `git push --no-verify`.

1. Verify the hooks are active: `git config --get core.hooksPath`, then `ls -l <hooks dir>/pre-commit <hooks dir>/pre-push`
   (default `.git/hooks`). A hook counts only if it is executable and runs the repo's checks (read the file; a stub like
   `exec just pre-push` qualifies).
2. Missing hooks and the repo has an `install-hooks` recipe (`just install-hooks`) -> run it, then re-verify step 1.
3. Hooks active -> commit and push; the hooks run the checks. A hook failure blocks the commit or push: fix the cause
   (`just fmt` / `cargo fmt` for formatting) and retry. Do not run `just check` / `just pre-push` separately first.
4. No hooks and no `install-hooks` recipe (or the hooks do not run the checks) -> fall back to manual checks BEFORE
   committing, once: `justfile` `pre-commit` recipe (`just pre-commit`), else `check` recipe (`just check`), else the
   repo's documented checks (e.g. `cargo fmt --check`, `cargo clippy ... -D warnings`, `cargo check`). Fix failures and
   re-run until green.

**Why:** a slow disk makes every full-suite run expensive, and running the suite by hand before a hook that runs it
again is pure duplicate cost. Relying on the repo's own hook is also the tool-first path (`tooling-gap-discipline.md`).

## No test runs outside the git hooks (MANDATORY)

When the repo's hooks are active (steps above), the hooks and CI are the ONLY place checks run. NEVER run, by hand or
in the background, any of: `cargo test` (full or filtered, including a single new test), `cargo clippy`,
`cargo fmt --check`, `just check` / `just pre-push` / `just pre-commit`, `claude-run test-postgres`, or any other
suite, linter or type check the hooks or CI already run.

- Write the code and its tests, commit, and let the hook run them. A hook failure is the feedback.
- Allowed before the commit: `cargo check` (compile only), and running the deliverable itself as `testing.md` section 1
  requires (a script, CLI or migration actually executed), never the test suite.
- An AC such as "tests pass on SQLite and Postgres" is satisfied by the hooks and CI, not by a local run. Report it as
  "covered by the pre-push hook and CI".
- A leg the hooks cannot run (a Postgres leg, a runner-only check) is left to CI. Say so in the PR body. Do not start
  it locally, and do not retry it.
- If I notice I ran one, say so to the user at once, with its duration.

**Why:** every extra run costs minutes on a slow workstation and duplicates what the hook and CI run again. In one
session, manual filtered tests, clippy and two `test-postgres` runs (one hit the 600s limit) cost about 15 to 20
minutes before the hook ran the same suite.

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
