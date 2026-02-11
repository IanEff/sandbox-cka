---
tags: ["type/guide", "source/gemini", "status/seed"]
aliases: ["The "First 30 Seconds" Setup"]
---

# Guide - The "First 30 Seconds" Setup

*Do this immediately upon starting your terminal session. It saves thousands of keystrokes.*

1. **The "Do" Variable:**
    Instead of typing the dry-run flag every time, export it as a variable.

    ```bash
    export do="--dry-run=client -o yaml"
    # Usage: k run nginx --image=nginx $do
    ```

2. **The Namespace Switcher:**
    You will constantly need to switch namespaces.

    ```bash
    alias kn='kubectl config set-context --current --namespace '
    # Usage: kn mercury (Now you are in namespace 'mercury')
    ```

3. **The Vim Setup:**
    Make YAML readable.

    ```bash
    echo 'set expandtab tabstop=2 shiftwidth=2 syntax on' >> ~/.vimrc
    er... mebbe..
    echo 'syntax on' >> ~/.vimrc
    ```

  1 set expandtab
  2 set tabstop=2
  3 set shiftwidth=2
  4 set autoindent
  5 set smartindent
  6 set bg=dark
  7 syntax on
  8 set number

1. **TEST THIS OUT** **The bash oshit setup**

    This *may* lick the terminal wrap thing for long commands:

    ```bash
    bind 'set horizontal-scroll-mode off'
    ```

---

---
**Topics:** [[Topic - Networking]], [[Topic - Security]], [[Topic - Tooling]]
