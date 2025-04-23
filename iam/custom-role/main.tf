variable "project_id" {
  description = "The ID of the project where the custom IAM role will be created."
  type        = string
}

variable "role_id_prefix" {
  description = "The prefix for the custom IAM role ID."
  type        = string
  default     = "labcustomrole"
}

variable "name" {
  description = "The name of the custom IAM role."
  type        = string
  default     = "lab-custom-role"
}

variable "title" {
  description = "The title of the custom IAM role."
  type        = string
  default     = "LabCustomRole"
}

variable "included_permissions" {
  description = "The list of permissions to include in the custom IAM role."
  type        = list(string)
}

resource "time_static" "current_time" {}

locals {
  epoch_timestamp = time_static.current_time.unix
  role_id = "${var.role_id_prefix}_${local.epoch_timestamp}"
}

resource "google_project_iam_custom_role" "custom_role" {
  role_id     = local.role_id
  title       = var.title
  description = "Custom role for the lab"
  project     = var.project_id
  permissions = var.included_permissions
  stage       = "GA"
}

output "role_id" {
  description = "The full ID of the created custom IAM role."
  value       = "projects/${var.project_id}/roles/${google_project_iam_custom_role.custom_role.role_id}"
}