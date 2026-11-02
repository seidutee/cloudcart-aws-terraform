# CloudCart — AWS Cloud-Native E-Commerce Platform

CloudCart is a containerized e-commerce demonstration application deployed on AWS using Terraform, Amazon ECS Fargate, Amazon RDS PostgreSQL, Amazon ECR, and an Application Load Balancer.

**Project status: Core AWS deployment completed and successfully tested.**

## Architecture

```text
Customer / Web Browser
          |
          v
Application Load Balancer (HTTP)
          |
          v
Amazon ECS Fargate
CloudCart Flask Application
          |
          v
Amazon RDS PostgreSQL
```

Supporting infrastructure includes:

- Amazon VPC with public and private subnets across two Availability Zones
- Security groups and private database networking
- Amazon ECR for Docker images
- IAM roles and AWS Secrets Manager
- VPC endpoints for private AWS service access
- Amazon CloudWatch Logs
- ECS service autoscaling configuration
- Terraform for infrastructure provisioning
- GitHub Actions for CI validation

## Application Features

- Responsive e-commerce storefront
- Product catalog retrieved from PostgreSQL
- Product pricing and inventory display
- Interactive demonstration shopping cart
- REST API for product retrieval
- Application health and database readiness endpoints

The cart is a frontend demonstration. Checkout, payment processing, and order persistence are not implemented.

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | HTML, CSS, JavaScript |
| Backend | Python, Flask |
| Database | PostgreSQL 16 |
| Containers | Docker |
| Orchestration | Amazon ECS Fargate |
| Container registry | Amazon ECR |
| Networking | Amazon VPC, ALB |
| Security | IAM, Secrets Manager, security groups |
| Infrastructure as Code | Terraform |
| CI | GitHub Actions |

## Deployment Workflow

1. Validate Terraform configuration and run application tests.
2. Build Docker images for the Flask application and database initialization.
3. Push images to Amazon ECR.
4. Deploy AWS infrastructure using Terraform with the API service disabled.
5. Run a one-time ECS task to initialize the RDS database.
6. Verify that database initialization exits successfully.
7. Enable the ECS API service through Terraform.
8. Verify ECS service health and ALB connectivity.
9. Access the storefront through the ALB DNS endpoint.

## Docker Images

A single ECR repository, `cloudcart-dev-app`, contains:

- `v2` — Flask API and storefront
- `db-init-v1` — PostgreSQL initialization container

ECR tags are immutable.

## API Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | CloudCart storefront |
| `/health` | Application health |
| `/ready` | Database readiness |
| `/api/products` | List products |
| `/api/products/{id}` | Retrieve a product |

## Deployment Verification

The following tests were successfully completed during the live AWS deployment:

- Terraform infrastructure deployment completed.
- Database initialization ECS task exited with code `0`.
- CloudCart website loaded through the public ALB endpoint.
- Three products were retrieved and displayed.
- Add to Cart functionality worked in the browser.
- Terraform reported no pending changes after deployment.

## Security and Limitations

- RDS is deployed in private subnets.
- ECS tasks run in private application subnets.
- Database credentials are supplied through AWS Secrets Manager.
- IAM execution and task roles are separated.
- The development ALB endpoint uses HTTP and is not suitable for transmitting sensitive customer information.
- This deployment is a validated portfolio environment, not a production-ready payment platform.

## Future Enhancements

- Amazon CloudFront
- Amazon Route 53 with a custom domain
- HTTPS from the browser through to the application origin
- AWS WAF
- Advanced deployment strategies
- Expanded monitoring, disaster recovery, and automated database migrations

## Cost Management

AWS resources such as RDS, the ALB, Fargate tasks, and VPC endpoints can incur ongoing charges.

After collecting deployment evidence, destroy the dev environment with:

```bash
terraform -chdir=terraform/environments/dev destroy \
  -var="enable_ecs_service=true"
```

Review the destruction plan carefully and verify that billable resources have been removed. Separately managed Terraform bootstrap resources may require separate cleanup.

## Project Outcome

Successfully designed, provisioned, deployed, and tested a working containerized e-commerce application on AWS using reusable Terraform modules, managed infrastructure services, and Docker-based application delivery.
