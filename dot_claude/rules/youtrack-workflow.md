# YouTrack Workflow (all repos)

Every code change starts as a YouTrack issue, and every issue is PR-sized. This file is the MANDATORY compliance gate.
Drafting workflow, body shape, rationale and examples live in the `youtrack-workflow` skill (invoke it before drafting
an issue body).

Use the `yt` CLI (via Bash) for YouTrack; discover syntax with `yt <command> --help` and prefer `--description-file` /
`--dry-run`. The YouTrack MCP (`mcp__youtrack__*`) is the FALLBACK, only when a `yt` command fails or lacks the
capability: load schemas with ToolSearch first and say which was used and why. Never hit the REST API directly
(`tooling-gap-discipline.md`). Find project keys with `yt project list`; never guess one.

## 1. One issue per PR

Before EVERY `yt issue create`: "would this get its own PR, reviewable and mergeable on its own?" No -> it is an
acceptance-criteria line on an existing issue (`yt issue update`). Yes -> its own issue. Never split by file, layer,
commit, or phase of one change. When unsure, file the LARGER issue.

## 2. Parent related work, never invent a parent (every issue creation)

Only an epic or milestone root (an issue that exists to group, with no work of its own) is ever a parent. An issue with
work NEVER gets a child task: closing a child auto-closes the parent, and the runner treats a parent as blocked by its
children. Relate two work issues with `depends on` / `is required for`, or `relates to` when neither blocks the other,
never `subtask of`. Only an epic is ever a parent, and nothing else is ever filed as a subtask. Before passing a parent,
run `yt issue inspect` on the candidate and confirm it is a pure grouping root (its only acceptance criterion is that its
children are resolved, and it has no code work of its own). Unsure it is an epic -> top-level and ask. Decide the parent
on every creation:

- Belongs under an existing epic or milestone -> pass `parentIssue` in the SAME create call, never as a follow-up link.
- An epic plausibly fits but it is unclear which -> ASK before creating.
- One of 3+ related issues (separate PRs) with no epic yet -> ask whether to file the epic first.
- Few open issues, or no related open work -> top-level, no ask. Never create a catch-all epic to give an issue a parent.

Set `Estimation` in that same create call (omitted silently otherwise). Leave `Start date` and `Sprints` unset unless
asked. Audit after any session that created issues: every hit for `project: <KEYS> has: -{subtask of}` is a milestone
root or an issue that fits no existing epic.

## 3. No orphan notes

Any deferred item, follow-up, "later", out-of-scope note, or known gap gets its own issue, linked via `yt issue link`
("is required for", or "relates to" only with no real dependency), UNLESS it ships in the same PR (then it is an
acceptance-criteria line; apply the section 1 test first). A doc that contradicts the live system is always tracked,
even when corrected in the current PR. Never leave a bare note with no owning issue.

## 4. Human steps gate the MERGE, never the code

IAM grants, secrets, queues, firewall rules, credential rotation and other human actions are preconditions of MERGING,
never of starting. Never write an AC like "X is granted" for the implementer; put them in a
`## Before this PR is merged` section naming the exact action, identifier, and owner. Missing permission mid-run:
finish everything else, commit, open the PR, record the exact grant in the PR body and an issue comment, say plainly it
must not merge yet, then stop. Never park the branch or re-file the coding work as blocked.

That section holds ONLY human actions the agent cannot perform. Running, restoring, or exercising what the PR produces
is the agent's job (`testing.md`).

## 5. The working agent must be able to finish the issue alone

The AI runner can only read/change the repo, run checks, and open a PR. It cannot write to YouTrack, touch a cloud
console or secret store, resolve an open decision, or ask a question. Before every issue creation:

- External mutation (field change, comment, console setting, secret rotation, PR merge) is done NOW, at filing time, and
  recorded under `## Already done, not part of this issue`. A Knowledge Base article is never one of them (section 8).
- Unwritten content ("use the right wording") is a decision: author it during filing or paste the exact final text.
- Every AC is checkable from the repo alone, and the issue names the file set its diff may touch, with an AC that
  `git diff --stat` confirms nothing else changed.
