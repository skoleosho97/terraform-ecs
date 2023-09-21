resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.project}-cluster"
}

resource "aws_cloudwatch_log_group" "log-group" {
    for_each = toset(var.all_services)

    name = "${each.value}-log-group"
}

resource "aws_ecs_task_definition" "backend_task" {
    for_each = var.backend_services

    family                      = "${each.key}-task"
    requires_compatibilities    = ["FARGATE"]
    network_mode                = "awsvpc"
    memory                      = "1024"
    cpu                         = "512"
    execution_role_arn          = var.exec_role_arn

    container_definitions = jsonencode([
        {
            name = each.key
            image = each.key == "gateway" ? "200407870575.dkr.ecr.us-east-1.amazonaws.com/skoleosho/gateway:latest" : "200407870575.dkr.ecr.us-east-1.amazonaws.com/skoleosho/${each.key}-microservice:latest"
            essential = true
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = "${each.key}-log-group"
                    awslogs-region = "us-east-1"
                    awslogs-stream-prefix = var.project
                }
            }
            portMappings = [
                {
                    containerPort = each.value.port
                    hostPort = each.value.port
                }
            ]
            cpu = 512
            memory = 1024
            environment = each.key != "gateway" ? var.backend_env : [
                    {
                        name = "APP_SERVICE_HOST"
                        value = var.service_host
                    },
                    {
                        name = "PORTAL_LANDING"
                        value = "http://${var.landing_dns}:4000"
                    },
                    {
                        name = "PORTAL_DASHBOARD"
                        value = "http://${var.dashboard_dns}:4200"
                    },
                    {
                        name = "PORTAL_ADMIN"
                        value = "http://${var.admin_dns}:4001"
                    }
            ]
        }
    ])
}

resource "aws_ecs_task_definition" "landing_task" {
    family                      = "landing-family"
    requires_compatibilities    = ["FARGATE"]
    network_mode                = "awsvpc"
    memory                      = "1024"
    cpu                         = "512"
    execution_role_arn          = var.exec_role_arn

    container_definitions = jsonencode([
        {
            name = "landing"
            image = "200407870575.dkr.ecr.us-east-1.amazonaws.com/skoleosho/landing-portal:latest"
            essential = true
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = "landing-log-group"
                    awslogs-region = "us-east-1"
                    awslogs-stream-prefix = var.project
                }
            }
            portMappings = [
                {
                    containerPort = 4000
                    hostPort = 4000
                }
            ]
            cpu = 512
            memory = 1024
            environment = [
                {
                    name = "REACT_APP_MEMBER_DASHBOARD_URL"
                    value = "http://${var.dashboard_dns}:4200"
                },
                {
                    name = "REACT_APP_API"
                    value = "http://${var.service_host}/api"
                }
            ]
        }
    ])
}

resource "aws_ecs_task_definition" "dashboard_task" {
    family                      = "dashboard-family"
    requires_compatibilities    = ["FARGATE"]
    network_mode                = "awsvpc"
    memory                      = "1024"
    cpu                         = "512"
    execution_role_arn          = var.exec_role_arn

    container_definitions = jsonencode([
        {
            name = "dashboard"
            image = "200407870575.dkr.ecr.us-east-1.amazonaws.com/skoleosho/member-dashboard:latest"
            essential = true
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = "dashboard-log-group"
                    awslogs-region = "us-east-1"
                    awslogs-stream-prefix = var.project
                }
            }
            portMappings = [
                {
                    containerPort = 4200
                    hostPort = 4200
                }
            ]
            cpu = 512
            memory = 1024
            environment = [
                {
                    name = "APP_SERVICE_PORT"
                    value = var.service_host
                },
                {
                    name = "REACT_APP_API_URL"
                    value = "http://${var.service_host}/api"
                },
                {
                    name = "LANDING_PORTAL"
                    value = "http://${var.landing_dns}:4000"
                }
            ]
        }
    ])
}

resource "aws_ecs_task_definition" "admin_task" {
    family                      = "admin-family"
    requires_compatibilities    = ["FARGATE"]
    network_mode                = "awsvpc"
    memory                      = "1024"
    cpu                         = "512"
    execution_role_arn          = var.exec_role_arn

    container_definitions = jsonencode([
        {
            name = "admin"
            image = "200407870575.dkr.ecr.us-east-1.amazonaws.com/skoleosho/admin-portal:latest"
            essential = true
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = "admin-log-group"
                    awslogs-region = "us-east-1"
                    awslogs-stream-prefix = var.project
                }
            }
            portMappings = [
                {
                    containerPort = 4001
                    hostPort = 4001
                }
            ]
            cpu = 512
            memory = 1024
            environment = [
                {
                    name = "REACT_APP_API_BASEURL"
                    value = "http://${var.service_host}:8080"
                },
                {
                    name = "REACT_APP_TOKEN_NAME"
                    value = "jwtToken"
                }
            ]
        }
    ])
}

resource "aws_ecs_service" "backend_service" {
    for_each = var.backend_services

    name = "${each.key}-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.backend_task[each.key].arn
    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        subnets             = var.public_subnets
        assign_public_ip    = true
        security_groups     = [
            aws_security_group.service-security-group.id,
            var.backend_lb_sg_id
        ]
    }

    load_balancer {
        target_group_arn = var.backend_tg[each.key].arn
        container_name = each.key
        container_port = each.value.port
    }
}

resource "aws_ecs_service" "landing_service" {
    name = "landing-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.landing_task.arn
    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        subnets             = var.public_subnets
        assign_public_ip    = true
        security_groups     = [
            aws_security_group.service-security-group.id,
            var.landing_lb_sg_id
        ]
    }

    load_balancer {
        target_group_arn = var.landing_tg_arn
        container_name = "landing"
        container_port = "4000"
    }
}

resource "aws_ecs_service" "dashboard_service" {
    name = "dashboard-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.dashboard_task.arn
    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        subnets             = var.public_subnets
        assign_public_ip    = true
        security_groups     = [
            aws_security_group.service-security-group.id,
            var.dashboard_lb_sg_id
        ]
    }

    load_balancer {
        target_group_arn = var.dashboard_tg_arn
        container_name = "dashboard"
        container_port = "4200"
    }
}

resource "aws_ecs_service" "admin_service" {
    name = "admin-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.admin_task.arn
    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        subnets             = var.public_subnets
        assign_public_ip    = true
        security_groups     = [
            aws_security_group.service-security-group.id,
            var.admin_lb_sg_id
        ]
    }

    load_balancer {
        target_group_arn = var.admin_tg_arn
        container_name = "admin"
        container_port = "4001"
    }
}

resource "aws_security_group" "service-security-group" {
    vpc_id = var.vpc_id

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = [var.backend_lb_sg_id]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"] 
    }

    tags = {
        Name        = "${var.project}-service-sg"
        Environment = var.env
    }
}