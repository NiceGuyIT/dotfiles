---
name: yt-file
description: File a YouTrack issue from a short free-text report and queue it for the AI agent, then STOP (no branch, no code, no PR). Invoke as `/yt-file <description> [link] [logs or log path] [image path or pasted image]`.
argument-hint: <description> [link] [logs] [image]
---

# /yt-file: file a YouTrack issue and queue it

The user's arguments are a raw report: a description, plus optionally a link, logs, and an image. "File" means create
the issue with a full spec and STOP. Do not create a branch, edit code, or open a PR.

The mandatory rules live in `~/.claude/rules/youtrack-workflow.md` and apply in full (sizing test, parenting,
estimation, no orphan notes, agent-must-finish-alone preflight, queue-on-file, no internal names, ASCII only, no
em-dash). Invoke the `youtrack-workflow` skill for the body shape. This file only adds the intake and the finish.

## 1. Sort the arguments

- Description: the report itself. It becomes Background, Goal and Proposed approach.
- Link: goes under `## References`. A link to another tracker issue also gets a `yt issue link` after creation.
- Logs: inline text or a file path. Read the file. Put the relevant lines in a fenced block under `## Evidence`,
  sanitized per `no-internal-names.md` (replace hostnames, IPs, people and tenants with roles or reserved
  placeholders; keep the message text).
- Image: a pasted image or a path. Attach it after creation with `yt issue attachment add` (confirm syntax with
  `yt issue attachment add --help`). A pasted image with no file on disk cannot be attached: say so, describe it in
  the body, and ask for a path. Never skip it silently. If `yt` cannot attach, that is a tooling gap, not a reason to
  hit the REST API (`tooling-gap-discipline.md`).

## 2. Pick the project

Infer the key from the current repo (CLAUDE.md, recent commit trailers, branch names). Confirm it with
`yt project list`. If it is not clear, ask in plain prose. Never guess a key.

## 3. Draft and check

1. Ground the body in the repo: real file paths and function names, read this turn.
2. Run the sizing test (one PR?) and the parent check (does an existing epic fit?). Pass `--parent` and
   `--estimation` in the create call.
3. Run the agent-must-finish-alone preflight on every acceptance criterion.
4. Resolve open decisions by asking the user in plain prose (no `AskUserQuestion` preview field), then file.

## 4. File and queue

1. Write the body to a temp file in the scratchpad and pass `--description-file`.
2. Confirm the field names with `yt project fields`, then create with the queue field in the SAME call:
   `yt issue create --project <KEY> --summary "<summary>" --description-file <path> --estimation <minutes> --field "AI Agent=Queued"`
   (plus `--parent <KEY-N>` when an epic fits). Use `--dry-run` first if any field is uncertain.
3. Attach the image, add any link, then re-read the issue with `yt issue inspect` this turn.
4. Leave `AI Agent` unset only when the preflight fails, a dependency has not landed, or the user said not to queue it.
   Say the reason plainly. Tag `Needs-Info` only when a person must decide something.

## 5. Report

One short block: issue key and URL, the fields set (parent, estimation, `AI Agent`), what was attached, and anything
left unqueued with the reason. Nothing else.
