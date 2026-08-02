#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY_FILE="${1:-$HOME/Downloads/authorized_key.json}"
VAULT_FILE="$ROOT/ansible/vault.yml"

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

SA_KEY="$(python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1]))))' "$KEY_FILE")"

case "$SA_KEY" in
  *"'"*)
    echo "Key contains a single quote, cannot embed safely." >&2
    exit 1
    ;;
esac

umask 077
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

cat > "$TMP_FILE" <<EOF
TF_VAR_yc_service_account_key: '$SA_KEY'
TF_VAR_yc_cloud_id: "$CLOUD_ID"
TF_VAR_yc_folder_id: "$FOLDER_ID"
AWS_ACCESS_KEY_ID: "$ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY: "$SECRET_ACCESS_KEY"
EOF

ansible-vault encrypt "$TMP_FILE" --output "$VAULT_FILE"
echo "Created $VAULT_FILE"
