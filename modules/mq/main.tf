resource "random_password" "mq_user_password" {
  length  = 24
  special = false
}

resource "aws_mq_broker" "mq_broker" {
  broker_name         = var.application
  engine_type         = var.engine_type
  deployment_mode     = var.deployment_mode
  engine_version      = var.engine_version
  host_instance_type  = var.instance_type
  security_groups     = [aws_security_group.mq_sg.id]
  publicly_accessible = var.publicly_accessible
  subnet_ids          = var.vpc_subnets
    user {
      username = var.username
      password = random_password.mq_user_password.result
  }

}

resource "aws_security_group" "mq_sg" {
  name        = "${var.application}-mq-sg"
  description = "Allow traffic to mq"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.application}-mq-sg"
    Environment = var.application
  }

  ingress {
    from_port   = 5671
    to_port     = 5671
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
