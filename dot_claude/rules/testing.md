# Testing (MANDATORY, every change)

## 1. Test the deliverable yourself

The agent runs what it builds, in its own environment, before calling work done. A script, CLI, migration, restore,
backup or program is run for real in a sandbox: a throwaway database, temp directory, container, or fixture data you
generate (for a restore script: create a small database, back it up into a temp directory, restore into an empty
database, compare). Report what was run and what happened, failures included (`error-visibility.md`). If something
cannot be run (production credentials, an unreachable external system), say so with the exact reason and test every
part that can be run.

Never put testing on a human. An acceptance criterion, "Before this PR is merged" item, test plan or PR checklist MUST
NOT ask a human to run, restore, or exercise what the PR produces; the agent does it and records the result in the PR
body. `## Before this PR is merged` is ONLY for human actions the agent cannot perform (IAM grants, secrets, queues,
firewall rules, credential rotation).

No redundant checks: run the repo's required pre-commit check once and the deliverable's own run once per change; re-run
only after the code changes.

## 2. No unrequested tests

NEVER run a load, stress, performance, benchmark, IO, network, memory or disk test unless the user's message says "Yes,
run the <name> test" naming it. The permission covers only that test, once; it does not carry to a later turn, variant
or repeat. Judge by purpose and effect: covered are timing a suite under different configurations, `cargo test` or
nextest runs to compare speed, fio/dd/iperf/wrk/pgbench, cold builds to see how long they take, anything run at scale to
observe behaviour under load. If sustained heavy CPU, memory, disk or network use on the user's machine is the effect,
ask first.

Not covered: correctness checks of the delivered change (the project's unit tests and check suite once, one smoke run
of what was built) and read-only reads of live state (`df`, `free`, `uptime`, `docker ps`, `SELECT`, files, logs).

**Never test the user's statement.** When the user states a fact, result, measurement or intent, accept it. If in
doubt, say so in one sentence and give read-only commands for the user to run. Before proposing any measurement, search
for existing evidence (CI files, docs, issues, logs) read-only and cite it. A measurement may be offered only as a
question: "Run the <name> test?" This does not weaken `verify-source-of-truth.md`; reading live state is never escalated
into testing.

**Never gate acceptance on infrastructure verification.** An AC, PR checklist item, "Before this PR is merged" item or
follow-up issue NEVER requires proving that an out-of-PR infrastructure or configuration change took effect (a secret
exists, a grant applied, a runner label is registered, a firewall rule is open, a service is reachable, a workflow
dispatched). Assume it was made correctly; a human will open issues if not. Such steps also need an open PR or merge the
runner cannot do, and create cycles (`youtrack-workflow.md` section 9).

**Why:** a restore-script PR was gated on a human-run restore the agent could have done itself. A cold build plus four
full-suite runs, started to check a user's claim, froze the workstation at load average 666 when the measurements
already existed in the repo's CI file. A criterion to dispatch a workflow from the PR branch created a dependency cycle.
