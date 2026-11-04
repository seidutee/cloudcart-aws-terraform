# CloudCart — Implementation Guide

[← Back to project overview](../README.md)

## 1. Architecture and Networking

CloudCart uses a VPC (`10.0.0.0/16`) spanning two Availability Zones. Public subnets host the internet-facing ALB, private application subnets host ECS Fargate workloads, and private database subnets host Amazon RDS PostgreSQL.

| Subnet | CIDR | Role |
|---|---|---|
| Public A / B | `10.0.0.0/24`, `10.0.1.0/24` | ALB |
| Private App A / B | `10.0.2.0/24`, `10.0.3.0/24` | ECS |
| Private DB A / B | `10.0.4.0/24`, `10.0.5.0/24` | RDS subnet group |

The ALB accepts HTTP traffic and forwards requests to the Flask container. Security groups restrict ECS inbound traffic to the ALB and PostgreSQL inbound traffic to the ECS security group. Private endpoints support access to ECR, CloudWatch Logs, Secrets Manager, and S3 without relying on NAT gateways in the tested dev setup.

## 2. Terraform Modules

The `terraform/modules/` directory separates networking, security, ECR, IAM, ECS, ALB, RDS, and VPC endpoints. The `terraform/environments/dev/` directory composes these modules and currently uses **local Terraform state**. Keep state files, saved plans, `.env`, and sensitive `.tfvars` out of Git; keep `.terraform.lock.hcl` tracked.

The ECS service is controlled by the `enable_ecs_service` variable. During initial provisioning, the service was disabled until the database initialization task finished. Later applies must preserve the intended variable value to avoid unintended ECS service removal.

## 3. Application and Container Images

- `app/`: Flask backend, templates, static files, and automated tests.
- `database/init.sql`: Product table and seed data.
- `database/Dockerfile`: PostgreSQL client image used for one-time initialization.
- `compose.yaml` and `.env.example`: Local development configuration.

ECR repository `cloudcart-dev-app` stores the application image (`v2`) and initialization image (`db-init-v1`) using immutable tags.

## 4. Deployment Sequence

1. Run Python tests and Terraform validation.
2. Build and push the application and database initialization images to ECR.
3. Provision infrastructure with `enable_ecs_service=false` so RDS is ready before the application starts.
4. Run the ECS `cloudcart-dev-db-init` task in private application subnets, using the ECS security group and Secrets Manager credentials.
5. Wait for the task to stop and confirm container exit code `0`.
6. Enable the API service using `enable_ecs_service=true` and apply Terraform.
7. Wait for the ECS service to stabilize, inspect ALB target health, and open the ALB DNS name over HTTP.
8. Verify `/health`, `/ready`, `/api/products`, storefront rendering, and Add to Cart behavior.

**Important:** The lifecycle scripts automate Terraform planning, deployment, and destruction; they do not replace the initial one-time database initialization or the image publishing steps. When provisioning from scratch, follow the sequence above rather than enabling the API service before images and schema are ready.

## 5. Infrastructure Scripts

From the repository root in Git Bash:

```bash
bash scripts/plan.sh
bash scripts/deploy.sh
bash scripts/destroy.sh
```

Review the Terraform plan before applying or destroying. Destruction may remove the database and its contents. Separate bootstrap state and retained resources need independent review.

## 6. Application Endpoints

| Endpoint | Method | Purpose |
|---|---|---|
| `/` | GET | Storefront |
| `/health` | GET | Application liveness |
| `/ready` | GET | Database readiness |
| `/api/products` | GET | Product catalog |
| `/api/products/{id}` | GET | Individual product |

## 7. CI Workflow

The existing GitHub Actions workflow runs on pushes and pull requests to `main`, with three independent jobs:

- Python 3.12 / pytest application tests.
- Docker image build verification.
- Terraform formatting, backend-free initialization, and validation.

Continuous deployment is **not yet implemented**. Planned work includes GitHub Actions OIDC, ECR image publishing with commit-based immutable tags, ECS task definition updates, deployment verification, and failure handling.

## 8. Verification and Cost Control

The completed deployment passed RDS initialization (exit code `0`), ALB storefront access, display of three database-backed products, cart interaction, and Terraform drift check (no changes). Save deployment evidence before destroying the dev environment. RDS, ALB, Fargate, and VPC endpoints incur charges while provisioned.
