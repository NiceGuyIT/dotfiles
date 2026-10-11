# YouTrack Workflow (all repos)

Every code change starts as a YouTrack issue, and every issue is PR-sized. This file is the MANDATORY checklist that
must hold regardless of what else is in context. Full conventions, worked examples, and the issue-drafting workflow
live in the `youtrack-workflow` skill (invoke it, or type `/youtrack-workflow`, before drafting an issue body) - that
skill is reference material, this file is the compliance gate.

Use the `yt` CLI (via Bash) for YouTrack operations: create, read, search, update fields, comment, link, change
assignee, manage tags, log work. It covers everything the MCP does; discover syntax with `yt <command> --help` and
prefer `--description-file` / `--dry-run` for bodies and risky writes. The YouTrack MCP (`mcp__youtrack__*` tools) is the
FALLBACK, used only when a `yt` command fails or lacks the capability; load its schemas with ToolSearch first (e.g.
`select:mcp__youtrack__create_issue,mcp__youtrack__update_issue,mcp__youtrack__get_issue`). Say which one was used and
why when falling back. Never hit the YouTrack REST API directly: see `tooling-gap-discipline.md`. Discover project keys
with `yt project list` (MCP: `mcp__youtrack__list_projects`); never guess a key.

## 1. One issue per PR

Sizing test before EVERY issue creation (`yt issue create`): "would this get its own PR, reviewable and mergeable on its
own?" No -> it's an acceptance-criteria line on an existing issue (`yt issue update`), not a new issue.
Yes -> its own issue. Never split by file, layer, commit, or phase of one change. When unsure, file the LARGER issue.
**Why:** N issues closed by one PR means N assignments and N-1 duplicate reviews of the same diff.

## 2. Parent related work, never invent a parent (every issue creation)

A parent groups related tasks. Decide it deliberately on every issue creation:

- The issue belongs under an existing epic or milestone -> pass `parentIssue` in the SAME call that creates it, never
  as a follow-up link, the follow-up call is the one that gets skipped.
- An existing epic plausibly fits but it is not clear which -> ASK before creating.
- The issue is one of 3+ related issues (separate PRs) with no epic yet -> ask whether to file the epic first.
- The project has few open issues, or the issue relates to no other open work -> file it top-level without asking.
  Never create a catch-all epic just to give an issue a parent.

Set `Estimation` in that same call, it fails identically: omitted silently. `Start date` and `Sprints` are NOT
required, leave them unset unless the user asks for a specific date or sprint.
**Why:** an issue that belongs to an epic but is filed without it is absent from that epic's reports, and the gap is
only ever found by audit. An unrelated issue forced under a parent is the opposite failure: it makes the grouping
meaningless. Verify at the end of any session that created issues: every hit for `project: <KEYS> has: -{subtask of}`
is either a milestone root or an issue that fits no existing epic.

## 3. No orphan notes

Any deferred item, follow-up, "later," out-of-scope note, or known gap gets its own YouTrack issue, linked to the
current one via `yt issue link` ("is required for" / Depend, or "relates to" only with no real
dependency) - UNLESS it ships in the same PR as the current issue, in which case it's an acceptance-criteria line, not
a new issue (apply the sizing test from section 1 first). A doc that contradicts the live system is this same kind of
discovery and is always tracked, even when corrected in the current PR. Never leave a bare note with no owning issue.

## 4. Human steps gate the MERGE, never the code

IAM grants, secrets, queues, firewall rules, credential rotation, and other human actions are preconditions of
MERGING, never of starting. Never write an acceptance criterion of the form "X is granted" as a step the implementer
completes first; put human prerequisites in their own `## Before this PR is merged` section naming the exact action,
identifier, and owner. When a missing permission appears mid-run: finish everything else, commit, open the PR, record
the exact missing grant in the PR body and an issue comment, say plainly it must not merge yet, then stop. Never park
the branch or re-file the coding work as blocked.

`## Before this PR is merged` holds ONLY human actions the agent cannot perform. A step that runs, restores, or
exercises what the PR itself produces (a restore of a database for a restore-script PR, a trial run of a new script) is
never in it: the agent runs it itself in its own environment and records the result in the PR body. The AC says the
agent tested it; it never asks a human to. See `test-deliverable-yourself.md`.

## 5. The working agent must be able to finish the issue alone

The AI runner can only read/change the repo, run checks, and open a PR - it cannot write to YouTrack, touch a cloud
console or secret store, resolve an open decision, or ask a question. Before every issue creation:

- External mutation (field change, comment, console setting, secret rotation, merging a PR) is done NOW, at filing
  time, and recorded under `## Already done, not part of this issue` - never left as an AC. A YouTrack Knowledge Base
  article is never one of them: see section 8.
