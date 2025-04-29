variable "project_id" {
    description = "The GCP project ID where the Kubernetes cluster will be created."
    type        = string
}

variable "cluster_name" {
    description = "The name of the Kubernetes cluster."
    type        = string
}

variable "zone" {
    description = "The GCP zone where the Kubernetes cluster will be deployed."
    type        = string
}

variable "initial_node_count" {
    description = "The initial number of nodes in the Kubernetes cluster."
    type        = number
    default     = 2
}

variable "machine_type" {
    description = "The machine type to use for the Kubernetes cluster nodes."
    type        = string
    default     = "n1-standard-1"
}

variable "disk_size_gb" {
    description = "The size of the disk in GB for each Kubernetes cluster node."
    type        = number
    default     = 10
}

variable "workload_identity" {
    description = "Enable or disable workload identity for the Kubernetes cluster."
    type        = bool
    default     = false
}

variable "k8s_version" {
    description = "The Kubernetes version to use for the cluster."
    type        = string
    default     = "1.32"
}

resource "google_container_cluster" "primary" {
    name               = var.cluster_name
    location           = var.zone
    initial_node_count = var.initial_node_count
    deletion_protection = false

    node_config {
        machine_type = var.machine_type
        disk_size_gb = var.disk_size_gb
        oauth_scopes = [
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/trace.append",
        ]

        dynamic "workload_metadata_config" {
            for_each = var.workload_identity ? [1] : []
            content {
                mode = "GKE_METADATA"
            }
        }
    }

    dynamic "workload_identity_config" {
        for_each = var.workload_identity ? [1] : []
        content {
            workload_pool = "${var.project_id}.svc.id.goog"
        }
    }

    min_master_version = var.k8s_version
}

