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

ENV_NAMES = {
    "yc_service_account_key": "TF_VAR_yc_service_account_key",
    "yc_cloud_id": "TF_VAR_yc_cloud_id",
    "yc_folder_id": "TF_VAR_yc_folder_id",
    "pg_password": "TF_VAR_pg_password",
    "datadog_api_key": "TF_VAR_datadog_api_key",
    "datadog_app_key": "TF_VAR_datadog_app_key",
    "aws_access_key_id": "AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "AWS_SECRET_ACCESS_KEY",
    "upmon_ping_url": "UPMON_PING_URL",
}
LEGACY_NAMES = {env_name: key for key, env_name in ENV_NAMES.items()}

data = yaml.safe_load(sys.stdin) or {}

problems = []
for key in data:
    if key in ENV_NAMES:
        continue
    if key in LEGACY_NAMES:
        problems.append(f"{key}: old name, rename it to {LEGACY_NAMES[key]}")
    else:
        problems.append(f"{key}: unknown key, add it to ENV_NAMES in scripts/secrets.sh")
for key in ENV_NAMES:
    if key not in data:
        problems.append(f"{key}: missing from the vault")

if problems:
    print("Vault keys do not match scripts/secrets.sh, nothing exported:", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    sys.exit(1)

exports = []
for key, env_name in ENV_NAMES.items():
    value = data[key]
    value = "" if value is None else str(value)
    if not value:
        print(f"{key} is empty, {env_name} not exported", file=sys.stderr)
        continue
    exports.append(f"export {env_name}={shlex.quote(value)}")

print("\n".join(exports))
'
