#!/usr/bin/env python3
"""
Manage Kubernetes Configuration for Vagrant Sandbox.
Requires Python 3.6+ (Using 3.14 features where compatible).
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import List, Dict, Optional

# Configuration
CONTROL_PLANE_IP = "192.168.56.10"
WORKER_IP_BASE = 20
PREP_CONTROL_PLANE_IP_BASE = 40

KUBE_CONFIG_PATH = Path.home() / ".kube" / "config"
SSH_CONFIG_PATH = Path.home() / ".ssh" / "config"

# Context settings for kubeconfig
NEW_CONTEXT_NAME = "ubukubu"
NEW_USER_NAME = f"{NEW_CONTEXT_NAME}-admin"
NEW_CLUSTER_NAME = f"{NEW_CONTEXT_NAME}-cluster"


def get_project_root() -> Path:
    """Finds the project root containing the Vagrantfile."""
    cwd = Path.cwd()
    if (cwd / "Vagrantfile").exists():
        return cwd
    if (cwd.parent / "Vagrantfile").exists():
        return cwd.parent
    return cwd # Fallback


def get_vm_ip(name: str) -> Optional[str]:
    """Calculates VM IP based on naming convention matches Vagrantfile."""
    if name == "ubukubu-control":
        return CONTROL_PLANE_IP
    
    # Handle ubukubu-control-N (N >= 2)
    # Vagrantfile logic: PREP_CONTROL_PLANE_IP_BASE + i (where index = i + 1)
    # So i = index - 1.
    match_cp = re.match(r"ubukubu-control-(\d+)", name)
    if match_cp:
        n = int(match_cp.group(1))
        return f"192.168.56.{PREP_CONTROL_PLANE_IP_BASE + (n - 1)}"

    # Handle ubukubu-node-N
    # Vagrantfile logic: WORKER_IP_BASE + node_index
    match_node = re.match(r"ubukubu-node-(\d+)", name)
    if match_node:
        n = int(match_node.group(1))
        return f"192.168.56.{WORKER_IP_BASE + n}"
            
    return None


def scan_vms() -> List[Dict[str, str]]:
    """Scans .vagrant directory for active VMs and their keys."""
    root = get_project_root()
    machines_dir = root / ".vagrant" / "machines"
    
    if not machines_dir.exists():
        print("No .vagrant/machines directory found. Have you run 'vagrant up'?")
        return []
    
    vms = []
    for vm_dir in machines_dir.iterdir():
        if vm_dir.is_dir():
            name = vm_dir.name
            # We only care about our project's VMs
            if not name.startswith("ubukubu-"):
                continue

            key_path = vm_dir / "virtualbox" / "private_key"
            if key_path.exists():
                ip = get_vm_ip(name)
                if ip:
                    vms.append({
                        "name": name,
                        "key_path": str(key_path),
                        "ip": ip
                    })
                else:
                    print(f"Warning: Could not determine IP for {name}")
    
    return sorted(vms, key=lambda x: x["name"])


def backup_file(path: Path):
    """Creates a timestamped backup of a file."""
    if path.exists():
        timestamp = int(time.time())
        backup_path = path.with_suffix(f".bak.{timestamp}")
        shutil.copy2(path, backup_path)
        print(f"Backed up {path.name} to {backup_path.name}")


def update_ssh_config(vms: List[Dict[str, str]]):
    """Adds or updates SSH config entries for all found VMs."""
    if not vms:
        print("No VMs found to configure.")
        return

    print(f"Updating SSH config for {len(vms)} nodes...")

    if not SSH_CONFIG_PATH.exists():
        SSH_CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
        SSH_CONFIG_PATH.touch(mode=0o600)

    backup_file(SSH_CONFIG_PATH)
    content = SSH_CONFIG_PATH.read_text(encoding="utf-8")
    
    # Simple parsing: Remove existing ubukubu-* blocks to avoid duplication
    lines = content.splitlines()
    new_lines = []
    skip = False
    
    for line in lines:
        if line.strip().startswith("Host ubukubu-"):
            skip = True
        
        if skip:
            if line.strip() == "":
                skip = False
                continue # Skip the empty line after the block
            elif line.strip().startswith("Host ") and not line.strip().startswith("Host ubukubu-"):
                skip = False
                # Fall through to keep this line
            else:
                continue # Skip content of the block

        new_lines.append(line)

    # Generate new blocks
    new_blocks = []
    for vm in vms:
        block = f"""
Host {vm['name']}
    HostName {vm['ip']}
    User vagrant
    IdentityFile {vm['key_path']}
    IdentitiesOnly yes
    PreferredAuthentications publickey
    PubkeyAuthentication yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
