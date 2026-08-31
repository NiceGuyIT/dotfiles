# YouTrack Workflow (all repos)

Every code change starts as a YouTrack issue, and every issue is PR-sized. This file is the MANDATORY checklist that
must hold regardless of what else is in context. Full conventions, worked examples, and the issue-drafting workflow
live in the `youtrack-workflow` skill (invoke it, or type `/youtrack-workflow`, before drafting an issue body) - that
skill is reference material, this file is the compliance gate.

Use the YouTrack MCP (`mcp__youtrack__*` tools) for ALL YouTrack operations: create, read, search, update fields,
comment, link, change assignee, manage tags, log work. Load tool schemas with ToolSearch first (e.g.
`select:mcp__youtrack__create_issue,mcp__youtrack__update_issue,mcp__youtrack__get_issue`). The `yt` CLI is a fallback
for the few things the MCP doesn't expose. Never hit the YouTrack REST API directly: see `tooling-gap-discipline.md`.
Discover project keys with `mcp__youtrack__find_projects`; never guess a key.

## 1. One issue per PR

Sizing test before EVERY `mcp__youtrack__create_issue`: "would this get its own PR, reviewable and mergeable on its
own?" No -> it's an acceptance-criteria line on an existing issue (`mcp__youtrack__update_issue`), not a new issue.
Yes -> its own issue. Never split by file, layer, commit, or phase of one change. When unsure, file the LARGER issue.
**Why:** N issues closed by one PR means N assignments and N-1 duplicate reviews of the same diff.

## 2. Every issue has a parent (every `create_issue` call)

Pass `parentIssue` in the SAME call that creates the issue, never as a follow-up link, the follow-up call is the one
that gets skipped. Only milestones/top-level epics may have no parent. Set `Start date`, `Estimation`, and `Sprints`
in that same call, they fail identically: omitted silently. If the right parent isn't obvious, ASK before creating.
**Why:** an unparented issue is invisible, it appears in no milestone report and no sprint board, and the gap is only
ever found by audit. Verify at the end of any session that created issues: `project: <KEYS> has: -{subtask of}`
should return nothing outside milestone roots.

## 3. No orphan notes

Any deferred item, follow-up, "later," out-of-scope note, or known gap gets its own YouTrack issue, linked to the
current one via `mcp__youtrack__link_issues` ("is required for" / Depend, or "relates to" only with no real
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
console or secret store, resolve an open decision, or ask a question. Before every `create_issue`:

- External mutation (KB article edit, field change, comment, console setting, secret rotation, merging a PR) is done
  NOW, at filing time, and recorded under `## Already done, not part of this issue` - never left as an AC.
- Unwritten content ("use the right wording/convention") is a decision, not a criterion: author it during filing, or
  paste the exact final text into the issue body verbatim.
- Every AC is checkable from the repo alone (working tree or the project's existing check suite), and every issue
  names the file set its diff may touch, with an AC that `git diff --stat` confirms nothing else was touched.
- Never hardcode MCP tool names as the criterion; state the outcome and let the implementer confirm the live schema.
- Preflight before setting `AI Agent = Queued`: re-read every AC and confirm "the agent can complete this with repo
  access alone and only what's written here." Any "no" gets fixed before handoff, not discovered by the runner.

## 6. Filing vs working an issue

"File / open / queue X" means create the issue with a full spec and STOP - no branch, no code, no PR, and leave the
`AI Agent` field unset (the user sets `Queued` themselves). "Implement / fix X (and open a PR)" means do the full
branch -> change -> test -> PR flow. Ask which when the request is ambiguous.

## 7. Every commit references its issue

Bare `#<KEY>-N` (id only, nothing after it - anything after it is parsed as a VCS command and fires on push) as the
LAST block of the commit body, one issue per line, not hard-wrapped. No exceptions: a change with no tracked issue
gets one filed before committing. Make field changes (assignee, tags, comments, other fields) explicitly via the MCP,
never via a parse-time commit command. Always create NEW commits, never amend, to correct a wrong reference use the
MCP, not `--amend`.

## Common gotchas

- Setting a field the project doesn't define fails. Call `mcp__youtrack__get_issue_fields_schema` first and only pass
  `customFields` the schema lists.
- The em-dash ban (`user-preferences.md`) applies to YouTrack issue summaries, descriptions, and comments too.
