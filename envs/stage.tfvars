# Staging Environment Configuration
# ⚠️ These are example values for demonstration purposes only

# Project Configuration
project_name = "atlas-micro"
environment  = "stage"
region       = "eu-west-1"

# Network Configuration
vpc_cidr             = "10.1.0.0/16"
availability_zones   = 2
enable_nat_gateway   = true
single_nat_gateway   = false  # Multiple NAT gateways for higher availability
enable_dns_hostnames = true
enable_dns_support   = true

# EKS Configuration
cluster_version                = "1.28"
cluster_endpoint_public_access = true
cluster_endpoint_private_access = true

# Node Group Configuration
node_instance_types = ["t3.large"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 6
node_disk_size      = 100

# Feature Toggles - Staging mirrors production with some optimizations
enable_rds         = true
enable_redis       = true
enable_msk         = false  # MSK typically disabled in staging due to cost
enable_bastion     = true

# RDS Configuration (when enabled)
db_engine          = "postgres"
db_engine_version  = "15.4"
db_instance_class  = "db.t3.small"
db_allocated_storage = 100
db_storage_encrypted = true
db_name            = "atlasdb"
db_username        = "atlas_user"
db_backup_retention_period = 7
db_backup_window          = "03:00-04:00"
db_maintenance_window     = "sun:04:00-sun:05:00"
db_skip_final_snapshot    = false

# Redis Configuration (when enabled)
redis_node_type              = "cache.t3.small"
redis_parameter_group_name   = "default.redis7"
redis_engine_version         = "7.0"
redis_num_cache_clusters     = 2
redis_port                   = 6379

# MSK Configuration (when enabled)
msk_kafka_version    = "3.5.1"
msk_instance_type    = "kafka.t3.small"
msk_ebs_volume_size  = 100

# Bastion Configuration (when enabled)
bastion_instance_type = "t3.small"
bastion_key_name      = "atlas-stage-key"

# Tags
common_tags = {
  Project     = "atlas-micro"
  Environment = "stage"
  ManagedBy   = "terraform"
  Owner       = "platform-team"
  CostCenter  = "engineering"
}
