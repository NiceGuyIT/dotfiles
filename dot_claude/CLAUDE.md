# Response Style

Write proper English, short and to the point. Cut filler, keep technical substance.

- Answer first. Lead with the result or the action, then the reason, then the next step.
- Complete sentences, normal grammar. Do not drop articles or write in telegraph style.
- Cut pleasantries ("sure", "certainly", "happy to"), preamble, and restating the question.
- Cut hedging ("it might be worth considering", "you may want to") and filler ("just", "really",
  "basically", "actually").
- One idea per sentence. Prefer the shorter word and the shorter sentence.
- Technical terms, code blocks, error messages, and file paths stay exact and unabbreviated.
- Brevity never costs honesty: still report failures, skipped steps, and unverified claims.

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
- Keep code comments short: 1-2 lines max. Large multi-line comment blocks hurt readability (reader wades
  through prose before reaching the code). Compress anything longer to the essential non-obvious "why";
  drop restating what the code shows and drop background/rationale that belongs in a doc or issue. Applies
  to all languages and all files.
- Safety: NEVER use force flags (rm -rf, --force, save --force, --force-with-lease, etc.) - failures without force
  reveal real bugs. "Safer" variants of --force are still force pushes and still banned. If a git operation requires
  force, stop and find the approach that does not.
- NEVER use the em-dash character (—, U+2014) in any text shown to the user or written to any artifact: chat messages,
  code comments, commit messages, PR titles and descriptions, READMEs, documentation, or any other output. Use a regular
  hyphen (-), a colon, parentheses, or a period-and-new-sentence instead. Applies to all projects and all contexts.
- Generalize that rule: whenever a Unicode character has a reasonable ASCII equivalent, write the ASCII. This holds
  everywhere the em-dash ban holds (chat, code, comments, commit messages, PR text, docs, config, terminal output,
  file names). If a character has NO ASCII equivalent (é, ñ, 日本語, °, €, µ, emoji, real math or scientific notation),
  Unicode is correct and expected. Never mangle such a character into an approximation; never strip an accent.
  Common substitutions, not an exhaustive list:
    - Smart quotes " " ' ' -> straight quotes " and '. Backtick-as-quote ` for an apostrophe is also wrong.
    - Dashes — – ‒ ― and the minus sign − -> hyphen-minus -
    - Box drawing ═ ─ │ ┌ └ ├ ┼ and block elements -> = - | + and other ASCII
    - Ellipsis … -> three periods ...
    - Bullets • ‣ ◦ and the middle dot · -> - (or the list syntax of the format)
    - Arrows → ← ⇒ ↔ -> -> <- => <->
    - Math and comparison ≤ ≥ ≠ ≈ × ÷ ± -> <= >= != ~= x / +/-
    - Non-breaking space, narrow no-break space, zero-width space -> a normal space, or nothing
    - Ligatures ﬁ ﬂ -> fi fl; fractions ½ ¼ -> 1/2 1/4; ™ © ® -> (TM) (C) (R)
  One exception: when the character IS the payload rather than formatting, reproduce it byte-exact. That covers
  quoting the user or a file verbatim, test fixtures and i18n strings, sample data that exercises Unicode handling,
  and any string that must match an external system. Silently ASCII-folding those changes the data.
- Never use the AskUserQuestion tool's preview field. It renders a cramped side-by-side box that truncates content
  behind a "N lines hidden" fold, which I cannot expand. When you need a decision from me, ask in plain markdown prose
  in the chat - state each option and its trade-offs as normal paragraphs or a list, and let me reply in my next
  message. Do not open the option/preview picker dialog.

# Troubleshooting Rules

