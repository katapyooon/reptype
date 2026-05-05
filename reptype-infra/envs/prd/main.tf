module "ecr" {
  source = "../../modules/ecr"

  repositories = {
    "nginx-reptype" = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = false
    }
    "rails-reptype" = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = false
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  cidr_block = "10.0.0.0/16" # 実際のVPCのCIDRに変更してください
}

module "ecs" {
  source = "../../modules/ecs"

  cluster_name = "reptype-cluster"
  service_name = "reptype-service"
  task_family  = "reptype-task"
  task_cpu     = "256"
  task_memory  = "512"

  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskRole"

  container_definitions = jsonencode([
    {
      name      = "rails"
      image     = "${module.ecr.repository_urls["rails-reptype"]}:latest"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
          name          = "rails-3000-tcp"
          appProtocol   = "http"
        }
      ]
      secrets = [
        { name = "DB_HOST", valueFrom = "arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.current.account_id}:parameter/reptype/DB_HOST" },
        { name = "DB_PASSWORD", valueFrom = "arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.current.account_id}:parameter/reptype/DB_PASSWORD" },
        { name = "RAILS_MASTER_KEY", valueFrom = "arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.current.account_id}:parameter/reptype/RAILS_MASTER_KEY" },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/reptype-task"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment    = []
      mountPoints    = []
      volumesFrom    = []
      systemControls = []
    },
    {
      name      = "nginx"
      image     = "${module.ecr.repository_urls["nginx-reptype"]}:latest"
      cpu       = 0
      essential = false
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          name          = "nginx-80-tcp"
        }
      ]
      volumesFrom = [
        { sourceContainer = "rails", readOnly = false }
      ]
      readonlyRootFilesystem = false
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/reptype-task"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment    = []
      mountPoints    = []
      systemControls = []
    }
  ])

  desired_count    = 1
  subnet_ids       = ["subnet-0bfed06307e7a730e"]
  security_group_ids = ["sg-027a10a08ba4e1490"]
  assign_public_ip = true

  target_group_arn             = "arn:aws:elasticloadbalancing:ap-northeast-1:${data.aws_caller_identity.current.account_id}:targetgroup/reptype-target/9edb6e53970b306a"
  load_balancer_container_name = "nginx"
  load_balancer_container_port = 80

  capacity_provider        = "FARGATE_SPOT"
  capacity_provider_weight = 100
  platform_version         = "1.4.0"
}

module "rds" {
  source = "../../modules/rds"

  db_identifier            = "reptype-db"
  engine                   = "postgres"
  engine_version           = "17.4"
  instance_class           = "db.t3.micro" # 実際のインスタンスクラスに変更してください
  allocated_storage        = 20            # 実際のストレージ容量に変更してください
  max_allocated_storage    = 1000
  storage_encrypted        = true
  username                 = "postgres"
  subnet_group_name        = "reptype_rds_subnet_group"
  subnet_group_description = "reptype_rds_subnet_group"
  subnet_ids = [
    "subnet-00ae5782d26d656f4",
    "subnet-056b348ce9ae77302",
  ]
  vpc_security_group_ids = ["sg-057c2d32abb9fba70"]
  multi_az               = false
  deletion_protection    = false
  copy_tags_to_snapshot  = true
  enabled_cloudwatch_logs_exports = [
    "iam-db-auth-error",
    "postgresql",
    "upgrade",
  ]
}
