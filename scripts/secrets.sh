#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VAULT_FILE="${VAULT_FILE:-$ROOT/ansible/vault.yml}"
VAULT_PASS_FILE="${VAULT_PASS_FILE:-$ROOT/ansible/.vault_pass}"

if [ ! -f "$VAULT_FILE" ]; then
  echo "Vault file not found: $VAULT_FILE" >&2
  echo "Create it with 'make vault-init'." >&2
  exit 1
fi

if [ ! -f "$VAULT_PASS_FILE" ]; then
  echo "Vault password file not found: $VAULT_PASS_FILE" >&2
  echo "Write the vault password into it — Terraform reads the vault through a" >&2
  echo "provider, which has no way to ask for the password interactively." >&2
  exit 1
fi

ansible-vault view "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE" | python3 -c '
import sys, yaml, shlex

EXPORTED = (
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "TF_VAR_pg_password",
    "TF_VAR_datadog_api_key",
    "UPMON_PING_URL",
)

REQUIRED = ("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY")

data = yaml.safe_load(sys.stdin) or {}

missing = [key for key in REQUIRED if not data.get(key)]
if missing:
    sys.exit("Vault is missing the S3 backend credentials: " + ", ".join(missing))

for key in EXPORTED:
    if key in data:
        print(f"export {key}={shlex.quote(str(data[key]))}")
'
