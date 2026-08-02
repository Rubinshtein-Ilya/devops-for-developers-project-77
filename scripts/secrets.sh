#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VAULT_FILE="${VAULT_FILE:-$ROOT/ansible/vault.yml}"

if [ ! -f "$VAULT_FILE" ]; then
  echo "Vault file not found: $VAULT_FILE" >&2
  exit 1
fi

ansible-vault view "$VAULT_FILE" | python3 -c '
import sys, yaml, shlex

data = yaml.safe_load(sys.stdin) or {}
for key, value in data.items():
    print(f"export {key}={shlex.quote(str(value))}")
'
