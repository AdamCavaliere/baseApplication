variable "environment" {
  description = "Environment - e.g. dev, stage prod"
  default     = "notSet"
}

variable "servercount" {
  description = "Number of servers"
  default     = "1"
}

variable "app_name" {
  description = "Name of application"
  default     = "notSet"
}
