import os
import re
import shutil
from collections import defaultdict

BASE_DIR = "/Users/ian/projects/kubernetes/sandbox-kcna"
VAULT_DIR = os.path.join(BASE_DIR, "obsidian_vault")
CONCEPTS_DIR = os.path.join(VAULT_DIR, "01_Concepts")
GUIDES_DIR = os.path.join(VAULT_DIR, "02_Guides")
REFERENCE_DIR = os.path.join(VAULT_DIR, "03_Reference")
TOPICS_DIR = os.path.join(VAULT_DIR, "04_Topics")
INDEX_DIR = os.path.join(VAULT_DIR, "00_Index")

# Registry: Filename -> Data
NOTE_REGISTRY = []
# Topic Registry: Topic Name -> List of Note Titles
TOPIC_REGISTRY = defaultdict(list)

TOPIC_KEYWORDS = {
    "Workloads": [
        "pod",
        "deployment",
        "replicaset",
        "daemonset",
        "statefulset",
        "job",
        "cronjob",
        "workload",
        "controllers",
    ],
    "Networking": [
        "service",
        "ingress",
        "networkpolicy",
        "dns",
        "cni",
        "kube-proxy",
        "network",
        "port",
    ],
    "Storage": ["pvc", "pv", "storageclass", "volume", "csi", "storage", "claim"],
    "Security": [
        "rbac",
        "role",
        "binding",
        "serviceaccount",
        "user",
        "group",
        "securitycontext",
        "psa",
        "cert",
        "key",
    ],
    "Architecture": [
        "etcd",
        "scheduler",
        "controller-manager",
        "apiserver",
        "architecture",
        "kubelet",
        "plane",
        "node",
    ],
    "Tooling": ["helm", "kustomize", "kubectl", "jsonpath", "command"],
    "Troubleshooting": ["troubleshoot", "debug", "logging", "monitoring", "fix", "error", "fail"],
}


def ensure_dirs():
    if os.path.exists(VAULT_DIR):
        shutil.rmtree(VAULT_DIR)
    for d in [CONCEPTS_DIR, GUIDES_DIR, REFERENCE_DIR, TOPICS_DIR, INDEX_DIR]:
        os.makedirs(d, exist_ok=True)


def sanitize_filename(name):
    clean = re.sub(r'[\\/*?:"<>|]', "", name)
    return clean.strip()


def identify_topics(content, title):
    text_to_search = (title + " " + content).lower()
    found_topics = set()

    for topic, keywords in TOPIC_KEYWORDS.items():
        for kw in keywords:
            # Simple substring match is usually enough and faster/more rigorous than simple regex for keywords
            if kw in text_to_search:
                found_topics.add(topic)
                break  # Found one keyword for this topic, ample enough

    return sorted(list(found_topics))


def create_note(directory, title, content, type_tag, source_tag, aliases=None):
    filename = f"{sanitize_filename(title)}.md"
    filepath = os.path.join(directory, filename)

    # 1. Identify Topics
    topics = identify_topics(content, title)

    # 2. Register for MOC generation
    for topic in topics:
        TOPIC_REGISTRY[topic].append(title)

    # 3. Construct Frontmatter
    tags = [type_tag, source_tag, "status/seed"]

    alias_str = ""
    all_aliases = set()
    cleaned_title = title.replace("Concept - ", "").replace("Guide - ", "").replace("Tactic - ", "")
    all_aliases.add(cleaned_title)

    if aliases:
        for a in aliases:
            all_aliases.add(a)

    final_aliases = [a for a in all_aliases if len(a) > 2]  # Filter short noise
    if final_aliases:
        alias_list = [f'"{a}"' for a in final_aliases]
        alias_str = f"aliases: [{', '.join(alias_list)}]\n"

    tag_list = [f'"{t}"' for t in tags]

    # 4. Construct Footer (The "Mind Map" Links)
    topic_footer = ""
    if topics:
        topic_links = [f"[[Topic - {t}]]" for t in topics]
        topic_footer = f"\n\n---\n**Topics:** {', '.join(topic_links)}"

    frontmatter = f"""---
tags: [{", ".join(tag_list)}]
{alias_str}---

# {title}

"""

    with open(filepath, "w") as f:
        f.write(frontmatter + content.strip() + topic_footer + "\n")

    print(f"Created: {filepath}")

    # Add to registry
    NOTE_REGISTRY.append(
        {"filename": filename, "path": filepath, "title": title, "aliases": final_aliases}
    )


