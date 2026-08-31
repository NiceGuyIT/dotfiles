# Documentation Provenance (MANDATORY, every proposal and every doc write)

Documentation is a CLAIM about the system. It is never evidence for one. The system is the evidence: the running
infrastructure, the live config, the deployed resource, the tool's own source. Before proposing a change, asserting an
architectural fact, or writing a sentence into any doc, establish the fact from the system. A doc that agrees with you
is not corroboration; it may be a sentence you or a predecessor wrote from the same guess.

This rule exists because AI-authored documentation compounds. The loop:

1. The assistant proposes something plausible that it did not verify.
2. The developer does not hold the whole architecture either, it sounds right, and it stands.
3. The assistant writes it into a doc as settled.
4. The next session reads that doc, treats it as established, and builds on it with MORE confidence, not less.

No step in that loop is dishonest and none of them warns anybody. The output is a repo whose documentation is
internally consistent, confidently worded, and wrong.

**Scope.** This governs claims about how the system IS: deployment topology, network paths, what is running where,
what a third-party tool does. It does not govern proposals about how the system SHOULD be, opinions offered as
opinions, or reading code, where the code in the working tree IS the system.

## Before you propose

- **Verify the claim the proposal rests on, against the system, this turn.** Not the doc that describes the system.
  If the proposal depends on how something is deployed, query the deployment. If it depends on what a third-party
  tool does, fetch that tool's docs or source.
- **Check whether the thing you are about to call necessary, impossible, or new is already running.** Before arguing
  a design is required, look for an existing component solving the same problem another way. One list command
  usually settles it, and it is the check most often skipped because it feels tangential.
- **Mark how you know.** Every claim about the system is either verified, with the command, or assumed, said out
  loud. The reader cannot tell them apart unless you mark them.

## When you write it down

- Write ONLY what you verified. An unverified claim does not enter a doc, in any tense or hedge.
- An infrastructure fact in a doc carries the command that establishes it, so the next reader re-runs it instead of
  trusting it. This is a citation for a human, NOT a test: it adds no script, recipe, or CI step (see
  `documentation-currency.md`).
- Prefer the narrow verified statement over the broad plausible one.

## Silence is not confirmation

A developer not objecting is NOT verification. They may not know either, which is the entire reason the loop exists.
Never record "nobody pushed back" as agreement, and never cite an earlier unchallenged statement of your own as
support for a later one.

## When the developer questions it

A challenge invalidates the document as evidence for that claim. Do not defend the claim from the doc that produced
it, and do not simply concede either, because caving to pressure is as unhelpful as digging in.

1. Re-derive the fact from the system, this turn, with a command.
2. Report the result plainly, including when it contradicts you AND when it contradicts them.
3. Re-check the claims ADJACENT to the challenged one that rest on the same document. A challenge that lands means
   the source is unreliable, not that one sentence was unlucky. Scoping the recheck to the exact sentence questioned
   is how the same failure survives its own correction.
4. If the doc and the system disagree, that is a discrepancy, and it gets an issue (see the no-orphan-notes rule in
   `youtrack-workflow.md`).

**Why:** a production data-pipeline deploy once failed because a firewall rule targeted a network tag no VM carried.
The repo's own migration doc had predicted that exact defect in writing, and the cutover shipped anyway. While
diagnosing it, the assistant then made three architectural claims straight from that same doc and from memory: that
`pg_hba.conf` on the prod VM was hand-edited (it runs in Docker from the stock image, which generates
`host all all all`), that a dedicated egress subnet was necessary (both services had been on Direct VPC egress from
the existing subnet in both environments all along), and that sharing the existing subnet would widen access (it was
already shared). Each took one command to check, against infrastructure the assistant already had authenticated access
to. None was checked until the developer pushed back twice. Every wrong claim came AFTER a correct diagnosis: being
right about the first thing produced unearned confidence about everything next to it.
