output "cluster_arn" {
  description = "ARN of the MSK cluster"
  value       = aws_msk_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the MSK cluster"
  value       = aws_msk_cluster.main.cluster_name
}

output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_scram" {
  description = "SASL/SCRAM connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers_sasl_scram
}

output "bootstrap_brokers_sasl_iam" {
  description = "SASL/IAM connection host:port pairs"
  value       = aws_msk_cluster.main.bootstrap_brokers_sasl_iam
}

output "zookeeper_connect_string" {
  description = "A comma separated list of one or more hostname:port pairs to connect to the Apache Zookeeper cluster"
  value       = aws_msk_cluster.main.zookeeper_connect_string
}

output "kafka_version" {
  description = "The current version of the MSK cluster"
  value       = aws_msk_cluster.main.kafka_version
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates"
  value       = aws_msk_cluster.main.current_version
}

# Security Group
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.msk.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.msk.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.msk.name
}

# Configuration
output "configuration_arn" {
  description = "ARN of the MSK configuration"
  value       = aws_msk_configuration.main.arn
}

output "configuration_latest_revision" {
  description = "Latest revision of the MSK configuration"
  value       = aws_msk_configuration.main.latest_revision
}

# KMS Key
output "kms_key_id" {
  description = "The ID of the KMS key used for encryption"
  value       = aws_kms_key.msk.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = aws_kms_key.msk.arn
}

# CloudWatch Log Group
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for MSK"
  value       = aws_cloudwatch_log_group.msk.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN for MSK"
  value       = aws_cloudwatch_log_group.msk.arn
}

# CloudWatch Alarms
output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.msk_cpu.arn
}

output "disk_alarm_arn" {
  description = "ARN of the disk utilization alarm"
  value       = aws_cloudwatch_metric_alarm.msk_disk.arn
}

# Connection strings for different protocols
output "connection_strings" {
  description = "Connection strings for different protocols"
  value = {
    plaintext   = aws_msk_cluster.main.bootstrap_brokers
    tls         = aws_msk_cluster.main.bootstrap_brokers_tls
    sasl_scram  = aws_msk_cluster.main.bootstrap_brokers_sasl_scram
    sasl_iam    = aws_msk_cluster.main.bootstrap_brokers_sasl_iam
  }
}

# Useful commands for Kafka operations
output "kafka_commands" {
  description = "Useful Kafka commands for cluster management"
  value = {
    list_topics = "kafka-topics.sh --list --bootstrap-server ${aws_msk_cluster.main.bootstrap_brokers_tls}"
    create_topic = "kafka-topics.sh --create --topic my-topic --bootstrap-server ${aws_msk_cluster.main.bootstrap_brokers_tls} --partitions 3 --replication-factor 2"
    describe_cluster = "kafka-broker-api-versions.sh --bootstrap-server ${aws_msk_cluster.main.bootstrap_brokers_tls}"
    consumer_groups = "kafka-consumer-groups.sh --list --bootstrap-server ${aws_msk_cluster.main.bootstrap_brokers_tls}"
    producer_test = "kafka-console-producer.sh --bootstrap-server ${aws_msk_cluster.main.bootstrap_brokers_tls} --topic test-topic"
    consumer_test = "kafka-console-consumer.sh --bootstrap-server ${aws_msk_cluster.main.bootstrap_brokers_tls} --topic test-topic --from-beginning"
  }
}
