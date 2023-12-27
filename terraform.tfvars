## Application configurations
account      = 385892239032
region       = "us-east-1"
app_name     = "testing"
env          = "dev"
hosted_zone = "kisialeu.com"
certificate_arn = "arn:aws:acm:us-east-1:385892239032:certificate/77635d1d-799e-47a2-b80b-dc6143d9a598"

app_services = ["public", "backend", "worker"]

#VPC configurations
cidr               = "10.10.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.10.50.0/24", "10.10.51.0/24"]
private_subnets    = ["10.10.0.0/24", "10.10.1.0/24"]

#Internal ALB configurations
internal_alb_config = {
  name      = "Internal-Alb"
  listeners = {
    "HTTP" = {
      listener_port     = 80
      listener_protocol = "HTTP"

    }
  }

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["10.10.0.0/16"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["10.10.0.0/16"]
    }
  ]
}

#Friendly url name for internal load balancer DNS
internal_url_name = "service.internal"

#Public ALB configurations
external_alb_config = {
  name      = "Public-Alb"
  listeners = {
    "HTTP" = {
      listener_port     = 80
      listener_protocol = "HTTP"

    }
  }

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
#storages
storage = {
  name = "storage"
  s3_buckets = {
    assets = {
      name   = "assets"
      prefix = "htask"
      lifecycle_rules = [
        {
          rule_name       = "prunedimages"
          expiration_days = 30
          prefix          = "pruned-images/"
        }
      ]
    },
    twin_assets = {
      name   = "twin-assets"
      prefix = "htask"
    },
    analytics = {
      name   = "analytics"
      prefix = "htask"
    }
  }
}


#Microservices
microservice_config = {
  "public" = {
    name             = "public"
    is_public        = true
    container_port   = 80
    host_port        = 80
    cpu              = 256
    memory           = 512
    desired_count    = 1
    alb_target_group = {
      port              = 80
      protocol          = "HTTP"
      path_pattern      = ["/*"]
      health_check_path = "/health"
      priority          = 1
    }
    auto_scaling = {
      max_capacity = 2
      min_capacity = 1
      cpu          = {
        target_value = 75
      }
      memory = {
        target_value = 75
      }
    }
  },
  "backend" = {
    name             = "backend"
    is_public        = false
    container_port   = 3000
    host_port        = 3000
    cpu              = 256
    memory           = 512
    desired_count    = 1
    alb_target_group = {
      port              = 3000
      protocol          = "HTTP"
      path_pattern      = ["/customer*"]
      health_check_path = "/health"
      priority          = 1
    }
    auto_scaling = {
      max_capacity = 2
      min_capacity = 1
      cpu          = {
        target_value = 75
      }
      memory = {
        target_value = 75
      }
    }
  },
  "worker" = {
    name             = "worker"
    is_public        = false
    container_port   = 80
    host_port        = 3000
    cpu              = 256
    memory           = 512
    desired_count    = 1
    alb_target_group = {
      port              = 3000
      protocol          = "HTTP"
      path_pattern      = ["/transaction*"]
      health_check_path = "/health"
      priority          = 1
    }
    auto_scaling = {
      max_capacity = 2
      min_capacity = 1
      cpu          = {
        target_value = 75
      }
      memory = {
        target_value = 75
      }
    }
  }
}

cloudfront_distributions = {
    admin = {
      enable_lambda_edge = false
    }
    public-assets = {
      enable_lambda_edge = false
    }
  }
