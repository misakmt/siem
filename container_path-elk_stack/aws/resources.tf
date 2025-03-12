resource "aws_ecs_cluster" "elk_cluster" {
  name = "elk-cluster"
}

resource "aws_ecr_repository" "elasticsearch_repo" {
  name = "elasticsearch"
}

resource "aws_ecs_task_definition" "elasticsearch_task" {
  family                   = "elasticsearch"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "elasticsearch"
      image = "${aws_ecr_repository.elasticsearch_repo.repository_url}:latest"
      cpu   = 1024
      memory = 2048
      environment = [{ "name": "discovery.type", "value": "single-node" }]
      portMappings = [{ containerPort = 9200 }]
    }
  ])
}

resource "aws_ecs_service" "elasticsearch_service" {
  name            = "elasticsearch-service"
  cluster        = aws_ecs_cluster.elk_cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = [aws_subnet.elk_public_subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
