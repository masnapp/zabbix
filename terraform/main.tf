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

# Create VPC
resource "google_compute_network" "vpc_network" {
    name = var.vpc_network
    auto_create_subnetworks = true
}

# Create data disk 
resource "google_compute_disk" "pd" {
    name = "zabbix-data"
    size = 10 
    type = "pd-standard"
    labels = {
        enviorment = "zabbix"
    }
}

# Create VM to host Docker/Zabbix
resource "google_compute_instance" "vm_instance" {
  name         = var.vm_name
  machine_type = var.machine_type
  tags = [ "zabix", "ssh" ]

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  attached_disk {
    source = google_compute_disk.pd.self_link
    device_name = "data-disk-0"
    mode = "READ_WRITE"
  }

  network_interface {
    # A default network is created for all GCP projects
    network = var.vpc_network
    access_config {
    }
  }

  metadata_startup_script = "${file("../scripts/zabbix_startup.sh")}"

}