"""
        new_blocks.append(block)

    # Append new blocks
    output = "\n".join(new_lines).rstrip() + "\n" + "".join(new_blocks)
    
    with open(SSH_CONFIG_PATH, "w", encoding="utf-8") as f:
        f.write(output)

    print("SSH config updated.")


def remove_ssh_config():
    """Removes all ubukubu-* entries from SSH config."""
    if not SSH_CONFIG_PATH.exists():
        print("SSH config not found.")
        return

    print("Removing all ubukubu-* entries from SSH config...")
    content = SSH_CONFIG_PATH.read_text(encoding="utf-8")

    lines = content.splitlines()
    new_lines = []
    skip = False

    for line in lines:
        if line.strip().startswith("Host ubukubu-"):
            skip = True

        if skip:
            if line.strip() == "":
                skip = False
                continue
            elif line.strip().startswith("Host ") and not line.strip().startswith("Host ubukubu-"):
                skip = False
            else:
                continue

        new_lines.append(line)

    output = "\n".join(new_lines)
    
    if len(lines) != len(new_lines):
        backup_file(SSH_CONFIG_PATH)
        SSH_CONFIG_PATH.write_text(output + "\n", encoding="utf-8")
        print("Removed SSH config entries.")
    else:
        print("No ubukubu entries found.")


def add_kube_config(vms: List[Dict[str, str]]):
    """Downloads and merges kubeconfig from the control plane."""
    # Find control plane in the list
    cp_vm = next((vm for vm in vms if vm["name"] == "ubukubu-control"), None)
    
    if not cp_vm:
        print("Error: ubukubu-control not found in active VMs. Cannot update kubeconfig.")
        return

    print(f"Fetching admin.conf from {cp_vm['name']}...")
    temp_conf = Path("admin.conf.tmp")

    # scp
    cmd = [
        "scp",
        "-o",
        "StrictHostKeyChecking=no",
        "-o",
        "UserKnownHostsFile=/dev/null",
        "-o",
        "IdentitiesOnly=yes",
        "-i",
        cp_vm["key_path"],
        f"vagrant@{cp_vm['ip']}:/home/vagrant/.kube/config",
        str(temp_conf),
    ]

    try:
        subprocess.run(cmd, check=True, capture_output=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to fetch admin.conf: {e.stderr.decode()}")
        # Check if file exists, maybe the scp failed but we can't do anything
        return

    print("Refining kubeconfig context names...")
    content = temp_conf.read_text(encoding="utf-8")
    # Replace default names to avoid collisions
    content = content.replace("kubernetes-admin", NEW_USER_NAME)
    content = content.replace("cluster: kubernetes", f"cluster: {NEW_CLUSTER_NAME}")
    content = content.replace(
        "name: kubernetes", f"name: {NEW_CLUSTER_NAME}"
    )
    
    # Fix context name
    content = content.replace(f"name: {NEW_USER_NAME}@kubernetes", f"name: {NEW_CONTEXT_NAME}")
    content = content.replace(f"context: {NEW_USER_NAME}@kubernetes", f"context: {NEW_CONTEXT_NAME}")

    temp_conf.write_text(content, encoding="utf-8")

    print("Merging kubeconfig...")
    merged_conf = Path("kubeconfig.merged")

    # KUBECONFIG=... kubectl config view --flatten
    env = os.environ.copy()
    if KUBE_CONFIG_PATH.exists():
        env["KUBECONFIG"] = f"{temp_conf}:{KUBE_CONFIG_PATH}"
    else:
        env["KUBECONFIG"] = str(temp_conf)

    try:
        with open(merged_conf, "w") as f:
            subprocess.run(
                ["kubectl", "config", "view", "--flatten"], env=env, stdout=f, check=True
            )
    except subprocess.CalledProcessError:
        print("Failed to merge kubeconfig.")
        temp_conf.unlink(missing_ok=True)
        return

    # Move into place
    backup_file(KUBE_CONFIG_PATH)
    KUBE_CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(merged_conf, KUBE_CONFIG_PATH)
    KUBE_CONFIG_PATH.chmod(0o600)

    temp_conf.unlink(missing_ok=True)
    print(f"Kubeconfig updated. Context '{NEW_CONTEXT_NAME}' added.")


def remove_kube_config():
    """Removes the context, user, and cluster from kubeconfig."""
    print("Removing K8s configuration...")

    cmds = [
        ["kubectl", "config", "delete-context", NEW_CONTEXT_NAME],
        ["kubectl", "config", "delete-cluster", NEW_CLUSTER_NAME],
        ["kubectl", "config", "delete-user", NEW_USER_NAME],
    ]

    for cmd in cmds:
        try:
            subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

    print("Kubeconfig cleaned up (best effort).")

def main():
    parser = argparse.ArgumentParser(description="Manage Kubernetes Config for Sandboxes")
    parser.add_argument("action", choices=["add", "remove"], help="Action to perform")
    args = parser.parse_args()

    if args.action == "add":
        vms = scan_vms()
        update_ssh_config(vms)
        add_kube_config(vms)
    elif args.action == "remove":
        remove_ssh_config()
        remove_kube_config()


if __name__ == "__main__":
    main()