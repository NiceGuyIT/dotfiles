# Large Writes: Check the Filesystem First (MANDATORY)

Before writing anything large or unbounded to a path, run `df --human-readable <path>` and
`findmnt --noheadings --output FSTYPE,SIZE,AVAIL --target <path>`. Large means 1 GB or more, or unknown size. Build
target directories, clones of big repos, archives, container volumes, database data directories and caches all count.

- NEVER write it to a RAM-backed filesystem (tmpfs, ramfs, `/dev/shm`, `/run`). That consumes memory and swap, not disk.
- Require free space of at least twice the expected size, on a disk-backed filesystem such as one under `/home`.
- The session scratchpad is under `/tmp`, which is tmpfs on this workstation. It is for small files only.
- State the path and filesystem type when creating a large directory. List it and delete it when done, without a force flag.

**Why:** a 32 GB build directory in the RAM-backed scratchpad filled memory and swap, and the workstation froze.
