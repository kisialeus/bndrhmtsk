resource "random_password" "rds_user_password" {
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.application}-subnet-group"
  subnet_ids = var.vpc_subnets

  tags = {
    Name = "${var.application}-subnet-group"
    Environment = var.application
  }
}

resource "aws_rds_cluster_instance" "rds_cluster_instances" {
  identifier          = "${var.application}-node"
  cluster_identifier  = aws_rds_cluster.rds_cluster.id
  instance_class      = var.instance_type
  publicly_accessible = var.publicly_accessible
  engine              = aws_rds_cluster.rds_cluster.engine
  engine_version      = aws_rds_cluster.rds_cluster.engine_version
}
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier      = "${var.application}-cluter"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = var.engine_version
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  availability_zones      = [
    "${var.region}a",
    "${var.region}b",
    "${var.region}c"
  ]
  final_snapshot_identifier = "${var.application}-rds-cluter-final-snapshot"

  database_name           = var.application
  master_username         = "postgres"
  master_password         = random_password.rds_user_password.result
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.application}-rds-cluster-sg"
  description = "Allow traffic to rds cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.application}-rds-cluster-sg"
    Environment = var.application
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.security_groups.security_group_id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_ssm_parameter" "ssm_rds_cluster_host" {
  name  = "/${var.application}/postgres/host"
  value = aws_rds_cluster.rds_cluster.endpoint
  type  = "String"
}
