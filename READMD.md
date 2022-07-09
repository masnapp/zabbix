Goal: 

Spin up Zabbix container in GKE using Terraform. 

Step 1: 
- Create project in Google cloud GUI
- Create credentials to access project 
- Navigate to IAM & Admin
- Configure OAuth Consent Screen
- Create service account
    - Role: Project/Editor
    - Create json key
        - Storred in ./secrets/
- Enable GKE API

Step 2 
- Create terraform directory 
- Create main.tf
    - Declare Providers. In this case we will be declaring the Google Provider as we are using GCP.      
```
terraform {
  required_providers {
    google = {
      source   = "hashicorp/google"
      version  = "4.27"
    }
  }
}

provider "google" {
  credentials      = file(var.credentials_file)
  project          = var.project
  region           = var.region
  zone             = var.zone
}
```
Step 3: 
- As you can see in the snippet above, we will be using variables for configuration information so we need to create two additional files. 
    - variables.tf
        - We will store variable declarations here 
```
# Project Variable, will prompt for project when ran
variable "project" {}

# Credentials to project for Terraform
variable "credentials_file" {}

# Variable for region with default 
variable "region" {
  default = "us-central1"
}

# Variable for zone with default 
variable "zone" {
  default = "us-central1-c"
}

variable "vpc_network" {
  default = "devops-network"
}
```
- terraform.tfvars
    - We will store variable values here 
```
project          = "<project-id>"
credentials_file = "<path/to/credential/file>"
vpc_network      = "<network_name>"
```
Step 3: 
CD to terraform directory and run:
### terraform init
This will verify that our IaC that we have written thus far is correct