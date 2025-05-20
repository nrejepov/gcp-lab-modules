# Variables

variable "container_image" {
  description = "Container image to deploy (e.g., gcr.io/google-samples/hello-app:2.0)"
  type        = string
  default     = "gcr.io/google-samples/hello-app:1.0"
}

variable "container_ports" {
  description = "Ports to expose from the container"
  type        = list(object({
    containerPort = number
    hostPort      = number
  }))
  default     = [
    {
      containerPort = 8080
      hostPort      = 8080
    }
  ]
}

variable "container_env" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default     = []
}

variable "cos_image_name" {
  description = "The specific COS image to use"
  type        = string
  default     = "cos-stable-77-12371-89-0"
}

variable "restart_policy" {
  description = "Restart policy for the container (Always, OnFailure, Never)"
  type        = string
  default     = "Always"
}

# Add the container configuration
module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.0"
  
  container = {
    image = var.container_image
    ports = var.container_ports
  }
  
  # COS image
  cos_image_name = var.cos_image_name
  restart_policy = var.restart_policy
}

# Add the container metadata to the VM
resource "google_compute_instance_metadata" "container_metadata" {
  instance = module.vm.instance_id
  
  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
  }
}

# Add container-specific labels
resource "google_compute_instance_labels" "container_labels" {
  instance = module.vm.instance_id
  
  labels = {
    container-vm = module.gce-container.vm_container_label
  }
}