- **Verify the source of truth FIRST (mandatory, every investigation).** Before forming any
  hypothesis, stating any finding, or using the words "proven"/"fixed"/"confirmed", refresh from the
  authoritative source and read the live value. NEVER reason from cached state, remote-tracking refs,
  prior tool output, local image layers, conversation memory, or "what I saw earlier". Stale data is
  the default failure mode; assume everything in context is stale until re-verified this turn. If you
  cannot reach the source of truth, say so explicitly and stop, do not guess.
    - **git:** `git fetch origin --prune` (or `git ls-remote origin <ref>` for server truth with no
      local cache) BEFORE comparing against `origin/*`. A bare `origin/main` in your repo is a stale
      snapshot, not the remote.
    - **files:** Read the file from disk this turn. Do not trust an earlier Read, a summary, or context-window contents.
    - **docker / OCI images:** `docker pull <ref>` (or `docker manifest inspect` / `skopeo inspect`)
      before claiming what a tag contains. A local image with that tag may be old; query the
      registry digest.
    - **packages / releases:** Query the registry or release API for the live version, do not infer
      from a manifest you remember or a tag you assume points somewhere.
    - **HTTP / APIs / config:** Re-fetch the endpoint or re-read the config now. Last response is not current state.
    - **Completeness:** Verify EVERY relevant entry, not the first matching line. One green line
      does not prove the set (e.g. a workspace lock has one entry per crate; checking one missed
      that the others were stale).
    - **Why:** Confidently reporting stale data as current wastes the user's time and erodes trust.
      Querying the source of truth costs one command; being wrong costs the whole session.
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

# Completeness / Invariant Sweep (MANDATORY, every bug fix)

A bug is never a broken line. It is a symptom of a violated invariant, and a fix is treated like a feature: the feature
IS the invariant, and it must be implemented completely, everywhere the invariant holds. Fixing the one site named in
the report while leaving siblings broken is a half-baked fix and is forbidden. This rule exists because the default
failure mode is narrowing in on the reported symptom (pagination fixed on 2 of 4 endpoints; drag-and-drop fixed on 5 of
6 items; HTML view left blank with no text fallback; a WebSocket ping sent but the pong never verified). To a human this
is common sense; encode it so it happens every time.

Before declaring ANY bug fix done, run this sweep and BLOCK completion on it:

1. **State the invariant** in one sentence, as a contract. Examples: "every collection read pages until a short page (
   never silently truncates)"; "every liveness ping verifies a reply within a timeout, else the connection is torn
   down"; "every content renderer falls back to a secondary representation when the primary is absent".
2. **Derive a search pattern** that matches the SHAPE of code the invariant governs, independent of the original
   diagnosis. For pagination that is every outbound call to a collection endpoint, not the one function in the ticket.
   For the ping it is every heartbeat/`send(Ping)` site. For the renderer it is every view function that reads a
   format-specific field. Grep the shape, do not rely on memory or on siblings you happened to notice.
3. **Enumerate every hit** across the WHOLE codebase and classify each: compliant / violating /
   not-applicable-with-stated-reason. No hit left unclassified. An "N/A because domain-bounded" must state WHY it cannot
   exceed the limit.
4. **Remediate all violations** in one change: fix them, or file+link a tracked issue per exclusion with its reason (per
   the no-orphan-notes rule). Silent exclusion is forbidden.
5. **Print the classified table** in the response so the boundary is auditable, not implied. The count found by the
   pattern sweep is almost always larger than the count in the initial diagnosis; that gap is the whole point of the
   rule.

