provider "aws" {}

resource "aws_ecr_repository" "main" {
  name = var.name

//  # TODO: normally, we would want this, but for a test it can be annoying
//  lifecycle {
//    prevent_destroy = true
//  }
}

resource "aws_cloudwatch_log_group" "main" {
  name = format("/aws/ecs/%s", var.name)

//  # TODO: normally, we would want this, but for a test it can be annoying
//  lifecycle {
//    prevent_destroy = true
//  }
}

resource "aws_ecs_task_definition" "main" {
  family = var.name
  cpu = var.cpu
  memory = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name = "webserver",
    image = aws_ecr_repository.main.repository_url
    portMappings = [
      {
        containerPort = var.container_port
      }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.main.name
        awslogs-region = data.aws_region.current.name
        awslogs-stream-prefix = "webserver"
      }
    }
  }])

  tags = {
    timestamp = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_lb" "main" {
  name = var.name
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.http_lb.id]
  subnets = aws_subnet.public.*.id
}

resource "aws_lb_target_group" "main" {
  name = var.name
  port = 80
  protocol = "HTTP"
  vpc_id = aws_lb.main.vpc_id
  target_type = "ip"

  health_check {
    path = var.health_check_url
  }
}

# TODO: with a proper domain we should use HTTPS here
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port = 80

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_ecs_service" "main" {
  name = var.name
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count = var.tasks
  launch_type = "FARGATE"

  network_configuration {
    subnets = aws_subnet.private.*.id
    security_groups = [aws_security_group.http_lb_target.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name = "webserver"
    container_port = var.container_port
  }
}
