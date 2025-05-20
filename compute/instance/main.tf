# Variables

variable "metadata" {
  description = "Metadata key/value pairs to make available from within the instance"
  type        = map(string)
  default     = {}
}

variable "machine_type" {
    description = "The machine type to use for the instance"
    type        = string
}

variable "zone" {
    description = "The zone where the instance will be created"
    type        = string
}

variable "image" {
    description = "The image to use for the boot disk"
    type        = string
}

variable "network_id" {
    description = "The ID of the network to attach the instance to"
    type        = string
}

variable "subnetwork_id" {
    description = "The ID of the subnetwork to attach the instance to"
    type        = string
}

variable "startup_script" {
    description = "The startup script to run on instance creation"
    type        = string
}

variable "service_account_email" {
    description = "The email of the service account to attach to the instance"
    type        = string
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "ca-lab-vm"
}

# VM instance resource
resource "google_compute_instance" "ca_lab_vm" {
    name         = var.instance_name
    machine_type = var.machine_type
    zone         = var.zone

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    network_interface {
        network    = var.network_id
        subnetwork = var.subnetwork_id
        access_config {}
    }

    metadata_startup_script = var.startup_script

    service_account {
        email  = var.service_account_email
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }
}

output "external_ip" {
    description = "The external IP address of the instance"
    value       = google_compute_instance.ca_lab_vm.network_interface[0].access_config[0].nat_ip
}