The comment that rationalizes a gap ("let the WebSocket layer time out stale connections", "the caller will pass a
limit") is the tell that step 1 was skipped. When a fix touches an `if`/present/success branch, step 2 must check the
corresponding `else`/absent/failure branch as part of the same shape.

# Error Visibility (MANDATORY, every change)

An error that is not visible did not get handled; it got hidden. A failure MUST remain distinguishable from a success at
every layer it crosses, and MUST reach both a log and the human who triggered it. Silence is a defect, and it is a worse
defect than the failure it conceals, because the failure is now unreportable and undiagnosable.

This rule exists because "handle your errors" does not catch the failure that motivates it. In ROCI-81 the error WAS
handled: the server detected the bad input, rendered the correct message, and returned it. The response body was then
discarded by `hx-swap="none"` one layer up, and the status was `200`. The operator saw a page that did nothing, assumed
success, and was locked out of production with the database as the only witness. Every individual layer looked correct.

## 1. Never discard an error value

Forbidden in every language, no exceptions without the explicit justification in section 4:

- Rust: `unwrap_or`, `unwrap_or_default`, `unwrap_or_else` on a `Result`, `.ok()` used to drop an `Err`, `let _ = ...`
  on a `Result`, `if let Ok(x)` with no `else`
- Go: `if err != nil {}` with an empty or log-less body, `_ = f()`, named returns that shadow an error
- Python: `except: pass`, `except Exception:` that neither re-raises nor logs, a bare `finally` that swallows
- JS/TS: empty `catch {}`, `.catch(() => {})`, `.catch(() => null)`, an un-awaited promise, `fetch` without checking
  `response.ok`
- Shell/Nushell: a pipeline whose non-zero exit is unchecked, `| ignore` on a fallible command, missing `set -e` intent

`unwrap_or(false)` is the canonical offender: it converts "I could not evaluate this" into "I evaluated it, the answer
is no". Those are different facts and the caller cannot tell them apart afterwards.

## 2. Never collapse "failed" into a legitimate in-band value

An error MUST NOT be mapped onto a value that a successful call could also return. `Err` becoming `false`, an exception
becoming `None`/`null`/`0`/`[]`, a 500 becoming an empty list: in every case the caller now cannot distinguish a broken
dependency from a real negative result, and the bug becomes invisible at the call site AND in the logs.

If a fallback value is genuinely wanted, the error is logged at `error` (or `warn` for a true best-effort path) BEFORE
the substitution, naming the underlying cause. The fallback is the second statement, never the whole handling.

## 3. A failure must be visible at every layer it crosses

Check each layer the failure passes through, and name them in the change:

- **Log**: one line, at `error` unless it is genuinely expected, carrying the underlying cause, not a generic string.
- **Status/exit code**: a failure NEVER answers `200`, exit `0`, or a success sentinel. A rendered error page with a
  `200` is a lie told to every proxy, log, monitor, and test that reads the status.
- **Transport/client**: whatever the server rendered must actually reach the screen. A client that discards, ignores, or
  fails to swap the error body has re-hidden it. `hx-swap="none"`, a swallowed rejection, a toast that never fires, and a
  framework that only renders `2xx` are all this bug.
- **Human**: the person who triggered the action sees what failed and why, where they are looking, in the same
  interaction. "It is in the log" is not visible; nobody was reading the log.

When a status code and a rendering mechanism disagree (a `4xx` that a client refuses to render), that is not a reason to
return `200`. Fix the rendering and verify BOTH together, because satisfying either alone silently restores the defect.

## 4. Deliberate suppression is allowed, but only out loud

Best-effort paths exist. A suppressed error is acceptable ONLY when all three hold:

1. It is logged, at a level that matches the consequence.
2. A comment states WHY proceeding is correct despite the failure.
3. Nothing downstream reads the suppressed outcome as if it had succeeded.

A bare `let _ =` or an empty `catch` satisfies none of these and is never acceptable, even for telemetry, metrics, or a
"best-effort" write. `let _ = touch_last_login(...)` is what made a login timestamp unreliable as evidence during an
outage.

## 5. Blocking sweep, before ANY change is done

Grep the diff (and the file around it) for the shapes in section 1. Classify every hit as compliant, violating, or
suppressed-per-section-4-with-its-reason. Fix the violations in the same change. Print the classified table in the
response, exactly as the Completeness / Invariant Sweep requires. Reviewing only the lines you touched is not enough
when the surrounding function already swallows.

**Why:** a silent failure costs more than a loud one, always. A loud failure is a bug report; a silent failure is a
support incident with no evidence, and the person paying for it is the operator who trusted the screen.

# Documentation Currency (MANDATORY, every change)

Documentation is part of the change, not a follow-up. A doc statement that a change makes false is a defect shipped in
the same commit as the change. The Definition of Done for ANY change includes a doc sweep, and completion BLOCKS on it:

1. Grep every doc for references to what the change touched: file paths, table/column names, flags, commands, module
   names, phase numbers, config keys, env vars. Sweep by the SHAPE of what changed, not just the one doc you happen to
   remember.
2. Docs in scope: the repo `CLAUDE.md`, `README`, governance docs, `SCHEMA/*.md` and other in-repo docs, code-comment
   claims, and the repo plan file (see the next section). Update every stale hit in the SAME PR as the change.
3. NEVER restate mutable status (done / TBD / in-progress / merged / planned) in prose. Status lives in the tracker
   (YouTrack); prose links to the issue and never re-asserts its state. A hand-maintained status table in Markdown is
   the anti-pattern that produced the stale claude-run `## Phases` table (issues CLAUDE-171/172/174/175): the table said
   "TBD" for work that had shipped months earlier because status was duplicated in prose instead of read from the
   tracker.
4. Stale doc discovered mid-change but outside its scope: file a linked issue per the no-orphan-notes rule; do not
   silently leave it, and do not silently fix unrelated docs as a drive-by.

This is the doc analogue of the Completeness / Invariant Sweep: the failure mode is fixing the code and forgetting the
prose that describes it, so encode the sweep to run every time. No hook can judge semantic staleness, so this blocking
sweep at change time is the enforcement, not a commit hook.

## Documentation is never unit tested (MANDATORY)

A change to a static documentation file ships NO test, guard script, `just` recipe, or CI step that asserts its
wording. Not one. Documentation is prose for humans; there is no documentation server, nothing imports a `.md` file,
and no behaviour can regress. A regex suite over prose fails on every legitimate rewording and stays green while the
prose rots in any way the regex does not model, so it certifies nothing and bills maintenance forever.

**In scope (never tested):** `*.md`, `*.mmd`, `*.txt`, READMEs, ADRs, governance docs, issue and PR templates, prompt
and instruction files, changelogs. Anything whose audience is a person reading it.

**NOT in scope (keep their tests):** documentation IN code. Docstrings, doctests, `--help` output, executed examples,
type stubs, and generated docs whose generator is code are all code and are tested like code.

Rules:

- Verification for a doc change is reading the diff. A `grep` named in an issue or an acceptance criterion is an
  instruction to run it ONCE at review time; it is never a licence to commit that grep as a script, a test, a recipe,
  or a CI job.
- If a banned term genuinely must never return, express it in the linter the repo ALREADY runs (a cspell forbidden
  word, an existing lint rule). Never a new bespoke script, never a new CI job.
- The permitted file set for a doc issue is the doc files themselves. A diff that adds a `scripts/`, `tests/`, or
  `.github/workflows/` entry to a documentation change has failed the issue, whatever else it got right.

**Why:** IDBWEB-188 stated twice, in the approach and in an acceptance criterion, that it adds no guard script, `just`
recipe, or CI step. The run shipped `scripts/no-idb-clean-test.ts`, a `check-idb-clean` recipe wired into `just check`,
and a Lint job step, then listed the guard in its summary as a satisfied criterion. IDB-389 turned a human-run prompt
file into an 85-line pytest asserting sentences. A written prohibition alone did not hold, so this rule is stated once,
globally, and the file-set check in the issue is what enforces it.

# Plans live in one file, linking the tracker

Every multi-step / phased / roadmap / "we will do X then Y then Z" plan lives in ONE designated file per repo:
`docs/ROADMAP.md` (create it if absent). Rules:

- The file holds durable narrative ONLY: goals, phases, sequencing, architecture direction, the reasoning behind the
  order. It is the answer to "where is the plan?".
- Each phase / item links to its owning YouTrack epic or issue. Status is READ from the tracker, never duplicated as
  checkboxes or a status column in the file (same rule as Documentation Currency step 3).
- "Agreed in PR review" or "agreed in chat" is NOT a plan. A plan agreed anywhere is written to the plan file BEFORE the
  work starts, so it is discoverable, reviewable, and cannot evaporate into an un-searchable review thread. The
  claude-run phases existed only as an uncaptured PR-review discussion, which is exactly the gap this rule closes.
- A phase or plan item with no owning issue is invisible work: file it and link it (no-orphan-notes rule).
- If a repo already uses another name for this file (e.g. `TODO.md`), keep the name but bind it to these same rules
  (narrative plus tracker links, never duplicated status). Prefer `docs/ROADMAP.md` for new repos; "TODO" invites the
  checkbox-status anti-pattern.

# Tooling Gap Discipline

When a task needs functionality that the project's existing tool (the YouTrack MCP, `yt`, `fj`, `gh`, etc.) does not
expose, STOP. Do not reach for the REST API, parse the CLI's human output, scrape HTML, or hand-roll an equivalent.

- Default to the configured CLI. If it does not cover the case, that is the signal to extend the CLI, not bypass it.
- Surface the gap explicitly: state which tool, which capability is missing, and what the new command should look like.
  Ask whether to (a) file an issue against the tool and pause, (b) file an issue and proceed with a documented
  workaround, or (c) drop the requirement.
- Never silently substitute a REST call, raw HTTP, jq pipeline, or human-output parser for a missing CLI command. That
  re-implements auth, error handling, and field selection in every consumer.
- "Just temporarily" is the trap. Temporary REST calls become permanent forks. If a workaround is authorized, file the
  tracking issue first and reference it inline, e.g. `# TODO(YT-7): switch to yt project vcs once it lands`.

**Why:** Workarounds embed assumptions about the upstream tool that drift the moment the tool changes. Missing
capabilities should land in the canonical CLI, not scatter across action YAMLs, scripts, and Makefiles.

**Examples that trigger this rule:**

- The YouTrack MCP lacks a capability you need. Stop, file the issue against the MCP, do not hit the YouTrack REST API
  by hand.
- `fj` has no JSON output for `pr search`. Stop, file the issue, do not regex the human output.
- `gh` lacks a flag. Stop, file the issue, do not hit `/api/...` directly.

This rule also applies to nu helpers, shell wrappers, and Makefile targets that reimplement what a CLI should provide.

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
turns a failed CI run plus a follow-up fix PR into zero round-trips. This is the gap that produced the unformatted-code
CI failure tracked in A8N-69.

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

Every code change starts as a YouTrack issue, and every issue is PR-sized (see `## Issue granularity: one issue per
PR`). This rule exists to stop code landing with nothing tracking it; it is NOT a licence to split one change into
several smaller issues. A small fix spotted mid-task attaches to the issue whose PR carries it.

Use the YouTrack MCP (`mcp__youtrack__*` tools) for ALL YouTrack operations: create, read, search, update fields,
comment, link, change assignee, manage tags, log work. The MCP is the default and is verified
working end-to-end. Its tools are deferred in most sessions, so load their schemas with ToolSearch (e.g.
`select:mcp__youtrack__create_issue,mcp__youtrack__update_issue,mcp__youtrack__get_issue`) before the first call.

The `yt` CLI (at `/usr/local/bin/yt`, config under `$XDG_CONFIG_HOME/youtrack-cli/`, refresh with `yt update`) stays
installed for the few things the MCP does not expose (e.g. `yt project vcs`, used inside action YAML snippets) and as a
fallback. Do NOT hit the YouTrack REST API directly: if the MCP lacks a capability, follow the Tooling Gap Discipline
rule.

## Issue granularity: one issue per PR

The unit of an issue is the unit of REVIEW, not the unit of work. If two pieces of work will land in the same pull
request, they are ONE issue with multiple acceptance criteria, never two issues.

Sizing test, applied before EVERY `mcp__youtrack__create_issue` call: "would this get its own PR, reviewable and
mergeable on its own?" No -> it is an acceptance-criteria line on an existing issue. Yes -> its own issue.

- A checklist of steps inside one deliverable (add the handler, add the test, wire the CI job, update the README) is ONE
  issue whose steps are its acceptance criteria. IDBR-22 was filed as 7 issues and shipped as one PR
  (isimcha/idb-reports#3); IDBWEB-153/154/155/156 also shipped as one PR. Each should have been a single issue.
- Never split by file, layer, commit, or phase of the same change. "Backend part" plus "frontend part" plus "tests" of
  one feature is one issue unless each half genuinely merges and ships independently.
- Prefer growing an open issue's AC list over filing a sibling. `mcp__youtrack__update_issue` on the issue in flight is
  the default move; a new issue is the exception that needs justifying.
- Split ONLY on a real boundary: separate PRs, separate assignees, separate release timing, a hard blocker that must
  merge first, or work that can be dropped without touching the rest.
- Parent plus subtasks is for epics only, meaning 3+ genuinely separate PRs. Never build that structure for work one PR
  closes.
- When unsure, file the LARGER issue. An oversized issue is visible on the board and can be split later; four undersized
  ones are already lost.

**Why:** a small team assigns and tracks work per issue. N issues closed by one PR means N assignments, N status
updates, and N-1 duplicate reviews of the same diff.

## No orphan notes: every deferred item gets its own tracked, linked issue

NEVER leave a note, deferred item, descoped piece, "next round", "later", "out of scope", "follow-up", "TODO", or
known-gap inside a YouTrack issue, PR description, commit message, code comment, or chat hand-off WITHOUT creating a
separate YouTrack issue that tracks it. A note with no owning issue is invisible work with no owner, no priority, and no
dependency visibility. It gets lost.

The target is the thing nobody is tracking: a gap noticed in passing, a limitation, a "you should be aware of this"
that produces no code change in the current PR and so would otherwise vanish. It is NOT a reason to shard the change
in front of you.

Whenever you defer, descope, or discover anything outside the issue you are currently working, FIRST apply the sizing
test from `## Issue granularity: one issue per PR`. If the item ships in the SAME PR as the current issue, file nothing:
add it as an acceptance criterion on the current issue and say so in chat. Only items landing in a DIFFERENT PR, or
needing no PR at all, get their own issue. Then:

1. Create a new YT issue for the deferred item with a full spec (per the `## Issue body conventions` rules).
2. Link it to the current issue with `mcp__youtrack__link_issues`, using the dependency direction: the new issue "is
   required for" the current issue (equivalently, the current issue "depends on" the new one). Use the project's Depend
   link type for a true blocker; use "relates to" only when there is genuinely no dependency.
3. In the current issue (and in chat), replace the bare note with a reference to the new issue id, so it reads "X is
   tracked in #KEY-N and is required for this" rather than "X is left for later".

Concretely: "RLS enablement is the next round after the table audit" is FORBIDDEN as a naked sentence. It must become
"The `app.*` table audit is tracked in #KEY-N, which is required for the RLS enablement in this issue." The same rule
applies to every gap found mid-task (a missing test, a stale doc, a rename, a known limitation) that will land in a
different PR or in no PR: file it, link it, reference it by id. Items riding along in the current PR become AC lines on
the current issue, not new issues.

This generalizes the `## Known Gaps` anti-pattern: a gap documented only in prose (in CLAUDE.md, an issue, or a code
comment) with no tracking issue is a defect. Every gap statement carries its `#KEY-N`.

**Why:** Linked issues make the dependency graph explicit (you can see what blocks what), and nothing falls through the
cracks because someone forgot a sentence buried in a description.

## Filing vs working an issue

"File / open / queue a YT issue for X" (or "open an issue, don't work it") means create the issue with a full spec and
STOP: no branch, no code, no PR. Do NOT set the `AI Agent` field when filing; leave it unset (it renders as "No AI
Agent"). The user sets `AI Agent = Queued` themselves when they want the claude-run runner to pick the issue up (the
runner's query is `-Resolved AI Agent: Queued`); filing and handing off are two separate steps, and the handoff is the
user's to take. "Implement / fix / work X (and open a PR)" means do the full branch -> change -> test -> PR flow
yourself. When the request is ambiguous, ask which before acting.

## Human steps gate the MERGE, never the code (MANDATORY)

A human action NEVER sits in front of the code. Granting an IAM role, adding a repo or environment secret, creating a
queue, opening a firewall, rotating a credential, approving spend, flipping a console setting: every one of these is
sequenced AFTER the implementation and its PR, as a precondition of MERGING, not a precondition of STARTING. The code
that needs the permission can be written, reviewed, and staged without it, because the permission is applied before the
PR lands anyway. An issue that stops at "the service account lacks X" has converted a mergeable PR into manual cleanup
for the user, and has done so for a condition that was going to be satisfied before merge regardless.

When filing, structure the issue this way:

- The acceptance criteria cover the code and the PR, written against the environment AS IT IS TODAY. Never write an AC
  of the form "X is granted" as a step the implementer must complete first.
- Human prerequisites go in their own `## Before this PR is merged` section, each naming the exact action, the exact
  identifier (role name, secret name, project, queue, bucket), and who applies it. That section is the merge gate.
- Name which checks will be red until the human step is applied, and why. A red deploy job with a stated cause and a
  named fix is a normal review state, not a blocker.
- Where verification genuinely needs the granted access (a staging smoke test, an authenticated E2E), the AC reads
  "verified after the prerequisite in `## Before this PR is merged` is applied", and it is checked at merge time.

When WORKING an issue and a missing permission appears mid-run:

- Finish everything that does not depend on it, commit, and open the PR. Do not park the branch.
- Record the exact missing grant in the PR body and in an issue comment: the principal, the permission, the resource,
  and the command or console path that applies it.
- Say plainly in the PR that it must not merge until that grant lands. Then stop, having delivered the code.
- Never re-file the coding work as blocked. Blocked-on-permission is a merge note, not a stop condition.

**Why:** this has cost the runner whole cycles repeatedly. IDBR-29's staging verification parked because the CI service
account lacked `cloudtasks.queues.create` and `iam.serviceAccounts.getIamPolicy`, so the report function was never
redeployed to test against, while the code change itself needed neither permission. IDB-375 carries the same shape with
`DB_STAGING_URL` and `roles/iap.tunnelResourceAccessor`. In every case the grant was applied before the PR was accepted,
so putting it before the code bought nothing and cost a full run.

## The working agent must be able to finish the issue alone (MANDATORY, before every `create_issue`)

An issue handed to the claude-run runner is worked by an agent whose only powers are: read the repo, change the repo,
run the project's checks, open a PR. It CANNOT write to YouTrack (no field change, no comment, no article edit, no
state transition), cannot touch a cloud console, a secret store, or a merge button, cannot resolve a decision the issue
left open, and cannot ask a question. Every acceptance criterion it cannot execute turns into a parked ticket and comes
back as manual cleanup for the user, which is the exact opposite of why the issue was queued.

Before EVERY `mcp__youtrack__create_issue`, walk the acceptance criteria one line at a time and classify each as
agent-executable or not. Then:

1. **External mutation is NEVER an acceptance criterion.** Editing a knowledge base article, setting a field, posting a
   comment, flipping a console setting, rotating a secret, merging a PR: DO IT NOW, in the filing session, with the
   tools that session has, and record it in the body under `## Already done, not part of this issue`. If it truly
   cannot be done now, it becomes its own issue with a human owner, linked per the no-orphan-notes rule, and it is not
   queued to the agent.
2. **Unwritten content is a decision, not a criterion.** An AC of the shape "replace X with the description / the right
   wording / the convention" hands the agent an authoring decision it is not allowed to make. Either do the edit during
   filing, or paste the exact final text into the issue body verbatim in a fenced block. "Author something sensible for
   X" is the shape that always parks.
3. **Every AC is checkable from the repo, by inspection where that is the honest check.** Evidence comes from the
   working tree or the project's EXISTING check suite. An AC whose only evidence lives in a web UI the agent cannot
   open does not belong in the list. Verification is not a deliverable: a `grep` in an AC is run once, never committed
   (see `## Documentation is never unit tested`). Every issue names the file set its diff may touch, and carries an AC
   that the diff touches nothing else, verified with `git diff --stat`. A negative stated in prose does not hold; the
   file-set check does.
4. **Never hardcode tool names as the criterion.** The interactive session MCP and the runner's MCP expose different
   tool and parameter names for the same YouTrack operation. State the OUTCOME (the article exists under IDB-A-2 with
   this title and this content) and instruct the implementer to confirm the live tool schema at run time.
5. **Preflight before the handoff.** Before setting `AI Agent = Queued`, or before telling the user the issue is ready,
   re-read the AC list and answer per line: "can the agent complete this with repo access alone and only what is
   written in this issue?" Any `no` gets fixed before the handoff, not discovered by the runner.

**Why:** IDB-389 was filed with two ACs requiring YouTrack writes (replace article IDB-A-2's body; publish a proof
report). The runner did nine of eleven, parked at `Needs Review`, and asked for a human decision; the user then did the
article work by hand. Both steps were one MCP call each from the filing session. The filing session does the parts only
it can do, and hands over an issue that is completable end to end.

## Project keys (discover with `mcp__youtrack__find_projects`)

- `LC`: a8n-Lets Chat
- `YT`: Pandora-YouTrack CLI

## Issue body conventions

YouTrack issues are pure implementation specs. They must read as a directive an AI agent (or human) can implement
end-to-end without further clarification. No "Open questions" section, no "TBD", no "we should decide later". Every
decision the implementation needs is resolved BEFORE the issue is filed.

Workflow:

1. Draft the issue body in conversation context.
2. While drafting, identify every decision the implementation needs: class names, threshold directions, library choices,
   file layouts, AC numbers, naming conventions, taxonomy splits, etc.
3. For each open decision, STOP drafting and ask the user via `AskUserQuestion` (one tool call, 1-4 questions,
   multi-select where appropriate). Recommend an option; let the user override.
4. Fold the answers into the relevant Background / Goal / Proposed approach / AC sections. Cite the user's choice inline
   when the decision is non-obvious ("class is named `form-scan` per the MK-18 taxonomy choice").
5. Only then file the issue with `mcp__youtrack__create_issue`.

Required body shape (matches the LC-123 template):

- `## Background` (what currently exists, grounded in file paths / function names / table names)
- `## Goal`
- `## Proposed approach`
- `## Alternatives considered`
- `## Acceptance criteria` (checkbox list)

Ground every claim in the actual codebase. Speculative-but-plausible content gets rewritten later; invented file paths
get caught at code-read time.

Genuinely-unknowable decisions (depend on observation that can only be made during implementation, e.g. "the exact
threshold falls out of running against real fixtures") get stated as explicit assumptions inside `## Proposed approach`,
never as a separate "Open questions" section. Example:
`Assume panel_density_min = 0.05; revise if validation shows otherwise.` The implementing agent then knows the default
and the trigger to revise.

## Reference YouTrack issues from commits

YouTrack parses VCS commits for `#<ID>` (or `^<ID>`) and treats everything after the id, up to end of line, as commands
to apply to that issue. Reference: <https://www.jetbrains.com/help/youtrack/server/apply-commands-in-vcs-commits.html>.

**MANDATORY: every commit MUST include its owning YouTrack issue number as a bare `#<KEY>-N` reference in the commit
message body. No exceptions.** Every code change starts as a YouTrack issue (see the YouTrack Workflow section), so
every commit has an owning issue, and that issue's id MUST be in the commit. A commit with no `#<KEY>-N` reference is a
defect: without it the reviewer cannot tell which issue the commit serves and will incorrectly assume it belongs to
whatever issue they were last looking at. If a change somehow has no tracked issue, stop and file one before committing
rather than committing without a reference.

**Use a BARE `#<KEY>-N` reference (id only, nothing after it).** Because anything after the id is parsed as a command
and applied when the commit is PUSHED (not when the PR merges), a bare reference links the PR to the issue without
triggering any parse-time action. Make field changes explicitly via the MCP (assignee via
`mcp__youtrack__change_issue_assignee`, tags via `mcp__youtrack__manage_issue_tags`, comments via
`mcp__youtrack__add_issue_comment`, other fields via `mcp__youtrack__update_issue`), so the change happens when you
intend it, not on push.

Where the reference goes in the commit message body:

End of body, last block, one issue per line, BARE id with nothing after it. The subject line stays clean of `#<ID>`
(the PR title carries the id for human readers; the commit body carries the bare id so YouTrack links the PR). Example:

```
fix(issue): surface description on issue inspect

The CLI requested only idReadable / summary / customFields when inspecting
an issue and never deserialized the description...

#YT-1
```

Multiple issues in one commit:

```
chore(deps): bump pulldown_cmark and serde

#LC-200
#LC-201
```

Rules that interact:

- Do not hard-wrap the `#<ID>` line (per the commit-body rule above). Each issue reference lives on one line.
- Em-dash ban still applies to any comment text.
- Always create NEW commits, never amend. If a commit went out with a wrong parse-time command, correct it via the
  MCP (`mcp__youtrack__update_issue`), not by amending; do NOT amend.
- A `Co-Authored-By:` trailer (where the repo uses one) goes BELOW the `#<ID>` line, separated by a blank line, so the
  YT parser sees the reference cleanly at the end of the body.

Mutations via the MCP: field assignments via `mcp__youtrack__update_issue`, comments via
`mcp__youtrack__add_issue_comment`, assignee via `mcp__youtrack__change_issue_assignee`, tags via
`mcp__youtrack__manage_issue_tags`, work logging via `mcp__youtrack__log_work`, links via `mcp__youtrack__link_issues`.
Prefer these over a commit trailer so the change happens when you intend it, not on push. The MCP has no dry-run: check
legal values with `mcp__youtrack__get_issue_fields_schema` first.

## Common gotchas

- Setting a field the project does not define fails. Call `mcp__youtrack__get_issue_fields_schema` first and only pass
  `customFields` the schema lists. Some projects have no `Type` field (e.g. `YT`, `CLAUDE`); do not pass `Type` there.
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
