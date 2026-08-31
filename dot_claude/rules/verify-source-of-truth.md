# Verify the Source of Truth FIRST (MANDATORY, everything)

This is not a debugging rule. It governs EVERY action and EVERY statement: answering a question, reading code, editing
a file, writing a doc or an issue, opening a PR, recommending a tool or service, and reporting that work is done.
Before forming a hypothesis, stating a finding, making a change, or using the words "proven" / "fixed" / "confirmed" /
"in use" / "still broken", refresh from the authoritative source and read the live value THIS TURN.

NEVER reason from cached state: conversation history, an earlier Read, a prior tool result, a summary, a local draft,
a saved memory, remote-tracking refs, local image layers, or "what I saw earlier". Assume everything already in context
is stale until re-verified this turn. Context goes stale WITHIN a single session: between turns the user edits files,
fixes the bug you were about to report, merges the PR, decommissions the service, and rewrites the document. None of
that appears in what you already hold. If you cannot reach the source of truth, say so explicitly and stop, do not
guess.

- **files:** Read the file from disk this turn. Do not trust an earlier Read, a summary, or context-window contents.
  The user edits files between turns and expects you to see it.
- **git:** `git fetch origin --prune` (or `git ls-remote origin <ref>` for server truth with no local cache) BEFORE
  comparing against `origin/*`. A bare `origin/main` in your repo is a stale snapshot, not the remote.
- **docker / OCI images:** `docker pull <ref>` (or `docker manifest inspect` / `skopeo inspect`) before claiming what a
  tag contains. A local image with that tag may be old; query the registry digest.
- **packages / releases:** Query the registry or release API for the live version, do not infer from a manifest you
  remember or a tag you assume points somewhere.
- **HTTP / APIs / config:** Re-fetch the endpoint or re-read the config now. Last response is not current state.
- **Shared documents you are about to WRITE** (YouTrack articles and issues, wikis, anything the user can edit
  concurrently): re-fetch immediately before writing and merge your change into the live content. These updates are
  full-content replacements, so a write assembled from a local draft silently DELETES every edit made since you last
  read it, with no diff and no warning.
- **Services and infrastructure:** confirm a host, endpoint, instance, or integration is still in use before naming it
  as current. A decommissioned service sitting in your context reads as live and sends the user to the wrong place.
- **Your own earlier claims in this session:** before repeating that something is broken, missing, unfixed, or still to
  do, re-check it. It may have been fixed several turns ago, by the user or by you.
- **Documentation, including this repo's own:** a README, architecture doc, plan file, ADR, or code comment records
  what someone believed when they wrote it, and an AI assistant may have written it. Treat it exactly like a saved
  memory: a lead to verify, never the evidence. Confirm the resource, tag, subnet, path, or service it names against
  the live system before repeating it, relying on it, or building on it.
- **Saved memories:** a memory records what was true when written. Verify the file, flag, or service it names still
  exists before recommending anything based on it.
- **Completeness:** Verify EVERY relevant entry, not the first matching line. One green line does not prove the set
  (e.g. a workspace lock has one entry per crate; checking one missed that the others were stale).

**Why:** confidently reporting stale data as current wastes the user's time and erodes trust, and a stale WRITE
destroys work outright. Querying the source of truth costs one command; being wrong costs the whole session.
