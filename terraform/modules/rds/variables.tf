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
  description = "List of subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of EKS nodes"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for RDS instance (GB)"
  type        = number
  default     = null
}

variable "storage_encrypted" {
  description = "Enable storage encryption for RDS instance"
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for RDS instance"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "atlasdb"
}

variable "username" {
  description = "Username for the database"
  type        = string
  default     = "atlas_user"
}

variable "password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "Backup retention period for RDS instance (days)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window for RDS instance"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window for RDS instance"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS instance"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection for RDS instance"
  type        = bool
  default     = false
}

variable "create_read_replica" {
  description = "Create a read replica for the RDS instance"
  type        = bool
  default     = false
}

variable "read_replica_instance_class" {
  description = "Instance class for read replica"
  type        = string
  default     = "db.t3.micro"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
