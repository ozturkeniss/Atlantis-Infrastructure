# ElastiCache Redis Module

# Cache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis-subnet-group"
  })
}

# Security Group for Redis
resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-${var.environment}-redis-"
  vpc_id      = var.vpc_id
  description = "Security group for ElastiCache Redis"

  ingress {
    description     = "Redis from EKS nodes"
    from_port       = var.port
    to_port         = var.port
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
    Name = "${var.project_name}-${var.environment}-redis-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Parameter Group for Redis
resource "aws_elasticache_parameter_group" "main" {
  family = "redis7.x"
  name   = "${var.project_name}-${var.environment}-redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis7-params"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ElastiCache Replication Group
resource "aws_elasticache_replication_group" "main" {
  replication_group_id         = "${var.project_name}-${var.environment}-redis"
  description                  = "Redis cluster for ${var.project_name} ${var.environment}"
  
  node_type                    = var.node_type
  port                         = var.port
  parameter_group_name         = aws_elasticache_parameter_group.main.name
  
  num_cache_clusters           = var.num_cache_clusters
  automatic_failover_enabled   = var.automatic_failover_enabled
  multi_az_enabled            = var.multi_az_enabled
  
  subnet_group_name           = aws_elasticache_subnet_group.main.name
  security_group_ids          = [aws_security_group.redis.id]
  
  # Maintenance window (should not conflict with RDS)
  maintenance_window          = "tue:05:00-tue:06:00"
  
  # Snapshot configuration
  snapshot_retention_limit    = 5
  snapshot_window            = "05:00-06:00"
  
  # Engine configuration
  engine_version             = var.engine_version
  
  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  # Logging
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis"
  })

  lifecycle {
    prevent_destroy = false  # Set to true for production
  }
}

# CloudWatch Log Group for Redis slow logs
resource "aws_cloudwatch_log_group" "redis_slow" {
  name              = "/aws/elasticache/redis/${var.project_name}-${var.environment}/slow-log"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis-slow-logs"
  })
}

# CloudWatch Alarms for Redis monitoring
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-redis-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors redis cpu utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-redis-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors redis memory utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis-memory-alarm"
  })
}

# Example of creating additional cache clusters for different purposes
# Uncomment if you need separate Redis instances for different use cases
/*
resource "aws_elasticache_replication_group" "sessions" {
  replication_group_id         = "${var.project_name}-${var.environment}-redis-sessions"
  description                  = "Redis cluster for session storage"
  
  node_type                    = "cache.t3.micro"
  port                         = 6379
  parameter_group_name         = aws_elasticache_parameter_group.main.name
  
  num_cache_clusters           = 1
  automatic_failover_enabled   = false
  multi_az_enabled            = false
  
  subnet_group_name           = aws_elasticache_subnet_group.main.name
  security_group_ids          = [aws_security_group.redis.id]
  
  maintenance_window          = "tue:06:00-tue:07:00"
  snapshot_retention_limit    = 1
  
  engine_version             = var.engine_version
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis-sessions"
    Purpose = "session-storage"
  })
}
*/
