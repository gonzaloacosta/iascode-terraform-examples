# IasCode - Terraform

## Items Review

  - Function
  - Terraform Console
  - Provider GoDaddy DNS

## Commands

```bash
#Functions testing

terraform console
min(42,5,16)
cidrsubnet(var.network_address_space, 8, 0)
cidrhost(cidrsubnet(var.network_address_space, 8, 0),5)
lookup(local.common_tags, "BillingCode", "Unknown")
lookup(local.common_tags, "Missing", "Unknown")
local.s3_bucket_name

#Configuration command

terraform init
terraform plan -out case4.tfplan
terraform apply "case4.tfplan"

terraform destroy
```

## Plugins GoDaddy

```bash
bash <(curl -s https://raw.githubusercontent.com/n3integration/terraform-godaddy/master/install.sh)


curl -X GET -H"Authorization: sso-key e5CjXom68Jwr_4Kr2zk3YGZ1wC6LWasUA6b:HZUNNMpXx6r3PWxMTSvc1K" "https://api.godaddy.com/v1/domains/available?domain=gonzaloacosta.com" 
{"available":false,"definitive":true,"domain":"gonzaloacosta.com"}


export GODADDY_API_KEY=e5CjXom68Jwr_4Kr2zk3YGZ1wC6LWasUA6b
export GODADDY_API_SECRET=HZUNNMpXx6r3PWxMTSvc1K
```
