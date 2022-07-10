<h1>How to install Zabbix using Docker, Google Cloud, and Terraform</h>

<h2>Step 1:</h2> 

Create project in Google cloud GUI
- Create credentials to access project 
- Navigate to IAM & Admin
- Configure OAuth Consent Screen
- Create service account
    - Role: Project/Editor
    - Create json key
        - Storred in ./secrets/
- Enable GKE API

<h2>Step 2</h2>

Create terraform directory 
- Create main.tf
    - Declare Providers. In this case we will be declaring the Google Provider as we are using GCP.      

```terraform
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
<h2>Step 3:</h2>

As you can see in the snippet above, we will be using variables for configuration information so we need to create two additional files. 
    - variables.tf
        - We will store variable declarations here 

```terraform
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
```terraform
project          = "<project-id>"
credentials_file = "<path/to/credential/file>"
vpc_network      = "<network_name>"
```

<h2>Step 3:</h2>

CD to terraform directory and run:
```terraform
terraform init
```
This will verify that our IaC that we have written thus far is correct.

If we run: 
```terraform
terraform plan 
```
We will see that there are no changes needed. 

<h2>Step 4:</h2>

Now we need to create our resource that will hold our Zabbix container(s).

In our case, we will host Zabbix on a Compute Instnace. In terraform the syntanx for this is `google_compute_instance`.

Add the following to the `main.tf` file create earlier:

```terraform 
variable "vm_name" {
    default = "ZABBIX-HOST"
}
variable "machine_type" {
    default = "e2-micro"
}

variable "vm_image" {
    default = "cos-cloud/cos-97-lts"
```

And then add the following to your `terraform.tfvars` file and replace values with your requirements:

```terraform 
vm_name = "ZABBIX-HOST"
machine_type = "e2-micro"
vm_image = "cos-cloud/cos-97-lts"
```

Now we can run `terraform plan` to verify our files are correct. We will see what resources terraform will destory or remove as denoted by either a + or - symbol.

<!-- Need to create storage resources to store zabbix data -->