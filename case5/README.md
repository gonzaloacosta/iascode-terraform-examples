# IasCode - Terraform

## Items Review

  - Workspaces dev, uat y prod

## Commands

```bash
terraform init
terraform workspace new dev
terraform plan -out dev.tfplan
terraform apply "dev.tfplan"

terraform workspace new uat
terraform plan -out uat.tfplan
terraform apply "uat.tfplan"

#Don't forget to remove from tfvars, variables, and resource provider
export AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"

terraform workspace new prod
terraform plan -out prod.tfplan
terraform apply "prod.tfplan"

terraform destroy

terraform workspace select uat
terraform destroy

terraform workspace select dev
terraform destroy
```
