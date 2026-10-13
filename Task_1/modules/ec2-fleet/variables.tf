variable "security_group_ids" {
  description = "Security group IDs to attach to each instance."
  type        = list(string)
}

variable "environment" {
  description = "Environment tag applied to every instance."
  type        = string
}

variable "owner" {
  description = "Owner tag applied to every instance."
  type        = string
}

variable "instances" {
  description = "Instance-specific configuration, keyed by instance name."

  type = map(object({
    instance_type     = string
    root_volume_type  = string
    root_volume_size  = number
    key_name          = string
    root_volume_iops = optional(number)
  }))

  validation {
    condition     = length(var.instances) == 5
    error_message = "Exactly five instances must be provided."
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      contains(["gp2", "gp3", "io1", "io2", "st1", "sc1", "standard"], instance.root_volume_type)
    ])
    error_message = "Each root_volume_type must be a supported EBS volume type."
  }
}