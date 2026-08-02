#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "--host" ]; then
  echo '{}'
  exit 0
fi

TF_DIR="$(cd "$(dirname "$0")/../../terraform" && pwd)"

if ! OUTPUTS="$(terraform -chdir="$TF_DIR" output -json 2>&1)"; then
  {
    echo "Cannot read Terraform outputs:"
    echo "$OUTPUTS"
    echo
    echo "Load the secrets first: eval \"\$(./scripts/secrets.sh)\""
    echo "and make sure the infrastructure exists: make apply"
  } >&2
  exit 1
fi

printf '%s' "$OUTPUTS" | python3 -c '
import json
import sys

raw = sys.stdin.read().strip()
outputs = json.loads(raw) if raw else {}


def value(key, default):
    return outputs.get(key, {}).get("value", default)


hostvars = {
    f"web{index}": {"ansible_host": address}
    for index, address in enumerate(value("web_public_ips", []), start=1)
}

print(json.dumps({
    "webservers": {
        "hosts": sorted(hostvars),
        "vars": {"db_host": value("postgresql_host", "")},
    },
    "_meta": {"hostvars": hostvars},
}, indent=2))
'
