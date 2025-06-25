variable "db_username" {
    description = "Username for the MySQL RDS instance"
    type        = string
    default     = "admin"
}

variable "db_password" {
    description = "Password for the MySQL RDS instance"
    type        = string
    default     = "password123" # Change this to a secure password
    sensitive   = true
}