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

## Pre-commit check (MANDATORY, runs before EVERY commit)

Before the FIRST `git commit` of any change, run the project's full check suite and block the commit on any failure.
Never bypass with `git commit --no-verify`.

1. Detect the project's check entrypoint, in order:
   a. `justfile` with a `pre-commit` recipe -> run `just pre-commit` (matches the CI toolchain exactly).
   b. else `justfile` with a `check` recipe -> run `just check`.
   c. else fall back to the repo's documented checks (e.g. `cargo fmt --check`, `cargo clippy ... -D warnings`,
   `cargo check`; the project's lint/format/build commands).
2. If any check fails, FIX it (e.g. `just fmt` / `cargo fmt`) and re-run until green BEFORE committing. A red check is
   never "commit now, fix in a follow-up".
3. At session start in a fresh clone, if the repo has an `install-hooks` recipe and `.git/hooks/pre-commit` is absent,
   run `just install-hooks` so the local hook backs you up.

**Why:** CI's fmt/clippy/build gate rejects unformatted or lint-dirty commits. Running the same checks locally first
turns a failed CI run plus a follow-up fix PR into zero round-trips. This is the gap that produced an unformatted-code
CI failure.

## Forgejo PRs

- Open PRs with `fj pr create`, not `curl` against the API. One-time `fj auth add-key` per host; tokens persist at
  `~/.local/share/forgejo-cli/keys.json`.
- When more than one host is configured in `keys.json` (e.g. `forgejo.example.com` alongside `gitea.example.org`),
  pass `--host forgejo.example.com` to every `fj` call. Org-scoped commands like `fj org repo list <org>` will
  silently target the wrong host or 403 without it. Repo-scoped commands run from inside a git working tree can
  usually infer the host from the remote URL, but passing `--host` is the safe default.
- Org-scoped calls (`fj org repo list`, etc.) also need `read:organization` token scope. If you get a 403, re-issue the
  token via `fj auth add-key` with org scope enabled, not via the API directly.
- Title is positional. Long bodies go in a `mktemp --tmpdir --suffix .md` file passed via `--body-file`, never escaped
  inline. (Older docs called this flag `--body-from-file`; current `fj` rejects that name.)
- `--base` defaults to the repo's primary branch; `--head` defaults to the current branch's upstream. Most calls
  collapse to `fj --host forgejo.example.com pr create "<title>" --body-file <path>`.
- DEFAULT to a branch-backed PR: `git push --set-upstream origin <branch>` first, then `fj pr create`. This is what
  `fj` does without `-a` (`--head` defaults to the current branch's upstream). A real server branch is what makes
  Forgejo's "Update Branch" control appear, so a PR that falls behind a protected base can be brought current and stays
  mergeable. `-A` (`--autofill`) is orthogonal and fine to keep: it fills title/body from the commits.
- AVOID `-a` (`--agit`). AGit opens the PR from local commits with no server branch (commits live only under
  `refs/pull/<N>/head`). That branch never appears in `git branch --all`, the web Branches page, or a plain
  `git fetch`, and because there is no branch to update, Forgejo cannot offer "Update Branch"; once the PR falls behind
  a base that requires up-to-date, the merge button disappears. Reserve `-a` for deliberate throwaway PRs where no
  server branch is wanted, and recover a stuck AGit PR by re-pushing its rebased/merged head to `refs/for/<base>` with
  `--push-option topic=<original-head-branch-name>`. AGit details:
  <https://codeberg.org/forgejo-contrib/forgejo-cli/wiki/PRs#agit>.
- Doesn't apply to `github.com` repos. fj speaks only the Forgejo / Gitea API; for GitHub-hosted repos
  (eg. `example-org/oci-images`) keep the `git push` + compare-URL pattern.

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
