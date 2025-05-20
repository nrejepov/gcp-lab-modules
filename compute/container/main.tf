# Variables

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "gcr.io/google-samples/hello-app:2.0"
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
  default     = null
}

variable "restart_policy" {
  description = "Restart policy for the container"
  type        = string
  default     = "Always"
}

# Container configuration
module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.2"
  
  container = {
    image = var.container_image
    ports = var.container_ports
    env   = var.container_env
  }
  
  cos_image_name = var.cos_image_name
  restart_policy = var.restart_policy
}

# Outputs
output "metadata_value" {
  description = "The container declaration metadata value"
  value       = module.gce-container.metadata_value
}

output "vm_container_label" {
  description = "The container VM label"
  value       = module.gce-container.vm_container_label
}

output "cos_image_name" {
  description = "The COS image name"
  value       = module.gce-container.cos_image_name
}