- Never hardcode `yt` commands or MCP tool names as the criterion; state the outcome.
- Preflight on EVERY issue: re-read every AC and confirm the agent can complete it with repo access alone and only
  what is written. Any "no" is fixed before handoff. The result decides `AI Agent` (section 6).
- Configuration issues enumerate the whole family from the source of truth (`completeness-invariant-sweep.md`).

## 6. Filing vs working an issue

"File / open / queue X" means create the issue with a full spec and STOP: no branch, no code, no PR. "Implement / fix X"
means the full branch -> change -> test -> PR flow. Ask which when ambiguous.

Queue by default: an issue that PASSES the section 5 preflight gets `AI Agent = Queued` in the SAME create call; the
same applies when an existing issue becomes workable (`yt issue update` / `yt issue set-field`, or `yt issue apply`
when the field is not writable that way). Leave `AI Agent` unset ONLY when the issue is not workable, and say why:

- The section 5 preflight fails (open decision, missing external mutation, AC not checkable from the repo).
- A human step is also a precondition of STARTING (rare; human steps normally gate the merge only).
- It depends on an issue not yet Done (link it per section 3; queue it once the dependency is Done).
- The user said not to queue it, or asked for a draft.

`AI Agent` is the runner lifecycle (Queued / Working / Needs Review / Done / Failed / Code Review); never park an
unqueued issue in it. Tag `Needs-Info` ONLY when a person must decide something, with a one-line comment naming the
decision. A dependency is NOT a reason for `Needs-Info`: the link records it.

## 7. Every commit AND every PR references its issues

Bare `#<KEY>-N` (id only; anything after it is parsed as a VCS command) as the LAST block of the commit body AND the PR
description, one issue per line, not hard-wrapped, listing EVERY issue the change works. Only the harness attribution
line may sit below it. Never `Closes` / `Fixes` / `Tracked in` / `Refs` KEY-N, a link, or other wording, even alongside
the bare id. Prose mentions elsewhere do not replace the final block. A change with no tracked issue gets one filed
before committing. Make field changes via `yt`, never a parse-time commit command. Always create NEW commits, never
amend; fix a wrong reference with `yt`.

## 8. Never write to YouTrack unbidden

- Write only when the current request asks for it ("file", "comment on", "queue", "link") or a rule here requires it.
  Working an issue is NOT a licence to update it: the PR, run summary and bare id in the commit body report the work.
  Never tidy fields, post progress comments, or change state nobody asked for.
- Never create or edit a Knowledge Base article while working an issue. Markdown files in `docs/` follow the `kb-sync`
  path: edit the file, never the article (CI publishes it under the `Docs` parent and reconciles both directions; a pair
  that both changed fails loudly with neither side written). Documents outside `docs/` are written as KB articles only
  when the request asks. A person editing an article is legitimate; sync carries it back.
- A `docs/` file needing an article that does not exist yet is a human step under `## Before this PR is merged` naming
  the exact title under `Docs`. The file with no article mapping is valid; the mapping is added once the article exists.

## 9. The dependency graph is acyclic

"A waits for B" covers `depends on` (A -> B), `is required for` (B -> A), `subtask of` (parent waits for child), and
any other blocking verb. Before each link, walk B's blockers to the end of the chain; if A is reachable, do not create
the link. After linking, run `yt issue inspect` on every issue touched and confirm none loops back.

- An AC never needs something that exists only after this issue's own PR is open or merged. Drop it or leave it to a
  human; never move it into a linked issue.
- A follow-up that needs this issue finished is linked `relates to`, or as a blocker of the follow-up, never a child.
- Existing cycle: report the keys and the links closing the loop. Remove a link you created; ask before removing one
  someone else (including the runner) created.

**Why:** a cycle looks like ordinary queued work, so both issues sit in `Queued` until a human notices.

## Common gotchas

- Setting a field the project does not define fails: call `yt project fields` first and set only what it lists.
- The em-dash ban (`user-preferences.md`) and `no-internal-names.md` apply to issue summaries, descriptions, comments.
