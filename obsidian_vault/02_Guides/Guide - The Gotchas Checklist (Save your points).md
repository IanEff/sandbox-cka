---
tags: ["type/guide", "source/gemini", "status/seed"]
aliases: ["The "Gotchas" Checklist (Save your points)"]
---

# Guide - The "Gotchas" Checklist (Save your points)

*Before hitting "Next Question", glance at this:*

1. **Context Check:** Did I run this on the right cluster? (`k config use-context ...`)
2. **Namespace Check:** Did I create the resource in `default` when it asked for `saturn`?
3. **SSH Check:** Am I still logged into a worker node? (Type `exit` or you will fail the next questions).
4. **Privilege Check:** If a command says "Permission Denied" on a node, `sudo -i`.

---
**Topics:** [[Topic - Architecture]], [[Topic - Tooling]], [[Topic - Troubleshooting]]
