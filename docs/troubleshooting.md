# CloudCart — Troubleshooting & Lessons Learned

[← Back to project overview](../README.md)

## 1. ALB Returned HTTP 503

**Symptom:** The ALB endpoint responded with `503 Service Unavailable` even though networking and database infrastructure existed.

**Investigation:** Checked ECS service listings, Terraform state, and the service resource configuration. The expected ECS service was missing from the cluster, so there were no application tasks to register as healthy ALB targets.

**Root cause:** The root Terraform module was not forwarding the `enable_ecs_service` setting to the ECS module's `enable_service` input. The ECS service resource used `count = var.enable_service ? 1 : 0`, so it was omitted.

**Resolution:** Added `enable_service = var.enable_ecs_service` to the root `module "ecs"` block. A subsequent Terraform plan showed the ECS service and autoscaling resources to be created. After deploying and initializing the database, the storefront became accessible.

**Lesson:** When a resource is missing, inspect module input wiring, conditional `count`/`for_each`, Terraform state, and actual AWS resources before blaming networking.

## 2. Database Initialization Order

**Challenge:** The Flask application expected PostgreSQL tables and seeded products before serving catalog requests.

**Resolution:** Packaged `database/init.sql` into a separate Docker image, published it to ECR, and executed it as a one-time ECS Fargate task after RDS provisioning. The task exited with code `0`, confirming successful initialization.

**Lesson:** Treat database schema preparation as an explicit deployment dependency. Container startup alone does not guarantee database readiness.

## 3. ECR Image and Task Definition Alignment

**Challenge:** The API and database initialization containers have different responsibilities and must use the correct image tags.

**Resolution:** Used immutable ECR tags (`v2` for the storefront/API and `db-init-v1` for initialization), and checked the ECS task definition image reference before running the task.

**Lesson:** Verify image URI, tag, task definition, and deployment ordering together. Publishing an image does not automatically update a running ECS service.

## 4. Terraform State and Cost Management

**Challenge:** The dev environment contains billable resources, and local Terraform state must stay consistent across deploy/destroy cycles.

**Resolution:** Added Bash lifecycle scripts and explicit review steps. Used `enable_ecs_service=true` consistently for the running application to avoid inadvertently removing the ECS service during a later apply.

**Lesson:** Terraform state is operationally critical. Keep state and saved plans out of version control; understand which state manages each resource, and verify cleanup in AWS.

## 5. End-to-End Verification

Successful deployment was verified by:

- One-time DB initialization task stopping with exit code `0`.
- Terraform reporting no changes after deployment.
- CloudCart storefront loading through the ALB.
- Three PostgreSQL-backed products appearing.
- Add to Cart functioning in the browser.

**Lesson:** Infrastructure provisioning is not the same as application success. Validate the actual user journey, not just Terraform exit codes.

## 6. Future Operational Improvements

- Automate immutable ECR image publishing and ECS releases with GitHub Actions OIDC.
- Add deployment health gates, alerting, and rollback procedures.
- Introduce HTTPS and production-grade edge security before handling real customer data.
- Add database migrations, backup verification, and recovery exercises.
