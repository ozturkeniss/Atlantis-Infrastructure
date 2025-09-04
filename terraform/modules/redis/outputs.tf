output "redis_replication_group_id" {
  description = "ID of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.id
}

output "redis_replication_group_arn" {
  description = "ARN of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.arn
}

output "redis_primary_endpoint" {
  description = "Primary endpoint for the Redis replication group"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint for the Redis replication group"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.main.port
}

output "redis_configuration_endpoint" {
  description = "Configuration endpoint for the Redis replication group"
  value       = aws_elasticache_replication_group.main.configuration_endpoint_address
}

# Security Group
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.redis.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.redis.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.redis.name
}

# Subnet Group
output "subnet_group_name" {
  description = "Cache subnet group name"
  value       = aws_elasticache_subnet_group.main.name
}

# Parameter Group
output "parameter_group_id" {
  description = "Cache parameter group identifier"
  value       = aws_elasticache_parameter_group.main.id
}

output "parameter_group_arn" {
  description = "Cache parameter group ARN"
  value       = aws_elasticache_parameter_group.main.arn
}

# CloudWatch Log Group
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for Redis slow logs"
  value       = aws_cloudwatch_log_group.redis_slow.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN for Redis slow logs"
  value       = aws_cloudwatch_log_group.redis_slow.arn
}

# Connection information
output "connection_string" {
  description = "Redis connection string"
  value       = "redis://${aws_elasticache_replication_group.main.primary_endpoint_address}:${aws_elasticache_replication_group.main.port}"
}

output "redis_url" {
  description = "Redis URL for application configuration"
  value       = "redis://${aws_elasticache_replication_group.main.primary_endpoint_address}:${aws_elasticache_replication_group.main.port}/0"
}

# Cluster information
output "cluster_enabled" {
  description = "Whether Redis cluster mode is enabled"
  value       = aws_elasticache_replication_group.main.cluster_enabled
}

output "num_cache_clusters" {
  description = "Number of cache clusters in the replication group"
  value       = aws_elasticache_replication_group.main.num_cache_clusters
}

output "member_clusters" {
  description = "List of cluster IDs that are part of this replication group"
  value       = aws_elasticache_replication_group.main.member_clusters
}

# Encryption information
output "at_rest_encryption_enabled" {
  description = "Whether encryption at rest is enabled"
  value       = aws_elasticache_replication_group.main.at_rest_encryption_enabled
}

output "transit_encryption_enabled" {
  description = "Whether encryption in transit is enabled"
  value       = aws_elasticache_replication_group.main.transit_encryption_enabled
}

# CloudWatch Alarms
output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.redis_cpu.arn
}

output "memory_alarm_arn" {
  description = "ARN of the memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.redis_memory.arn
}
