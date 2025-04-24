variable "project_id" {
  description = "The ID of the project where the service account will be created."
  type        = string
}

variable "roles" {
  description = "A list of IAM roles to bind to the service account."
  type        = list(string)
}

variable "identifier_suffix" {
  description = "The suffix for the service account identifier."
  type        = string
  default     = "sa"
}

variable "display_name" {
  description = "The display name for the service account. Defaults to the service account identifier."
  type        = string
  default     = null
}

locals {
  project_name    = length(split(":", var.project_id)) > 1 ? join(".", reverse(split(":", var.project_id))) : var.project_id
  sa_identifier   = substr("${local.project_name}-${var.identifier_suffix}", 0, 30)
  sa_display_name = var.display_name != null ? var.display_name : local.sa_identifier
}

resource "google_service_account" "service_account" {
  account_id   = local.sa_identifier
  display_name = local.sa_display_name
  project      = var.project_id
}

resource "terraform_data" "delay_after_creation" {
  depends_on = [google_service_account.service_account]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "google_project_iam_member" "iam_bindings" {
  count = length(var.roles)

  depends_on = [terraform_data.delay_after_creation] # Ensure delay is applied before IAM bindings

  project = var.project_id
  role    = var.roles[count.index]
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

output "name" {
  description = "The name of the created service account."
  value       = google_service_account.service_account.name
  depends_on  = [terraform_data.delay_after_creation] # Ensure delay before output
}

output "email" {
  description = "The email of the created service account."
  value       = google_service_account.service_account.email
  depends_on  = [terraform_data.delay_after_creation] # Ensure delay before output
}