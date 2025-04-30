# Variables

variable "region" {
    description = "The region where the instance will be created"
    type        = string
    default     = "us-central1"
}

variable "cidr_range" {
    description = "The CIDR range for the subnetwork"
    type        = string
}

variable "network_name" {
    description = "The name of the network"
    type        = string
    default     = "vm-network"
}
variable "subnet_name" {
    description = "The name of the subnetwork"
    type        = string
    default     = "vm-subnet"
}
# Network
resource "google_compute_network" "vm_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Subnetwork
resource "google_compute_subnetwork" "vm_subnet" {
  name          = var.subnet_name
  network       = google_compute_network.vm_network.id
  region        = var.region
  ip_cidr_range = var.cidr_range
}

# Outputs

output "network_id" {
    description = "The ID of the VM network"
    value       = google_compute_network.vm_network.id
}

output "subnet_id" {
    description = "The ID of the VM subnetwork"
    value       = google_compute_subnetwork.vm_subnet.id
}