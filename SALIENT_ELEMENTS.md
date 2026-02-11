# Salient Repository Elements

These are the critical files and directories that constitute the "Ubukubu" Lab and Drill Engine. Everything else in the root directory effectively constitutes "scratchpad" material and can be archived or deleted.

## Infrastructure (The Lab)

- `Vagrantfile`: Defines the virtual machines (Control Plane + Worker).
- `scripts/`: Contains the provision scripts (`control-plane.sh`, `node.sh`, `manage_k8s_config.py`).
- `.github/`: Contains Copilot instructions and project documentation.
- `.gitignore`: Git ignore rules.

## Drill Engine (The Practice)

- `drill.py`: The CLI tool for running and verifying drills.
- `drills/`: The library of drill scenarios (Source of Truth).
- `declarative_imperatives/`: Reference YAML manifests used during study.
- `MANIFEST--ROBOT_EYES_ONLY.md`: Automated registry of active drills/curriculum mapping.
- `pyproject.toml` & `uv.lock`: Python dependencies for the drill engine (managed by `uv`).

## Curriculum & Context

- `CKA_exam_cirriculum_v1.34.md`: Official curriculum reference.
- `killer-sh-questions.md`: Hard-mode question references.
