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

VAULT_KEYS = (
    "yc_service_account_key",
    "yc_cloud_id",
    "yc_folder_id",
    "pg_password",
    "datadog_api_key",
    "datadog_app_key",
    "aws_access_key_id",
    "aws_secret_access_key",
    "upmon_ping_url",
)

ENV_NAMES = {
    "aws_access_key_id": "AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "AWS_SECRET_ACCESS_KEY",
}

REQUIRED = tuple(ENV_NAMES)

data = yaml.safe_load(sys.stdin) or {}

problems = []
for key in data:
    if key not in VAULT_KEYS:
        problems.append(f"{key}: unknown key, add it to VAULT_KEYS in scripts/secrets.sh")
for key in VAULT_KEYS:
    if key not in data:
        problems.append(f"{key}: missing from the vault")
for key in REQUIRED:
    if not data.get(key):
        problems.append(f"{key}: empty, the S3 backend cannot authenticate without it")

if problems:
    print("Vault keys do not match scripts/secrets.sh, nothing exported:", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    sys.exit(1)

exports = []
for key, env_name in ENV_NAMES.items():
    value = data[key]
    value = "" if value is None else str(value)
    exports.append(f"export {env_name}={shlex.quote(value)}")

print("\n".join(exports))
'
