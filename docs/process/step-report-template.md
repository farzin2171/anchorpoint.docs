# Step report template

After every step, stop and send this report. Do not start the next step until the owner replies "next"
(or names the task to run).

```text
Step:        <Task id and title>
Repository:  <repository folder>
Commit:      <hash and message>, or "not committed yet" with the proposed message

What changed
  - <bullet per meaningful change>

How to verify
  <the exact commands from the step document and their result when you ran them>

Docs added or updated
  - <step document, step index, changelog, and any other document>

Source mapping
  - <one line: what came from where, or "no source counterpart">

Decisions / ADRs
  - <ADR ids or "none">

Known limitations
  - <what was left for a later task>

Now unblocked
  - <task ids that can start>
```

Rules:

- Report what actually ran. If a command was not run, say so; do not report it as passing.
- If a check failed, say it failed and show the relevant output.
- One report per step; one step is one commit.
