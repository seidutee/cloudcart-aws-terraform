variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )
    error_message = "Must be MUTABLE or IMMUTABLE."
  }
}

variable "image_retention_count" {
  description = "Maximum number of tagged images to retain"
  type        = number
  default     = 10

  validation {
    condition     = var.image_retention_count >= 1
    error_message = "Retention count must be at least 1."
  }
}
