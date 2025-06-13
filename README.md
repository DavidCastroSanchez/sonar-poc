# Sonar - Highly Available AWS Infrastructure with Disaster Recovery

A Terraform project that deploys a highly available infrastructure with disaster recovery capabilities on AWS.

![Main Architecture Overview](assets/main_architecture.png)

## Architecture Overview

This project implements a highly available architecture with the following components:

### Network Layer
- VPC with public and private subnets across multiple availability zones
- Public subnets for internet-facing resources
- Private subnets for application and database tiers
- NAT Gateways to allow private subnet resources to access the internet
- Configurable deployment with either a single NAT Gateway or one NAT Gateway per AZ
- DNS support and hostname resolution enabled
- Security groups with least privilege access controls

### Load Balancing
- Application Load Balancer for traffic distribution
- Health checks to ensure application availability

### Application Layer
- ECS clusters for containerized applications
- EC2 launch type 
- Auto-scaling based on CPU utilization
- IAM roles with least privilege permissions
- CloudWatch for container logs

### Database Layer
- Aurora MySQL 8.0 cluster deployed across multiple availability zones
- Automated backups for same-region disaster recovery
- Encrypted storage and connections
- Credentials stored in AWS Secrets Manager
- CloudWatch integration for logs

### Disaster Recovery
- Same-region DR using Aurora automated backups
- Configurable backup retention periods
- Ability to restore from backups in case of failure
- Optional cross-region disaster recovery using AWS Backup

## Project Structure

```
terraform-project/
├── environments/
│   ├── dev/       # Development environment 
│   └── prod/      # Production environment 
├── modules/
│   ├── alb/       # Application Load Balancer module
│   ├── aurora/    # Aurora database module
│   ├── dr/        # Disaster Recovery module
│   ├── ecs-cluster/ # ECS Cluster module
│   ├── ecs-service/ # ECS Service module
│   ├── s3/        # S3 bucket module
│   └── vpc/       # VPC network module
└── README.md
...
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- AWS CLI configured with appropriate credentials
- Basic knowledge of AWS services and Terraform

## Deployment Instructions

Main architecture (If you require cross-region protection, see the next section).

```bash
git clone https://github.com/DavidCastroSanchez/sonar-poc.git
cd sonar-poc
cd environments/<your-enviroment>/
terraform init
terraform plan
terraform apply
```
In case of a disaster, you can redeploy the infrastructure from scratch and recover the sensitive data stored in Aurora using the service’s automated backups.
**Note**: This proof of concept assumes that the only critical data is stored in the database, all other data and resources are considered stateless.

![Main Architecture Overview](assets/main_architecture.png)

### (optional) Enabling Cross-Region Disaster Recovery

If you require cross-region DR protection, you can enable the cross-region disaster recovery module:

```bash
git clone https://github.com/DavidCastroSanchez/sonar-poc.git
cd sonar-poc
cd environments/<your-enviroment>/
terraform init
terraform plan -var="enable_dr=true"
terraform apply -var="enable_dr=true"
```

This configures AWS Backup to create daily backups of the Aurora database. In the event of a regional disaster, you can deploy the solution in the DR region and restore the Aurora database from the backup.
**Note**: This proof of concept assumes that the only critical data is stored in the database, all other data and resources are considered stateless.

![(Optional) Cross Region Disaster Recovery Architecture](assets/cross-region-dr.png)

## Clean Up

To destroy the infrastructure:

```bash
cd environments/<your-enviroment>/
terraform destroy
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.