# IasCode - Terraform

## Case 2 - Initial Deploy

### Items Review

  - Authentication with Variables
  - New VPC
  - Subnets
  - Security Groups
  - EC2 Blue with provisioner

### Commands 

```bash
terraform init
terraform plan -out case2.tfplan
terraform apply case2.tfplan

terraform show
terraform output
```

## Case 2 - Update Deploy

### Items Review

  - Subnet 2
  - Route table assocition for subnet 2
  - Elastic Load Balancer (ELB)
  - EC2 Green with provisioner

### Commands

```bash
# Rename with the update file
mv case2-init.tf case2-init.tf.old
mv case2-update.tf.rename case2-update.tf

terraform plan -out case2.tfplan
terraform apply case2.tfplan

terraform destroy

# Set the files back
mv case2-init.tf.old case2-init.tf
mv case2-update.tf case2-update.tf.rename
```
