
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform/environments/dev"

echo "WARNING: This will destroy CloudCart DEV infrastructure."
echo "This may permanently delete database data."
echo

read -r -p "Type DESTROY to continue: " CONFIRM

if [[ "$CONFIRM" != "DESTROY" ]]; then
  echo "Destruction cancelled."
  exit 1
fi

terraform -chdir="$TF_DIR" init -input=false

terraform -chdir="$TF_DIR" plan \
  -destroy \
  -var="enable_ecs_service=true" \
  -out=cloudcart-destroy.tfplan

echo
read -r -p "Review the plan. Type APPLY to destroy: " APPROVE

if [[ "$APPROVE" != "APPLY" ]]; then
  echo "Destruction cancelled."
  exit 1
fi

terraform -chdir="$TF_DIR" apply cloudcart-destroy.tfplan

echo "CloudCart DEV infrastructure destruction completed."
