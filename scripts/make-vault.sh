#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY_FILE="${1:-$HOME/Downloads/authorized_key.json}"
VAULT_FILE="$ROOT/ansible/vault.yml"
VAULT_PASS_FILE="$ROOT/ansible/.vault_pass"

if [ ! -f "$KEY_FILE" ]; then
  echo "Authorized key file not found: $KEY_FILE" >&2
  exit 1
fi

if [ -f "$VAULT_FILE" ]; then
  echo "$VAULT_FILE already exists — remove it or use 'make vault-edit'." >&2
  exit 1
fi

read -r -p "cloud_id: " CLOUD_ID
read -r -p "folder_id: " FOLDER_ID
read -r -p "static access key id: " ACCESS_KEY_ID
read -r -s -p "static secret access key: " SECRET_ACCESS_KEY
echo
read -r -p "Datadog API key (Enter to skip): " DATADOG_API_KEY
read -r -p "Datadog application key (Enter to skip): " DATADOG_APP_KEY
read -r -p "Upmon ping URL (Enter to skip): " UPMON_PING_URL

umask 077

if [ ! -f "$VAULT_PASS_FILE" ]; then
  read -r -s -p "new vault password: " VAULT_PASS
  echo
  read -r -s -p "repeat vault password: " VAULT_PASS_AGAIN
  echo

  if [ -z "$VAULT_PASS" ]; then
    echo "The vault password cannot be empty." >&2
    exit 1
  fi

  if [ "$VAULT_PASS" != "$VAULT_PASS_AGAIN" ]; then
    echo "The passwords do not match." >&2
    exit 1
  fi

  printf '%s\n' "$VAULT_PASS" > "$VAULT_PASS_FILE"
  echo "Created $VAULT_PASS_FILE"
fi

PG_PASSWORD="$(openssl rand -base64 24 | tr -d '/+=')"

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

KEY_FILE="$KEY_FILE" \
CLOUD_ID="$CLOUD_ID" \
FOLDER_ID="$FOLDER_ID" \
PG_PASSWORD="$PG_PASSWORD" \
DATADOG_API_KEY="$DATADOG_API_KEY" \
DATADOG_APP_KEY="$DATADOG_APP_KEY" \
ACCESS_KEY_ID="$ACCESS_KEY_ID" \
SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY" \
UPMON_PING_URL="$UPMON_PING_URL" \
python3 - "$TMP_FILE" <<'PY'
import json, os, sys, yaml

with open(os.environ["KEY_FILE"]) as handle:
    service_account_key = json.dumps(json.load(handle))

secrets = {
    "TF_VAR_yc_service_account_key": service_account_key,
    "TF_VAR_yc_cloud_id": os.environ["CLOUD_ID"],
    "TF_VAR_yc_folder_id": os.environ["FOLDER_ID"],
    "TF_VAR_pg_password": os.environ["PG_PASSWORD"],
    "TF_VAR_datadog_api_key": os.environ["DATADOG_API_KEY"],
    "TF_VAR_datadog_app_key": os.environ["DATADOG_APP_KEY"],
    "AWS_ACCESS_KEY_ID": os.environ["ACCESS_KEY_ID"],
    "AWS_SECRET_ACCESS_KEY": os.environ["SECRET_ACCESS_KEY"],
    "UPMON_PING_URL": os.environ["UPMON_PING_URL"],
}

with open(sys.argv[1], "w") as handle:
    yaml.safe_dump(
        secrets,
        handle,
        default_flow_style=False,
        default_style='"',
        sort_keys=False,
        allow_unicode=True,
    )
PY

ansible-vault encrypt "$TMP_FILE" --output "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE"
echo "Created $VAULT_FILE"
