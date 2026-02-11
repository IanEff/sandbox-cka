---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["“Write output to file” tasks: don’t lose points on formatting"]
---

# Tactic - “Write output to file” tasks: don’t lose points on formatting

If asked to write *exactly* something to `/path/to/file`:

- Prefer `-o jsonpath=...` or `-o custom-columns=... --no-headers`
- Always redirect with `>` (not `>>`) unless explicitly told to append
- Confirm quickly:

  ```bash
  cat /path/to/file
  ```

---

---
**Topics:** [[Topic - Tooling]]
