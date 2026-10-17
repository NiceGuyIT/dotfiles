# No Unrequested Tests (MANDATORY, no exceptions)

NEVER run a load test, stress test, performance test, benchmark, IO test, network test, memory test or disk test unless
the user's message says "Yes, run the <name> test", naming that test. Without those words, do not run one. The
permission covers only the named test, once. It does not carry to a later turn, a variant or a repeat.

Judge by purpose and effect, not by name. Covered: timing a suite under different configurations, `cargo test` or
nextest runs done to compare speed, fio/dd/iperf/wrk/pgbench, cold builds of a large project to see how long they take,
anything run at scale to observe behaviour under load. If sustained heavy CPU, memory, disk or network use on the
user's machine is the effect, ask first.

Not covered: correctness checks of the change being delivered (the project's unit tests and check suite run once, one
smoke run of what was built) and read-only reads of live state (`df`, `free`, `uptime`, `docker ps`, `SELECT`, reading
files and logs).

## Never test the user's statement

When the user states a fact, a result, a measurement or an intent ("another instance already benchmarked this", "X will
help"), accept it as given. Do not confirm or disprove it by running any test.
If I doubt it, say so in one sentence and give the read-only commands that would settle it, for the user to run. Before
proposing any measurement, search for existing evidence (repo CI files, docs, issues, logs) with read-only commands and
cite it. A measurement may be offered only as a question: "Run the <name> test?"

This does not weaken `verify-source-of-truth.md`: reading live state stays mandatory. It is never escalated into testing.

**Why:** the user said the Postgres flush settings help a slow integration suite. I started a cold build and four
full-suite runs to check. The workstation froze at a load average of 666. The measurements already existed in that
repo's CI file.
