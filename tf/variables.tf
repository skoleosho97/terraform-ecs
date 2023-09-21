variable "region" {
    type        = string
    description = "Selected AWS region."
    default     = "us-east-1"
}

variable "project" {
    type        = string
    description = "Main prefix of the current project."
    default     = "skole-jenkins"   
}

variable "env" {
    type        = string
    description = "Environment of the project."
    default     = "production"   
}

variable "backend_services" {
    type = map(object({
        port = number
    }))
    description = "List of backend microservices."
    default = {
        gateway : { 
            port = 8080
        },
        underwriter : { 
            port = 8081
        },
        account : { 
            port = 8082
        },
        bank : { 
            port = 8083
        },
        transaction : { 
            port = 8085
        },
        user : { 
            port = 8086
        }      
    }
}

variable "all_services" {
    type = list(string)
    description = "List of all services."
    default = [
        "gateway", 
        "underwriter", 
        "account", 
        "bank", 
        "transaction", 
        "user", 
        "landing", 
        "dashboard", 
        "admin"
    ]
}
