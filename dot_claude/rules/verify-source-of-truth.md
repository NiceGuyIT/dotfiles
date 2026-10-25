# Verify the Source of Truth FIRST (MANDATORY, everything)

This governs EVERY action and EVERY statement: answering, reading code, editing, writing a doc or issue, opening a PR,
recommending a tool, reporting work done. Before forming a hypothesis, stating a finding, making a change, or using
"proven" / "fixed" / "confirmed" / "in use" / "still broken", read the live value from the authoritative source THIS TURN.

NEVER reason from cached state: conversation history, an earlier Read, a prior tool result, a summary, a local draft,
a saved memory, remote-tracking refs, local image layers. Assume everything in context is stale until re-verified this
turn: the user edits files, fixes bugs, merges PRs and decommissions services between turns. If the source is
unreachable, say so and stop; do not guess.

**Exception: facts the user states.** An infrastructure fact the user states (a host was renamed or retired, a
directory is decommissioned, an item is to be ignored, how two things relate) is accepted as given and used in the
work. Never verify it, question it, flag it as a conflict or warning, or write a conclusion that contradicts it. This
overrides everything else in this file. The duty to verify applies to facts I find myself, never to facts the user gave me.

## Answer gate (blocks every reply)

Before any reply stating a fact about a file, repo, issue, PR, service or tool:

1. Name the command or file read from THIS turn that backs each claim. None -> run the check now, or write
   "unverified" next to the claim.
2. Read the WHOLE file before describing what it does or telling the user to run it. A header, flag list or grep hit is
   not the file.
3. A command that reports changes (`git pull` with "N files changed", a new commit, a changed issue state) makes every
   earlier claim about those things stale. Re-check before the next reply.
4. Summaries are claims, not evidence: an agent report, PR description, issue comment, doc. Check the thing described.
5. "Is it still true?" is the first step of any follow-up about earlier work, including your own earlier claims that
   something is broken, missing, or still to do.
6. When challenged, re-derive the fact with a command this turn, then re-check the adjacent claims that rest on the same
   source. A landed challenge means the source is unreliable, not that one sentence was unlucky.

## Sources

- **files:** Read from disk this turn.
- **git:** `git fetch origin --prune` (or `git ls-remote origin <ref>`) BEFORE comparing against `origin/*`.
- **docker / OCI images:** `docker pull` or `docker manifest inspect` / `skopeo inspect` before claiming what a tag
  contains.
- **packages / releases:** query the registry or release API for the live version.
- **HTTP / APIs / config:** re-fetch or re-read now.
- **Shared documents you are about to WRITE** (YouTrack articles and issues, wikis, anything editable concurrently):
  re-fetch immediately before writing and merge into the live content. These updates are full replacements, so a write
  from a local draft silently deletes every edit made since you last read.
- **Services and infrastructure:** confirm a host, endpoint or integration is still in use before naming it as current.
  Skip this for a fact the user stated.
- **Saved memories:** verify the file, flag, or service a memory names still exists before recommending it.
- **Completeness:** verify EVERY relevant entry, not the first match. One green line does not prove the set; one runner
  config, host, or lock entry is a sample, not the fleet.

## Documentation is a claim, never evidence

A README, architecture doc, plan file, ADR or code comment records what someone believed when writing it (possibly an
AI assistant, compounding unverified guesses into confident prose). The system is the evidence: running infrastructure,
live config, the deployed resource, the tool's own source. The code in the working tree IS the system for code claims.

**Before you propose:**
- Verify the claim the proposal rests on against the system this turn, not the doc describing it. For a third-party
  tool, fetch its docs or source.
- Check whether the thing you call necessary, impossible, or new is already running (one list command usually settles
  it).
- Mark how you know: verified (with the command) or assumed, said out loud.

**When you write it down:**
- Write ONLY what you verified; an unverified claim never enters a doc, in any tense or hedge.
- An infrastructure fact carries the command that establishes it, as a citation for a human, never as a test, script,
  recipe or CI step (`documentation-currency.md`).
- Prefer the narrow verified statement over the broad plausible one.

**Silence is not confirmation.** A developer not objecting is not verification, and an earlier unchallenged statement of
yours is not support for a later one.

**When the developer questions a claim:** re-derive it from the system with a command, report the result plainly
(including when it contradicts either of you), re-check the adjacent claims from the same source, and file an issue for
any doc-versus-system discrepancy (`youtrack-workflow.md` section 3).

**Why:** stale data reported as current wastes the session, and a stale write destroys work. In one incident a deploy
failed on a firewall rule targeting a network tag no VM carried, and three architectural claims made from the repo's own
doc and memory were each wrong and each took one command to check, until the developer pushed back twice.
