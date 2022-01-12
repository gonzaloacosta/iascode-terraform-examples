# Configure an AWS profile with proper credentials
aws configure --profile admin-network

#admin-network
#AKIA3PIQT4UYOMHJX5MM
#z46UY+QtGEuXly5RBDw2mGkAT0rOedkf0jzuoyyD

#admin-application
#AKIA3PIQT4UYMCLNX4N5
#QgKU3eEeAmWNwMjvQLFE/o4xaksJwr/ZX32+HNgv

# Linux or MacOS
export AWS_PROFILE=admin-network

# Deploy the current environment
terraform init
terraform validate
terraform plan -out case7.tfplan
terraform apply "case7.tfplan"

# Create subnet manually

./create-subnet.sh
privateRouteTable: rtb-0fc1a6ae2b9296428
privateRouteTableAssoc: subnet-0fe180b78fa8b5e50/rtb-0fc1a6ae2b9296428
privateSubnet: subnet-0fe180b78fa8b5e50
publicRouteTableAssoc: subnet-047a6352c67aebf32/rtb-0b772b660f7339c9b
publicSubnet: subnet-047a6352c67aebf32

# Problems with zsh
# https://github.com/ohmyzsh/ohmyzsh/issues/7894

terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table.private[2]" "rtb-0fc1a6ae2b9296428"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table_association.private[2]" "subnet-0fe180b78fa8b5e50/rtb-0fc1a6ae2b9296428"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_subnet.private[2]" "subnet-0fe180b78fa8b5e50"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table_association.public[2]" "subnet-047a6352c67aebf32/rtb-0b772b660f7339c9b"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_subnet.public[2]" "subnet-047a6352c67aebf32"

terraform plan -out case7.tfplan

# There should be 3 changes where tags are added

terraform apply "case7.tfplan"

terraform destroy

## First let's try out some terraform state commands
## Go to the m3 folder and run the state commands

# View all the Terraform resources
terraform state list

# Now let's look at a specific resource
terraform state show module.vpc.aws_vpc.this[0]

# We can also view all the state data
terraform state pull

## Now it's time to deploy our local Consul server node
## Download the consul executable from https://www.consul.io/downloads
## https://releases.hashicorp.com/consul/1.8.5/consul_1.8.5_linux_amd64.zip

# Go into the consul subfolder
cd consul

# Create a data subdirectory
mkdir data

# Launch consul server instance
consul agent -bootstrap -config-file="config/consul-config.hcl" -bind="127.0.0.1"

# Open a separate terminal window to run the rest of the commands

# Generate the bootstrap TOKEN ROOT
consul acl bootstrap
AccessorID:       66fac0a5-3e13-b8d2-6ee5-2e42996ca3a9
SecretID:         96156d8e-6a0b-9c31-3248-85cd15a0d265
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2020-11-19 16:45:04.781246459 -0300 -03
Policies:
   00000000-0000-0000-0000-000000000001 - global-management

# Set CONSUL_TOKEN to SecretID (ROOT TOKEN)

# Linux and MacOS
export CONSUL_HTTP_TOKEN=96156d8e-6a0b-9c31-3248-85cd15a0d265

# Set up paths, policies, and tokens
cd consul/

terraform init
terraform plan -out consul.tfplan
terraform apply consul.tfplan

admin_application_token_accessor_id = aa90a0df-8d6e-59fa-8dc8-9d28b8b8a0da
admin_network_token_accessor_id = 3f0f4d03-0089-8ebf-316d-dfa1ee10e029

# Get token values for admin-network and admin-application and record them for later
consul acl token read -id aa90a0df-8d6e-59fa-8dc8-9d28b8b8a0da
consul acl token read -id 3f0f4d03-0089-8ebf-316d-dfa1ee10e029

☁  consul  consul acl token read -id aa90a0df-8d6e-59fa-8dc8-9d28b8b8a0da
AccessorID:       aa90a0df-8d6e-59fa-8dc8-9d28b8b8a0da
SecretID:         a82957c7-c4cf-aaf8-2b9c-4dbade882d76 >>>>>
Description:      token for Admin Application
Local:            false
Create Time:      2020-11-19 16:51:28.952280299 -0300 -03
Policies:
   cb9d5f5d-bb8f-634e-80ad-ec34df431231 - applications

☁  consul  consul acl token read -id 3f0f4d03-0089-8ebf-316d-dfa1ee10e029
AccessorID:       3f0f4d03-0089-8ebf-316d-dfa1ee10e029
SecretID:         bea686dc-5f1b-7476-8ec8-df566dbd4b5b >>>>> 
Description:      token for Admin Network
Local:            false
Create Time:      2020-11-19 16:51:28.952238308 -0300 -03
Policies:
   257ff0fc-65f2-9399-7fcf-0813e78143f7 - networking


# Go back to the main case7 folder
cd ..

## Now let's set up the Consul backend and migrate the state

# Copy the backend.tf file to case7
mv backend.tf-rename backend.tf

# Move to the case7 folder
cd ../case7

# Now let's set the Consul token to admin-network
# Replace SECRETID_VALUE with admin-network's secret ID
export CONSUL_HTTP_TOKEN=bea686dc-5f1b-7476-8ec8-df566dbd4b5b

# Now we can initialize the backend config
terraform init -backend-config="path=networking/state/semperti-primary"

# Change the enable_nat_gateway to true in the resources.tf file

# Now run terraform plan and apply
terraform plan -out nat.tfplan
terraform apply nat.tfplan

# Open a second terminal
# Export the Consul token again
# Try to run a terraform plan
terraform plan

