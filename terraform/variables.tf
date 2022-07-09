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
  default = "my-network"
}