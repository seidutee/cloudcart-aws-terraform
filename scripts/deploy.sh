
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform/environments/dev"

echo "=== CloudCart Infrastructure Deployment ==="

terraform -chdir="$TF_DIR" init -input=false
terraform -chdir="$TF_DIR" validate

terraform -chdir="$TF_DIR" plan \
  -var="enable_ecs_service=true" \
  -out=cloudcart.tfplan

echo
read -r -p "Review the plan. Type DEPLOY to continue: " CONFIRM

if [[ "$CONFIRM" != "DEPLOY" ]]; then
  echo "Deployment cancelled."
  exit 1
fi
terraform -chdir="$TF_DIR" apply cloudcart.tfplan

echo "=== Deployment Complete ==="

terraform -chdir="$TF_DIR" output

echo "CloudCart infrastructure is deployed."
