#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VAULT_FILE="${VAULT_FILE:-$ROOT/ansible/vault.yml}"
VAULT_PASS_FILE="${VAULT_PASS_FILE:-$ROOT/ansible/.vault_pass}"

if [ ! -f "$VAULT_FILE" ]; then
  echo "Vault file not found: $VAULT_FILE" >&2
  exit 1
fi

if [ -f "$VAULT_PASS_FILE" ]; then
  set -- --vault-password-file "$VAULT_PASS_FILE"
else
  set --
fi

ansible-vault view "$VAULT_FILE" "$@" | python3 -c '
import sys, yaml, shlex

data = yaml.safe_load(sys.stdin) or {}
for key, value in data.items():
    print(f"export {key}={shlex.quote(str(value))}")
'
