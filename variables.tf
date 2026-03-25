# --------------------------------------------------------------------------
# variables.tf — All input variable declarations
# --------------------------------------------------------------------------

# ---- General -------------------------------------------------------------
variable "project_name" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "iac-lab"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

# ---- Networking ----------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for the first private subnet (AZ-a)"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for the second private subnet (AZ-b)"
  type        = string
  default     = "10.0.11.0/24"
}

# ---- EC2 -----------------------------------------------------------------
variable "ec2_instance_type" {
  description = "Instance type for the web servers"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into EC2 (set to your IP/32)"
  type        = string
  default     = "0.0.0.0/0"
}

# ---- RDS -----------------------------------------------------------------
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the initial PostgreSQL database"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the RDS instance (min 8 chars)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "The database password must be at least 8 characters long."
  }
}