- Unwritten content ("use the right wording/convention") is a decision, not a criterion: author it during filing, or
  paste the exact final text into the issue body verbatim.
- Every AC is checkable from the repo alone (working tree or the project's existing check suite), and every issue
  names the file set its diff may touch, with an AC that `git diff --stat` confirms nothing else was touched.
- Never hardcode `yt` commands or MCP tool names as the criterion; state the outcome and let the implementer
  confirm the live schema.
- Preflight, run on EVERY issue before filing: re-read every AC and confirm "the agent can complete this with repo
  access alone and only what's written here." Any "no" gets fixed before handoff, not discovered by the runner. This
  preflight is what tells you the issue is workable as written, so it is never skipped.
- Completeness: for any issue that specifies configuration, the whole family is enumerated from the source of truth
  and the issue covers every member, per `completeness-invariant-sweep.md`. A narrower list is a defect, not a scope
  decision.

## 6. Filing vs working an issue

"File / open / queue X" means create the issue with a full spec and STOP - no branch, no code, no PR.
"Implement / fix X (and open a PR)" means do the full branch -> change -> test -> PR flow. Ask which when the request
is ambiguous.

Leave the `AI Agent` field unset on every filed issue: the user sets `Queued` themselves.

Never use the `AI Agent` field as a holding state: the field is the runner lifecycle
(Queued / Working / Needs Review / Done / Failed / Code Review). Tag `Needs-Info` ONLY when a person must make a
decision before the issue is workable, and add a one-line comment naming the decision. A dependency on another issue is
NOT a reason for `Needs-Info`: the YouTrack dependency link (section 3) already records it, so leave the issue
untagged until the dependency is Done.

## 7. Every commit AND every PR references its issues

Bare `#<KEY>-N` (id only, nothing after it - anything after it is parsed as a VCS command and fires on push) as the
LAST block of the commit body AND of the PR description, one issue per line, not hard-wrapped, listing EVERY issue the
change works. Only the attribution line the harness requires (`Co-Authored-By:` / `Generated with Claude Code`) may
sit below it. Never `Closes KEY-N`, `Fixes KEY-N`, `Tracked in KEY-N`, `Refs KEY-N`, a link, or any other wording in
place of the bare id: those forms are not acceptable even alongside it. Prose that mentions an issue elsewhere in the
body does not replace the final block. No exceptions: a change with no tracked issue gets one filed before committing. Make field changes (assignee, tags, comments, other fields) explicitly via `yt`,
never via a parse-time commit command. Always create NEW commits, never amend, to correct a wrong reference use
`yt`, not `--amend`.

## 8. Never write to YouTrack unbidden

A YouTrack write nobody asked for is invisible work in somebody else's system.

- **Write to YouTrack only when the current request asks for it** ("file an issue", "comment on X", "queue it", "link
  these"), or when a rule in this file requires it. Working an issue is NOT a licence to update it: the runner reports
  in its PR and its run summary, the bare `#<KEY>-N` in the commit body (section 7) is what links the work back to the
  issue, and a human or CI moves it from there. Never open or close a session by tidying fields, posting progress
  comments, or changing state nobody asked to be changed.
- **Never create or edit a Knowledge Base article while working an issue**, which is the bullet above applied to
  articles rather than a rule of its own: nobody asked for it. Two kinds of document exist, and they take different
  paths:
    - **Markdown files in `docs/`** follow the `kb-sync` path. The file is written in the repository and published as an
      article under the `Docs` parent article by CI, which reconciles both directions: an article edited in YouTrack is
      pulled back into its file, a file edited in the repository is pushed, and a pair that both changed since their
      last common sync fails loudly with neither side written. Edit the file, never the article, and never write the
      article directly.
    - **Documents that are not in `docs/`** are written directly as KB articles, and only when the current request asks
      for the article.

  A person editing an article IS legitimate; for a `docs/` pair, sync carries it back into the file, so editing either
  side is a normal way to change the document, not a way to lose work.
- **A `docs/` file that needs an article which does not exist yet** is a human step under
  `## Before this PR is merged` (section 4), naming the exact title under `Docs`. It is never a filing-time mutation,
  and the implementing agent never needs the article id: a file with no article mapping yet is valid, and the mapping
  is added once the article exists.

**Why:** an issue was once filed with a placeholder KB article created at filing time, reading section 5's "external
mutation is done NOW" as covering articles. Nobody had asked for an article, no diff reviewed a word of it, and the
content it was standing in for is CI's to publish.

## Common gotchas

- Setting a field the project doesn't define fails. Call `yt project fields` (MCP: `mcp__youtrack__get_issue_fields_schema`) first and
  only set fields the project lists.
- The em-dash ban (`user-preferences.md`) applies to YouTrack issue summaries, descriptions, and comments too.
