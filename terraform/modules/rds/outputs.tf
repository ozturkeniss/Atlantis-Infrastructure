output "db_instance_address" {
  description = "RDS instance hostname"
  value       = aws_db_instance.main.address
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_availability_zone" {
  description = "RDS instance availability zone"
  value       = aws_db_instance.main.availability_zone
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_engine" {
  description = "RDS instance engine"
  value       = aws_db_instance.main.engine
}

output "db_instance_engine_version" {
  description = "RDS instance engine version"
  value       = aws_db_instance.main.engine_version
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_resource_id" {
  description = "RDS instance resource ID"
  value       = aws_db_instance.main.resource_id
}

output "db_instance_status" {
  description = "RDS instance status"
  value       = aws_db_instance.main.status
}

output "db_instance_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "RDS instance master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_ca_cert_identifier" {
  description = "RDS instance CA certificate identifier"
  value       = aws_db_instance.main.ca_cert_identifier
}

output "db_instance_domain" {
  description = "RDS instance domain"
  value       = aws_db_instance.main.domain
}

output "db_instance_domain_iam_role_name" {
  description = "RDS instance domain IAM role name"
  value       = aws_db_instance.main.domain_iam_role_name
}

# Security Group
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.rds.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.rds.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.rds.name
}

# DB Subnet Group
output "db_subnet_group_id" {
  description = "DB subnet group identifier"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "DB subnet group ARN"
  value       = aws_db_subnet_group.main.arn
}

# Parameter Group
output "db_parameter_group_id" {
  description = "DB parameter group identifier"
  value       = aws_db_parameter_group.main.id
}

output "db_parameter_group_arn" {
  description = "DB parameter group ARN"
  value       = aws_db_parameter_group.main.arn
}

# CloudWatch Log Group
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.postgresql.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.postgresql.arn
}

# Useful connection information
output "connection_string" {
  description = "PostgreSQL connection string"
  value       = local.connection_string
  sensitive   = true
}

output "jdbc_connection_string" {
  description = "JDBC connection string"
  value       = "jdbc:postgresql://${aws_db_instance.main.endpoint}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
}

# Enhanced monitoring role
output "enhanced_monitoring_iam_role_name" {
  description = "Enhanced monitoring IAM role name"
  value       = aws_iam_role.rds_enhanced_monitoring.name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "Enhanced monitoring IAM role ARN"
  value       = aws_iam_role.rds_enhanced_monitoring.arn
}
