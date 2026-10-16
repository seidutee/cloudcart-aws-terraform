# CloudCart

CloudCart infrastructure and application scaffold.

## Repository layout

- `app/` contains the application source and container build definition.
- `terraform/bootstrap/` contains Terraform state-backend bootstrap configuration.
- `terraform/modules/` contains reusable infrastructure modules.
- `terraform/environments/` contains environment-specific Terraform configuration.
- `.github/workflows/` contains CI/CD workflow definitions.

Terraform module and application implementation can be added as those components are defined.
