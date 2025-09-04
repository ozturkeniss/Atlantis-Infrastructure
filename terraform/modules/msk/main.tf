# Amazon MSK (Managed Streaming for Apache Kafka) Module

# CloudWatch Log Group for MSK logs
resource "aws_cloudwatch_log_group" "msk" {
  name              = "/aws/msk/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-msk-logs"
  })
}

# Security Group for MSK
resource "aws_security_group" "msk" {
  name_prefix = "${var.project_name}-${var.environment}-msk-"
  vpc_id      = var.vpc_id
  description = "Security group for MSK cluster"

  # Kafka broker communication (plaintext)
  ingress {
    description     = "Kafka broker plaintext from EKS nodes"
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  # Kafka broker communication (TLS)
  ingress {
    description     = "Kafka broker TLS from EKS nodes"
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  # Kafka broker communication (SASL/SCRAM)
  ingress {
    description     = "Kafka broker SASL from EKS nodes"
    from_port       = 9096
    to_port         = 9096
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  # Zookeeper communication
  ingress {
    description     = "Zookeeper from EKS nodes"
    from_port       = 2181
    to_port         = 2181
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  # JMX monitoring
  ingress {
    description     = "JMX monitoring from EKS nodes"
    from_port       = 11001
    to_port         = 11002
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-msk-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# MSK Configuration
resource "aws_msk_configuration" "main" {
  kafka_versions = [var.kafka_version]
  name           = "${var.project_name}-${var.environment}-msk-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable=true
default.replication.factor=2
min.insync.replicas=2
num.partitions=8
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=false
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
PROPERTIES

  description = "MSK configuration for ${var.project_name} ${var.environment}"

  lifecycle {
    create_before_destroy = true
  }
}

# MSK Cluster
resource "aws_msk_cluster" "main" {
  cluster_name           = "${var.project_name}-${var.environment}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.instance_type
    ebs_volume_size = var.ebs_volume_size
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.msk.id]
  }

  configuration_info {
    arn      = aws_msk_configuration.main.arn
    revision = aws_msk_configuration.main.latest_revision
  }

  # Encryption settings
  encryption_info {
    encryption_at_rest_kms_key_id = aws_kms_key.msk.arn
    
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  # Enhanced monitoring
  enhanced_monitoring = "PER_TOPIC_PER_BROKER"

  # Open monitoring with Prometheus
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  # Logging
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk.name
      }
      firehose {
        enabled = false
      }
      s3 {
        enabled = false
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-msk"
  })

  depends_on = [aws_cloudwatch_log_group.msk]
}

# KMS Key for MSK encryption
resource "aws_kms_key" "msk" {
  description             = "KMS key for MSK cluster encryption"
  deletion_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-msk-kms"
  })
}

resource "aws_kms_alias" "msk" {
  name          = "alias/${var.project_name}-${var.environment}-msk"
  target_key_id = aws_kms_key.msk.key_id
}

# CloudWatch Alarms for MSK monitoring
resource "aws_cloudwatch_metric_alarm" "msk_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-msk-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CpuIdle"
  namespace           = "AWS/Kafka"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"  # Alert when CPU idle is less than 20% (high CPU usage)
  alarm_description   = "This metric monitors MSK CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-msk-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "msk_disk" {
  alarm_name          = "${var.project_name}-${var.environment}-msk-disk-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "KafkaDataLogsDiskUsed"
  namespace           = "AWS/Kafka"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"  # Alert when disk usage exceeds 80%
  alarm_description   = "This metric monitors MSK disk utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main.cluster_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-msk-disk-alarm"
  })
}

# Example of creating Kafka topics using terraform-provider-kafka
# Note: This requires the Kafka provider to be configured
# Uncomment if you want to manage topics via Terraform
/*
resource "kafka_topic" "user_events" {
  name               = "user-events"
  replication_factor = 2
  partitions         = 8

  config = {
    "cleanup.policy"                      = "delete"
    "delete.retention.ms"                 = "86400000"
    "segment.ms"                          = "604800000"
    "retention.ms"                        = "604800000"
  }
}

resource "kafka_topic" "order_events" {
  name               = "order-events"
  replication_factor = 2
  partitions         = 8

  config = {
    "cleanup.policy"                      = "delete"
    "delete.retention.ms"                 = "86400000"
    "segment.ms"                          = "604800000"
    "retention.ms"                        = "604800000"
  }
}

resource "kafka_topic" "system_metrics" {
  name               = "system-metrics"
  replication_factor = 2
  partitions         = 4

  config = {
    "cleanup.policy"                      = "delete"
    "delete.retention.ms"                 = "86400000"
    "segment.ms"                          = "86400000"
    "retention.ms"                        = "259200000"  # 3 days
  }
}
*/
