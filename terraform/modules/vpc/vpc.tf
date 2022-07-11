resource "google_compute_network" "vpc" {
    name = "${var.project_name}-vpc"
    auto_create_subnetworks = "false"
    routing_mode  = "GLOBAL"
}
output "network-name" {
  value = google_compute_network.vpc.name
}

resource "google_compute_subnetwork" "private_subnet" {
    name = "${var.project_name}-vpc-private-subnet"
    ip_cidr_range = var.private_subnet
    network = google_compute_network.vpc.name
    region = var.region
}

output "private_subnet" {
  value = google_compute_subnetwork.private_subnet.name
}

resource "google_compute_subnetwork" "public_subnet" {
    name = "${var.project_name}-vpc-public-subnet"
    ip_cidr_range = var.public_subnet
    network = google_compute_network.vpc.name
    region = var.region
    
}

output "public_subnet" {
  value = google_compute_subnetwork.public_subnet.name
}



resource "google_compute_firewall" "allow-http" {
    name = "${var.project_name}-vpc-http-fw"
    network = google_compute_network.vpc.name
    allow {
      protocol = "tcp"
      ports = ["80","443"]
    }
    source_ranges = [ "0.0.0.0/0" ]
    target_tags = ["zabbix"]
}

resource "google_compute_firewall" "allow-ssh" {
    name = "${var.project_name}-vpc-ssh-fw"
    network = google_compute_network.vpc.name
    # subnetwork = google_compute_subnetwork.public_subnet.name
    allow {
      protocol = "tcp"
      ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["ssh"]
  
}