def create_topic_mocs():
    print("\n--- Generating Topic MOCs ---")
    for topic, titles in TOPIC_REGISTRY.items():
        filename = f"Topic - {topic}.md"
        filepath = os.path.join(TOPICS_DIR, filename)

        content = f"# Topic: {topic}\n\n"
        content += "## Related Notes\n"

        # Sort notes alphabetically
        for t in sorted(titles):
            # We assume filename = title + .md roughly, but better to link by title or precise filename if we had it mapping
            # In our system create_note ensures filename is sanitized title.
            # Obsidian fuzzy matching usually handles [[Title]] fine even if filename is Concept - Title
            # But let's be precise: we used "Concept - Title" as the note title passed to create_note.

            # Find the actual filename for this title to be 100% safe, essentially reversing
            target_file = next(
                (n["filename"].replace(".md", "") for n in NOTE_REGISTRY if n["title"] == t), t
            )
            content += f"- [[{target_file}]]\n"

        frontmatter = """---
tags: ["type/moc"]
---
"""
        with open(filepath, "w") as f:
            f.write(frontmatter + content)
        print(f"Generated MOC: {filename}")


def create_dashboard():
    filepath = os.path.join(INDEX_DIR, "Dashboard.md")
    content = """---
tags: ["type/dashboard"]
---

# 🧠 CKA Study Vault

## 🗺️ Maps of Content (Topics)
"""
    for topic in sorted(TOPIC_REGISTRY.keys()):
        content += f"- [[Topic - {topic}]]\n"

    content += "\n## 📚 Indices\n"
    content += "- [[CKA_MOC|Full Map of Content]]\n"

    with open(filepath, "w") as f:
        f.write(content)
    print("Created Dashboard")


def apply_cross_links():
    print("\n--- Starting Auto-Linking Pass ---")
    term_map = {}
    for note in NOTE_REGISTRY:
        # Link to Title
        term_map[note["title"]] = note["filename"].replace(".md", "")
        # Link aliases
        for alias in note["aliases"]:
            term_map[alias] = note["filename"].replace(".md", "")

    # Also map Topics! So if text says "Networking", it links to [[Topic - Networking]]
    for topic in TOPIC_REGISTRY.keys():
        term_map[topic] = f"Topic - {topic}"

    sorted_terms = sorted(term_map.keys(), key=len, reverse=True)

    for note in NOTE_REGISTRY:
        with open(note["path"], "r") as f:
            content = f.read()

        # Isolate body from frontmatter
        if content.startswith("---"):
            fm_end = content.find("---", 3)
            if fm_end != -1:
                frontmatter = content[: fm_end + 3]
                body = content[fm_end + 3 :]
            else:
                frontmatter = ""
                body = content
        else:
            frontmatter = ""
            body = content

        # Protection
        placeholders = {}

        def save_protected(match):
            key = f"__PROTECTED_{len(placeholders)}__"
            placeholders[key] = match.group(0)
            return key

        protected_pattern = r"(```[\s\S]*?```|`[^`\n]+`|\[\[.*?\]\]|\[.*?\]\(.*?\))"
        safe_body = re.sub(protected_pattern, save_protected, body)
        modified_body = safe_body

        for term in sorted_terms:
            target_link = term_map[term]

            # Self-link check
            current_note_name = note["filename"].replace(".md", "")
            if target_link == current_note_name:
                continue

            # Length check
            if len(term) < 4 and term.lower() not in ["pod", "pvc", "env", "cli", "api", "job"]:
                continue

            pattern = re.compile(
                r"(?<!\[\[)(?<!\|)\b" + re.escape(term) + r"\b(?!\]\])", re.IGNORECASE
            )

            if pattern.search(modified_body):

                def replace_link(match):
                    return f"[[{target_link}|{match.group(0)}]]"

                modified_body = pattern.sub(replace_link, modified_body, count=1)

        # Restore
        for key, val in placeholders.items():
            modified_body = modified_body.replace(key, val)

        if modified_body != body:
            with open(note["path"], "w") as f:
                f.write(frontmatter + modified_body)

    print("Auto-linking complete.")


