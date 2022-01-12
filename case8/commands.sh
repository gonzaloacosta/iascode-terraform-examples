## Go into consul subfolder
cd consul

## We are going to add config data to our Consul installation

# Let's set the Consul token to Admin Network
# Replace SECRETID_VALUE with Admin Network's secret ID
#export CONSUL_HTTP_TOKEN=SECRETID_VALUE

export CONSUL_HTTP_TOKEN=bea686dc-5f1b-7476-8ec8-df566dbd4b5b

# Write the configuration data for semperti-primary config
consul kv put networking/configuration/semperti-primary/net_info @semperti-primary.json
consul kv put networking/configuration/semperti-primary/common_tags @common-tags.json

## Now go up and into the networking folder
cd ../networking

## We're going to initialize the Terraform config to use the Consul backend
terraform init -backend-config="path=networking/state/semperti-primary"

# Verify our state is loaded
terraform state list

# Now we'll run a plan using the values stored in Consul.
# There should be NO changes required
terraform plan -out config.tfplan

## Now we'll update our config data to use templates and default tags
# Go into the consul folder
cd ../consul

# Write new data
consul kv put networking/configuration/semperti-primary/net_info @semperti-primary-2.json

# Go into the networking2 folder
cd ../networking2

## We're going to initialize the Terraform config to use the Consul backend
terraform init -backend-config="path=networking/state/semperti-primary"

# Verify our state is loaded
terraform state list

# Now we'll run a plan using the values stored in Consul.
# All the tags should be updated
terraform plan -out config.tfplan

terraform apply config.tfplan
