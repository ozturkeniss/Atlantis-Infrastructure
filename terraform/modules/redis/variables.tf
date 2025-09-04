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
  description = "List of subnet IDs for Redis subnet group"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of EKS nodes"
  type        = string
}

variable "node_type" {
  description = "Node type for ElastiCache Redis cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "parameter_group_name" {
  description = "Parameter group name for ElastiCache Redis cluster"
  type        = string
  default     = "default.redis7"
}

variable "engine_version" {
  description = "Engine version for ElastiCache Redis cluster"
  type        = string
  default     = "7.0"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters for ElastiCache Redis"
  type        = number
  default     = 1
  
  validation {
    condition     = var.num_cache_clusters >= 1 && var.num_cache_clusters <= 6
    error_message = "Number of cache clusters must be between 1 and 6."
  }
}

variable "port" {
  description = "Port for ElastiCache Redis cluster"
  type        = number
  default     = 6379
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover for ElastiCache Redis cluster"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ for ElastiCache Redis cluster"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
