## Make sure consul is still running, if not open a separate terminal
## Go into m4\consul and fire it back up by running 
consul agent -bootstrap -config-file="config/consul-config.hcl" -bind="127.0.0.1"

## Go back to first terminal window
## Go into m6 folder and into consul folder
cd consul

## We are going to add more config data to our Consul installation

# Let's set the Consul token to Admin Networking
# Replace SECRETID_VALUE with Admin Networking's secret ID

export CONSUL_HTTP_TOKEN=SECRETID_VALUE

# Write the configuration data for additional workspaces config
consul kv put networking/configuration/semperti-primary/development/net_info @dev-net.json
consul kv put networking/configuration/semperti-primary/qa/net_info @qa-net.json
consul kv put networking/configuration/semperti-primary/production/net_info @prod-net.json

# Let's create a development workspace for networking
cd ../networking

# Same backend for all workspaces
terraform init -backend-config="path=networking/state/semperti-primary"

# Create the workspace
terraform workspace new development

# Create and apply the configuration
terraform plan -out dev.tfplan

terraform apply "dev.tfplan"

# Repeat for qa environment
terraform workspace new qa

terraform plan -out qa.tfplan

terraform apply qa.tfplan

## Creating production is an exercise I leave to you!

## Now let's change to us Admin Application's token for Consul
## You can go into the ACL section of the Consul UI and grab it

export CONSUL_HTTP_TOKEN=SECRETID_VALUE

## Now we can add the application data to consul
# Go into the consul folder
cd ../consul

# Write the configuration data for additional workspaces config
consul kv put applications/configuration/semperti-primary/development/app_info @dev-app.json
consul kv put applications/configuration/semperti-primary/qa/app_info @qa-app.json
consul kv put applications/configuration/semperti-primary/production/app_info @prod-app.json
consul kv put applications/configuration/semperti-primary/common_tags @app-tags.json

## Go into the applications folder
cd ../applications

# Same backend for all workspaces
terraform init -backend-config="path=applications/state/semperti-primary"

# Create the workspace
terraform workspace new development

# Create and apply the configuration
terraform plan -out dev.tfplan

terraform apply "dev.tfplan"

# Repeat for qa environment
terraform workspace new qa

terraform plan -out qa.tfplan

terraform apply qa.tfplan