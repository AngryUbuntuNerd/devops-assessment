variable "name" {
  type = string
  description = "Name of this service"
}

variable "cpu" {
  type = number
  description = "Amount of CPU units to assign each task (1024 = 1vCPU)"
}

variable "memory" {
  type = number
  description = "Amount of RAM to assign each task (MiB)"
}

variable "container_port" {
  type = number
  description = "Container port to expose to the world"
}

variable "tasks" {
  type = number
  description = "Number of tasks to provide"
}

variable "health_check_url" {
  type = string
  description = "Endpoint to use for health checks (should return non-200 on problems)"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}
