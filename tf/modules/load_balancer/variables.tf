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

variable "vpc_id" {
    type        = string
    description = "Environment of the project."
}

variable "public_subnets" {
    type        = list(string)
    description = "List of public subnets."
}