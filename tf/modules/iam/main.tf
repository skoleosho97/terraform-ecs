data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

locals {
    name = "skole-jenkins"
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name                = "${local.name}-task-execution-role"
    assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy" {
    role        = aws_iam_role.ecs_task_execution_role.name
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}