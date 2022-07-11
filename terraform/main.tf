terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

module "vpc" {
  source = "./modules/vpc/"
}
# Create data disk 
resource "google_compute_disk" "pd" {
  name = var.pd_name
  size = var.pd_size
  type = var.pd_type
  labels = {
    enviorment = "zabbix"
  }
}

# Create VM to host Docker/Zabbix
resource "google_compute_instance" "vm_instance" {
  name         = var.vm_name
  machine_type = var.machine_type
  tags         = ["zabbix", "ssh"]

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  attached_disk {
    source = google_compute_disk.pd.self_link
    # device_name = "data-disk-0"
    mode = "READ_WRITE"
  }

  network_interface {
    # A default network is created for all GCP projects
    subnetwork = "${module.vpc.public_subnet}"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = file("../scripts/startup.sh")

}