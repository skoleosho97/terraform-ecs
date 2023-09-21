resource "aws_security_group" "backend_lb_sg" {
    vpc_id      = var.vpc_id
    description = "Security group for Jenkins pipeline backend services."

    dynamic "ingress" {
        for_each = var.backend_services

        content {
            from_port       = ingress.value.port
            to_port         = ingress.value.port
            protocol        = "tcp"
            cidr_blocks     = ["0.0.0.0/0"]            
        }
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]       
    }
}

resource "aws_lb" "backend_lb" {
    name                = "${var.project}-backend-lb"
    subnets             = var.public_subnets
    security_groups     = [aws_security_group.backend_lb_sg.id]
    internal            = false
    load_balancer_type  = "application"

    tags = {
        Name        = "${var.project}-backend-lb"
        Environment = var.env
    }
}

resource "aws_security_group" "landing_lb_sg" {
    vpc_id      = var.vpc_id
    description = "Security group for Jenkins pipeline landing portal."

    ingress {
        from_port       = 4000
        to_port         = 4000
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]            
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]       
    }
}

resource "aws_lb" "landing_lb" {
    name                = "${var.project}-landing-lb"
    subnets             = var.public_subnets
    security_groups     = [aws_security_group.landing_lb_sg.id]
    internal            = false
    load_balancer_type  = "application"

    tags = {
        Name        = "${var.project}-landing-lb"
        Environment = var.env
    }
}

resource "aws_security_group" "dashboard_lb_sg" {
    vpc_id      = var.vpc_id
    description = "Security group for Jenkins pipeline member dashboard."

    ingress {
        from_port       = 4200
        to_port         = 4200
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]            
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]       
    }
}

resource "aws_lb" "dashboard_lb" {
    name                = "${var.project}-dashboard-lb"
    subnets             = var.public_subnets
    security_groups     = [aws_security_group.dashboard_lb_sg.id]
    internal            = false
    load_balancer_type  = "application"

    tags = {
        Name        = "${var.project}-dashboard-lb"
        Environment = var.env
    }
}

resource "aws_security_group" "admin_lb_sg" {
    vpc_id      = var.vpc_id
    description = "Security group for Jenkins pipeline admin portal."

    ingress {
        from_port       = 4001
        to_port         = 4001
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]            
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]       
    }
}

resource "aws_lb" "admin_lb" {
    name                = "${var.project}-admin-lb"
    subnets             = var.public_subnets
    security_groups     = [aws_security_group.admin_lb_sg.id]
    internal            = false
    load_balancer_type  = "application"

    tags = {
        Name        = "${var.project}-admin-lb"
        Environment = var.env
    }
}

resource "aws_lb_target_group" "backend_tg" {
    for_each = var.backend_services

    name = "${each.key}-tg"
    port = each.value.port
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
        healthy_threshold   = 3
        unhealthy_threshold = 2
        interval            = 30
        protocol            = "HTTP"
        matcher             = "200-499"
        timeout             = 3
        path                = "/health"
    }

    tags = {
        Name        = "${var.project}-${each.key}-tg"
        Environment = var.env
    }
}

resource "aws_lb_listener" "backend_listener" {
    for_each = var.backend_services

    load_balancer_arn   = aws_lb.backend_lb.arn
    port                = each.value.port
    protocol            = "HTTP"

    default_action {
        type                = "forward"
        target_group_arn    = aws_lb_target_group.backend_tg[each.key].arn
    }    
}

resource "aws_lb_target_group" "landing_tg" {
    name        = "landing-tg"
    port        = 4000
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    tags = {
        Name        = "${var.project}-landing-tg"
        Environment = var.env
    }
}

resource "aws_lb_listener" "landing_listener" {
    load_balancer_arn = aws_lb.landing_lb.arn
    port = "4000"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.landing_tg.arn
    }
}

resource "aws_lb_target_group" "admin_tg" {
    name        = "admin-tg"
    port        = 4001
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    tags = {
        Name        = "${var.project}-admin-tg"
        Environment = var.env
    }
}

resource "aws_lb_listener" "admin_listener" {
    load_balancer_arn = aws_lb.admin_lb.arn
    port = "4001"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.admin_tg.arn
    }
}

resource "aws_lb_target_group" "dashboard_tg" {
    name        = "dashboard-tg"
    port        = 4200
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    tags = {
        Name        = "${var.project}-dashboard-tg"
        Environment = var.env
    }
}

resource "aws_lb_listener" "dashboard_listener" {
    load_balancer_arn = aws_lb.dashboard_lb.arn
    port = "4200"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.dashboard_tg.arn
    }
}
