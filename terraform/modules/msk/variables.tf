variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for MSK cluster"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of EKS nodes"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version for MSK cluster"
  type        = string
  default     = "3.5.1"
  
  validation {
    condition = contains([
      "2.8.1", "2.8.2.tiered", "3.1.1", "3.2.0", "3.3.1", "3.3.2", "3.4.0", "3.5.1"
    ], var.kafka_version)
    error_message = "Kafka version must be a supported MSK version."
  }
}

variable "instance_type" {
  description = "Instance type for MSK cluster"
  type        = string
  default     = "kafka.t3.small"
  
  validation {
    condition = can(regex("^kafka\\.", var.instance_type))
    error_message = "Instance type must be a valid Kafka instance type (kafka.*)."
  }
}

variable "ebs_volume_size" {
  description = "EBS volume size for MSK cluster (GB)"
  type        = number
  default     = 100
  
  validation {
    condition     = var.ebs_volume_size >= 1 && var.ebs_volume_size <= 16384
    error_message = "EBS volume size must be between 1 and 16384 GB."
  }
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes for MSK cluster"
  type        = number
  default     = 2
  
  validation {
    condition     = var.number_of_broker_nodes >= 1 && var.number_of_broker_nodes <= 15
    error_message = "Number of broker nodes must be between 1 and 15."
  }
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring for MSK cluster"
  type        = bool
  default     = true
}

variable "client_authentication_sasl_scram" {
  description = "Enable SASL/SCRAM authentication"
  type        = bool
  default     = false
}

variable "client_authentication_sasl_iam" {
  description = "Enable SASL/IAM authentication"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
