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

## 5. The working agent must be able to finish the issue alone

The AI runner can only read/change the repo, run checks, and open a PR - it cannot write to YouTrack, touch a cloud
console or secret store, resolve an open decision, or ask a question. Before every issue creation:

- External mutation (KB article edit, field change, comment, console setting, secret rotation, merging a PR) is done
  NOW, at filing time, and recorded under `## Already done, not part of this issue` - never left as an AC.
- Unwritten content ("use the right wording/convention") is a decision, not a criterion: author it during filing, or
  paste the exact final text into the issue body verbatim.
- Every AC is checkable from the repo alone (working tree or the project's existing check suite), and every issue
  names the file set its diff may touch, with an AC that `git diff --stat` confirms nothing else was touched.
- Never hardcode `yt` commands or MCP tool names as the criterion; state the outcome and let the implementer
  confirm the live schema.
- Preflight, run on EVERY issue before filing: re-read every AC and confirm "the agent can complete this with repo
  access alone and only what's written here." Any "no" gets fixed before handoff, not discovered by the runner. This
  preflight is what decides the `AI Agent` field in section 6, so it is never skipped.
- Completeness: for any issue that specifies configuration, the whole family is enumerated from the source of truth
  and the issue covers every member, per `completeness-invariant-sweep.md`. A narrower list is a defect, not a scope
  decision.

## 6. Filing vs working an issue

"File / open / queue X" means create the issue with a full spec and STOP - no branch, no code, no PR.
"Implement / fix X (and open a PR)" means do the full branch -> change -> test -> PR flow. Ask which when the request
is ambiguous.

Queue by default. A filed issue that PASSES the section 5 preflight gets `AI Agent = Queued` in the SAME
create call, so the runner can start it with no second human step; the same applies when an existing issue is
updated into a workable state (`yt issue update` / `yt issue set-field`, or `yt issue apply` when the field is not writable that
way). This is the whole point of writing agent-completable issues: an issue that could be worked and is not queued is
work that silently waits on a human.

Leave `AI Agent` unset ONLY when the issue is not workable as written, and say so plainly in the response with the
reason. The cases:

- The section 5 preflight fails: an open decision, a missing external mutation, an AC that is not checkable from the
  repo alone.
- A `## Before this PR is merged` human step (section 4) is also a precondition of STARTING, which is rare - human
  steps normally gate the merge, not the code, so this alone is not a reason to hold the queue.
- The issue depends on another issue that has not landed yet (link it per section 3 and queue it when the dependency
  is Done).
- The user said not to queue it, or asked for a draft.

Never park an unqueued issue in the `AI Agent` field: the field is the runner lifecycle
(Queued / Working / Needs Review / Done / Failed / Code Review). Tag `Needs-Info` ONLY when a person must make a
decision before the issue is workable, and add a one-line comment naming the decision. A dependency on another issue is
NOT a reason for `Needs-Info`: the YouTrack dependency link (section 3) already records it, so leave the issue
untagged and unqueued until the dependency is Done.

## 7. Every commit AND every PR references its issues

Bare `#<KEY>-N` (id only, nothing after it - anything after it is parsed as a VCS command and fires on push) as the
LAST block of the commit body AND of the PR description, one issue per line, not hard-wrapped, listing EVERY issue the
change works. Only the attribution line the harness requires (`Co-Authored-By:` / `Generated with Claude Code`) may
sit below it. Never `Closes KEY-N`, `Fixes KEY-N`, `Tracked in KEY-N`, `Refs KEY-N`, a link, or any other wording in
place of the bare id: those forms are not acceptable even alongside it. Prose that mentions an issue elsewhere in the
body does not replace the final block. No exceptions: a change with no tracked issue gets one filed before committing. Make field changes (assignee, tags, comments, other fields) explicitly via `yt`,
never via a parse-time commit command. Always create NEW commits, never amend, to correct a wrong reference use
`yt`, not `--amend`.

## Common gotchas

- Setting a field the project doesn't define fails. Call `yt project fields` (MCP: `mcp__youtrack__get_issue_fields_schema`) first and
  only set fields the project lists.
- The em-dash ban (`user-preferences.md`) applies to YouTrack issue summaries, descriptions, and comments too.
