---
name: youtrack-workflow
description: How to draft and file a YouTrack issue - the issue-body workflow (identify open decisions, resolve them via AskUserQuestion before filing, required Background/Goal/Proposed approach/Alternatives/Acceptance criteria shape), plus the fuller rationale and examples behind the mandatory YouTrack rules. TRIGGER before calling mcp__youtrack__create_issue or mcp__youtrack__update_issue with new acceptance criteria, when the user says "file/open/create/queue a YouTrack issue" or "write an issue for X", or when wording acceptance criteria. The MANDATORY compliance checklist itself (one issue per PR, every issue has a parent, no orphan notes, human-steps-gate-merge, agent-must-finish-alone, commit references) already lives in the always-loaded rules/youtrack-workflow.md - that file is the compliance gate and applies regardless of whether this skill loads; this skill is reference material for HOW to draft good content once you've decided to file.
---

# YouTrack issue-drafting workflow

This skill is the detailed how-to companion to `~/.claude/rules/youtrack-workflow.md`, which holds the MANDATORY
checklist (one issue per PR, parenting, no orphan notes, human-steps-gate-merge, agent-must-finish-alone, commit
references). Read that file first for what must never be skipped; this file is for drafting quality once you're
filing.

## Issue body conventions

YouTrack issues are pure implementation specs. They must read as a directive an AI agent (or human) can implement
end-to-end without further clarification. No "Open questions" section, no "TBD", no "we should decide later". Every
decision the implementation needs is resolved BEFORE the issue is filed.

Workflow:

1. Draft the issue body in conversation context.
2. While drafting, identify every decision the implementation needs: class names, threshold directions, library
   choices, file layouts, AC numbers, naming conventions, taxonomy splits, etc.
3. For each open decision, STOP drafting and ask the user via `AskUserQuestion` (one tool call, 1-4 questions,
   multi-select where appropriate). Recommend an option; let the user override.
4. Fold the answers into the relevant Background / Goal / Proposed approach / AC sections. Cite the user's choice
   inline when the decision is non-obvious ("class is named `form-scan` per the taxonomy choice made when filing").
5. Only then file the issue with `mcp__youtrack__create_issue`.

Required body shape:

- `## Background` (what currently exists, grounded in file paths / function names / table names)
- `## Goal`
- `## Proposed approach`
- `## Alternatives considered`
- `## Acceptance criteria` (checkbox list)

Ground every claim in the actual codebase. Speculative-but-plausible content gets rewritten later; invented file
paths get caught at code-read time.

Genuinely-unknowable decisions (depend on observation that can only be made during implementation, e.g. "the exact
threshold falls out of running against real fixtures") get stated as explicit assumptions inside
`## Proposed approach`, never as a separate "Open questions" section. Example:
`Assume panel_density_min = 0.05; revise if validation shows otherwise.` The implementing agent then knows the
default and the trigger to revise.

## Why the mandatory rules exist (fuller context for edge-case judgment)

**One issue per PR.** A small team assigns and tracks work per issue. N issues closed by one PR means N assignments,
N status updates, and N-1 duplicate reviews of the same diff. One deliverable was filed as 7 issues and shipped as a
single PR; another was filed as 4 issues and also shipped as a single PR. Each should have been one issue. Prefer
growing an open issue's AC list over filing a sibling: `mcp__youtrack__update_issue` on the issue in flight is the
default move, a new issue is the exception that needs justifying. Split ONLY on a real boundary: separate PRs,
separate assignees, separate release timing, a hard blocker that must merge first, or work that can be dropped
without touching the rest. Parent-plus-subtasks is for epics only (3+ genuinely separate PRs) - never build that
structure for work one PR closes.

**Every issue has a parent.** Across three projects, parenting held cleanly for weeks and then stopped abruptly
mid-session, while filing bugs during implementation work. 38 issues were created with no parent over the following
36 hours and were absent from every milestone report in that window. Nothing failed and nothing warned; the gap was
found only by an audit, and three more orphans were created during the audit itself. **The failure mode is reactive
filing**: when filing an issue IS the task, the parent gets set; when an issue is filed as a side effect of other
work (a bug noticed mid-change, a follow-up spun out of review, a batch opened during debugging), every field gets
skipped, the parent included. Filing during other work is when the rule applies hardest, not when it relaxes.

**No orphan notes.** The target is the thing nobody is tracking: a gap noticed in passing, a limitation, a "you
should be aware of this" that produces no code change in the current PR and would otherwise vanish. Concretely,
"RLS enablement is the next round after the table audit" is FORBIDDEN as a naked sentence; it must become "The
`app.*` table audit is tracked in #KEY-N, which is required for the RLS enablement in this issue." A doc that
contradicts the live system gets an issue recording both sides (what the doc says with file/line, what the system
shows with the command and its output, and which is wrong) even when you fix the doc in the current PR - a doc wrong
once is evidence about how it was written, prompting a sweep of its neighbours. This generalizes the "Known Gaps"
anti-pattern: a gap documented only in prose (CLAUDE.md, an issue, a code comment) with no tracking issue is a
defect. Linked issues make the dependency graph explicit and nothing falls through the cracks because someone forgot
a sentence buried in a description.

**Human steps gate the merge.** This has cost whole cycles repeatedly. One issue's staging verification parked
because the CI service account lacked `cloudtasks.queues.create` and `iam.serviceAccounts.getIamPolicy`, so the
function under test was never redeployed, while the code change itself needed neither permission. Another carried
the same shape with a staging database URL secret and `roles/iap.tunnelResourceAccessor`. In every case the grant
was applied before the PR was accepted, so putting it before the code bought nothing and cost a full run. Name which
checks will be red until the human step is applied, and why - a red deploy job with a stated cause and a named fix
is a normal review state, not a blocker.

**The working agent must finish alone.** One issue was filed with two ACs requiring YouTrack writes (replace a
knowledge-base article's body; publish a proof report). The runner did nine of eleven, parked at `Needs Review`, and
asked for a human decision; the user then did the article work by hand. Both steps were one MCP call each from the
filing session. The filing session does the parts only it can do, and hands over an issue that is completable end to
end.

## Commit reference examples

End of body, last block, one issue per line, bare id with nothing after it. The subject line stays clean of `#<ID>`
(the PR title carries the id for human readers; the commit body carries the bare id so YouTrack links the PR):

```
fix(issue): surface description on issue inspect

The CLI requested only idReadable / summary / customFields when inspecting
an issue and never deserialized the description...

#PROJ-1
```

Multiple issues in one commit:

```
chore(deps): bump pulldown_cmark and serde

#PROJ-200
#PROJ-201
```

A `Co-Authored-By:` trailer (where the repo uses one) goes BELOW the `#<ID>` line, separated by a blank line, so the
YouTrack parser sees the reference cleanly at the end of the body.

## Common gotchas

- Setting a field the project does not define fails. Call `mcp__youtrack__get_issue_fields_schema` first and only
  pass `customFields` the schema lists. Some projects have no `Type` field at all; do not pass `Type` there.
- The interactive session MCP and the runner's MCP can expose different tool/parameter names for the same operation.
  State the outcome in an AC, not a specific tool name, and let the implementer confirm the live schema at run time.
