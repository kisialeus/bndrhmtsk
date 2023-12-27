resource "random_password" "redis_password" {
  count   = var.auth_token_enabled ? 1 : 0
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "redis_password_secret" {
  count = var.auth_token_enabled ? 1 : 0
  name  = "${var.application}/redis-password"
}
resource "aws_secretsmanager_secret_version" "redis_password_secret" {
  count         = var.auth_token_enabled ? 1 : 0
  secret_id     = aws_secretsmanager_secret.redis_password_secret[0].id
  secret_string = random_password.redis_password[0].result
}


resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.application}-redis-subg"
  subnet_ids = var.vpc_subnets
}

resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name   = "${var.application}-redis-pg"
  family = "redis${var.redis_engine_version}"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

resource "aws_elasticache_replication_group" "redis" {

  replication_group_id          = "${var.application}-redis-cluster"
  replication_group_description = "${var.application} redis cluster"
  engine_version                = var.redis_engine_version
  node_type                     = var.redis_node_type
#  num_cache_clusters            = var.cluster_size
  parameter_group_name          = aws_elasticache_parameter_group.redis_parameter_group.id
  multi_az_enabled              = var.multi_az_enabled
  automatic_failover_enabled    = var.automatic_failover_enabled
  apply_immediately             = var.apply_immediately
  transit_encryption_enabled    = var.transit_encryption_enabled
  auth_token                    = var.auth_token_enabled ? random_password.redis_password[0].result : null
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids            = [aws_security_group.redis_sg.id]

  snapshot_retention_limit  = var.snapshot_retention_limit
  final_snapshot_identifier = "${var.application}-redis-final-snapshot"
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.application}-redis-sg"
  description = "Allow traffic to ${var.application} redis cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.application}-redis-sg"
    Environment = var.application
  }
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.security_groups.security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