def process_notes_md():
    filepath = os.path.join(BASE_DIR, "notes.md")
    with open(filepath, "r") as f:
        content = f.read()

    parts = re.split(r"(^## Chapter .*$)", content, flags=re.MULTILINE)

    if parts[0].strip():
        create_note(
            CONCEPTS_DIR,
            "Concept - Intro & Cheat Sheet",
            parts[0],
            "type/reference",
            "source/notes_md",
        )

    for i in range(1, len(parts), 2):
        header = parts[i].strip()
        body = parts[i + 1]

        match = re.search(r"## Chapter \d+ [-–—] (.*)", header)
        if match:
            raw_title = match.group(1).strip()
            title = f"Concept - {raw_title}"
            aliases = [raw_title, header.replace("## ", "")]
        else:
            title = f"Concept - {header.replace('## ', '')}"
            aliases = [header.replace("## ", "")]

        create_note(CONCEPTS_DIR, title, body, "type/concept", "source/notes_md", aliases)


def process_copilot_tips():
    filepath = os.path.join(
        BASE_DIR, "generated_supplimentaries/CKA Hot Tips & Tactics - Copilot.md"
    )
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            content = f.read()
        parts = re.split(r"(^## \d+\) .*$)", content, flags=re.MULTILINE)
        for i in range(1, len(parts), 2):
            header = parts[i].strip()
            body = parts[i + 1]
            match = re.search(r"## \d+\) (.*)", header)
            if match:
                raw_title = match.group(1).strip()
                title = f"Tactic - {raw_title}"
                create_note(GUIDES_DIR, title, body, "type/tactic", "source/copilot")


def process_gemini_guide():
    filepath = os.path.join(
        BASE_DIR, "generated_supplimentaries/CKA Tactical Survival Guide - Gemini.md"
    )
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            content = f.read()
        parts = re.split(r"(^## [IVX]+\. .*$)", content, flags=re.MULTILINE)
        for i in range(1, len(parts), 2):
            header = parts[i].strip()
            body = parts[i + 1]
            match = re.search(r"## [IVX]+\. (.*)", header)
            if match:
                raw_title = match.group(1).strip()
                title = f"Guide - {raw_title}"
                create_note(GUIDES_DIR, title, body, "type/guide", "source/gemini")


def process_single_files():
    # Helm
    helm_path = os.path.join(BASE_DIR, "notes-learning-helm.md")
    if os.path.exists(helm_path):
        with open(helm_path, "r") as f:
            create_note(
                CONCEPTS_DIR,
                "Concept - Helm Deep Dive",
                f.read(),
                "type/concept",
                "source/helm_notes",
            )

    # K8s Book
    book_path = os.path.join(BASE_DIR, "notes-kubernetes-book.md")
    if os.path.exists(book_path):
        with open(book_path, "r") as f:
            create_note(
                CONCEPTS_DIR,
                "Concept - Pod Patterns & Init Containers",
                f.read(),
                "type/concept",
                "source/k8s_book",
            )


def create_full_moc():
    moc_path = os.path.join(INDEX_DIR, "CKA_MOC.md")
    content = "# CKA Full Index\n\n"
    content += "## Concepts\n"
    for f in sorted(os.listdir(CONCEPTS_DIR)):
        if f.endswith(".md"):
            content += f"- [[{f.replace('.md', '')}]]\n"
    content += "\n## Guides & Tactics\n"
    for f in sorted(os.listdir(GUIDES_DIR)):
        if f.endswith(".md"):
            content += f"- [[{f.replace('.md', '')}]]\n"
    content += "\n## Reference\n"
    for f in sorted(os.listdir(REFERENCE_DIR)):
        if f.endswith(".md"):
            content += f"- [[{f.replace('.md', '')}]]\n"
    with open(moc_path, "w") as f:
        f.write(content)


def main():
    ensure_dirs()
    print("Processing notes...")
    process_notes_md()
    process_copilot_tips()
    process_gemini_guide()
    process_single_files()

    print("Generating Structure...")
    create_topic_mocs()
    create_full_moc()
    create_dashboard()

    apply_cross_links()
    print("Done!")


if __name__ == "__main__":
    main()
