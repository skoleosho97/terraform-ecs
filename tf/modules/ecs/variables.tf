variable "exec_role_arn" {
    type        = string
    description = "ARN for task execution role."
}

variable "service_host" {
    type        = string
    description = "Hostname for service host."
}

variable "landing_dns" {
    type        = string
    description = "Hostname for landing portal."
}

variable "dashboard_dns" {
    type        = string
    description = "Hostname for member dashboard."
}

variable "admin_dns" {
    type        = string
    description = "Hostname for admin portal."
}

variable "backend_lb_sg_id" {
    type        = string
    description = "Security group for backend load balancer."
}

variable "landing_lb_sg_id" {
    type        = string
    description = "Security group for landing portal load balancer."
}

variable "dashboard_lb_sg_id" {
    type        = string
    description = "Security group for member dashboard load balancer."
}

variable "admin_lb_sg_id" {
    type        = string
    description = "Security group for admin portal load balancer."
}

variable "backend_tg" {
    type        = any
    description = "Target groups for backends."
}

variable "landing_tg_arn" {
    type        = string
    description = "Target group for landing portal."
}

variable "dashboard_tg_arn" {
    type        = string
    description = "Target group for member dashboard."
}

variable "admin_tg_arn" {
    type        = string
    description = "Target group for admin portal."
}

variable "vpc_id" {
    type        = string
    description = "Environment of the project."
}

variable "public_subnets" {
    type        = list(string)
    description = "List of public subnets."
}

variable "project" {
    type        = string
    description = "Main prefix of the current project."
}

variable "env" {
    type        = string
    description = "Environment of the project."
}

variable "backend_services" {
    type = map(object({ 
        port = number 
    }))
    description = "List of backend microservices."
}

variable "all_services" {
    type        = list(string)
    description = "List of all services."
}

variable "backend_env" {
    type = list(object({
        name    = string
        value   = string
    }))
    description = "Environment variables for backends."
    default = [
        {
            name = "SPRING_DATASOURCE_USERNAME"
            value = "root"
        },
        {
            name = "SPRING_DATASOURCE_PASSWORD"
            value = "Liella1997!"
        },
        {
            name = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://skoleosho-rds.cwuutkrrh33s.us-east-1.rds.amazonaws.com:3306/aline?allowPublicKeyRetrieval=true&useSSL=false"
        },
        {
            name = "SECRET_KEY"
            value = "1234567890123456"
        },
        {
            name = "JWT_SECRET_KEY"
            value = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        }       
    ]
}