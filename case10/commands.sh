# Export admin-network profile
aws configure --profile=admin-network
export AWS_PROFILE=admin-network

# Run consul in separete terminal in case7/consul
consul agent -bootstrap -config-file="config/consul-config.hcl" -bind="127.0.0.1"

## Go back to first terminal window
# We are going to create two tokens for Jenkins to use net and app
# First use the root token

# Linux and MacOS
#export CONSUL_HTTP_TOKEN=SECRETID_ROOT

export CONSUL_HTTP_TOKEN=96156d8e-6a0b-9c31-3248-85cd15a0d265

# Create two tokens (networking and applications)
consul acl token create -policy-name=networking -description="Jenkins networking"
consul acl token create -policy-name=applications -description="Jenkins applications"

☁  case10  consul acl token create -policy-name=networking -description="Jenkins networking"
AccessorID:       b220a9b8-45a4-6b55-0fbb-b81e1e273ce0
SecretID:         d53e3342-792c-9fc4-1f0b-c8cf4426833b
Description:      Jenkins networking
Local:            false
Create Time:      2020-11-20 00:47:12.720773781 -0300 -03
Policies:
   257ff0fc-65f2-9399-7fcf-0813e78143f7 - networking

☁  case10  consul acl token create -policy-name=applications -description="Jenkins applications"
AccessorID:       f60a236c-a232-5193-8634-c2befb904f55
SecretID:         6e577499-bec1-9343-32ea-61ec3dea1730
Description:      Jenkins applications
Local:            false
Create Time:      2020-11-20 00:47:17.149869813 -0300 -03
Policies:
   cb9d5f5d-bb8f-634e-80ad-ec34df431231 - applications

☁  case10  


# Create a Jenkins container
docker pull jenkins/jenkins:lts
#docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:lts
docker run --net=host -d -v /docker/volumes/jenkins:/var/jenkins_home --name jenkins jenkins/jenkins:lts
docker logs jenkins

#Copy the admin password
http://127.0.0.1:8080

# Install suggested plugins
# Create a user
# Manage jenkins
# Manage plugins
# Search for Terraform in Available and install without restart
# Back to Manage jenkins
# Global Tool Configuration
# Add Terraform
# Name: terraform 
# Install automatically
# Version - latest for linux (amd64)
# Click Save

# Create a new item
# Name: net-deploy
# Type pipeline
# Select poll SCM
# Definition: Pipeline script from SCM
# SCM: Git
# Repo URL: YOUR_REPO_URL or https://gitlab.com/gonzaloacosta/terraform-jenkins
# Script path: networking/Jenkinsfile
# Uncheck lightweight checkout

# Go to credentials -> global
# Create a credential of type secret text with ID networking_consul_token and the consul token as the secret
# Create a credential of type secret text with ID applications_consul_token and the consul token as the secret
# Create a credential of type secret text with ID aws_access_key and the access key as the secret
# Create a credential of type secret text with ID aws_secret_access_key and the access secret as the secret

#Now we can run a build of the network pipeline
# First build might fail, but now the parameters will be Available

# Run a new build WITH parameters

# When build is successful create a new pipeline for the application stack

# Create a new item
# Name: app-deploy
# Type pipeline
# Select poll SCM
# Definition: Pipeline script from SCM
# SCM: Git
# Repo URL: YOUR_REPO_URL or https://gitlab.com/gonzaloacosta/terraform-jenkins
# Script path: applications/Jenkinsfile
# Uncheck lightweight checkout

# First build might fail, but now the parameters will be Available


# Then run the build again