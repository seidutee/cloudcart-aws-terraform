
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform/environments/dev"

echo "=== CloudCart Terraform Plan ==="

terraform -chdir="$TF_DIR" init -input=false
terraform -chdir="$TF_DIR" fmt -check
terraform -chdir="$TF_DIR" validate

terraform -chdir="$TF_DIR" plan \
  -var="enable_ecs_service=true" \
  -out=cloudcart.tfplan

echo "Plan saved to terraform/environments/dev/cloudcart.tfplan"
