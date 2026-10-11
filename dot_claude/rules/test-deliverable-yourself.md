# Test the Deliverable Yourself (MANDATORY, every change)

The agent tests what it builds, inside its own environment, every time. A script, tool, or program is run by the agent
before the work is called done. Testing is never handed to a human.

## 1. Always run the deliverable in the sandbox

When the deliverable is a script, CLI, migration, restore, backup, or any program, run it for real within the confines
of the agent's environment: a local or throwaway database, a temp directory, a container, generated fixture data. Build
the fixture yourself if none exists (for example, create a small database, run the backup script into a temp directory,
then run the restore script against an empty database and compare). Report what was run and what happened, including
failures, per `error-visibility.md`.

If something truly cannot be run in the environment (it needs production credentials or an external system the agent
cannot reach), say so plainly in the response with the exact reason, and test every part that can be run. Do not skip
the run because it is effortful.

## 2. Never put testing on a human

An acceptance criterion, a "Before this PR is merged" item, a test plan, or a PR checklist MUST NOT ask a human to
run, restore, or exercise what the PR produces. Example of what is forbidden: "Restore the newest backup set into an
empty non-production Postgres" as a human step before merging a restore-script PR. The agent does that run itself and
records the result in the PR body.

`## Before this PR is merged` is ONLY for human actions the agent cannot perform from its environment: IAM grants,
secrets, queues, firewall rules, credential rotation.

## 3. No redundant checks

Testing the deliverable once, properly, is required. Repeating a passing check, adding verification passes the repo does
not require, or inventing extra sweeps is not. Run the repo's required pre-commit check once and the deliverable's own
run once per change; re-run only after the code changes.

**Why:** a restore-script PR was filed with a human-run database restore as a merge gate. The agent can build the
fixture and run the script itself, so the human spent hours doing the agent's testing.
