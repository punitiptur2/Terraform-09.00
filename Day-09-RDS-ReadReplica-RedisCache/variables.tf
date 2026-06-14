variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to prefix all resources."
  type        = string
  default     = "terrafrom-practice"
}

variable "environment" {
  description = "Environment label such as dev, stage, or prod."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Extra tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs across multiple AZs."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnets are required for multi-AZ RDS and Redis."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach RDS and Redis. Defaults to the VPC CIDR."
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for RDS."
  type        = string
  default     = "admin"
}

variable "db_engine_version" {
  description = "MySQL engine version for the primary RDS instance."
  type        = string
  default     = "8.0"
}

variable "db_parameter_group_family" {
  description = "Parameter group family for the RDS primary."
  type        = string
  default     = "mysql8.0"
}

variable "db_instance_class" {
  description = "Instance class for the primary RDS instance."
  type        = string
  default     = "db.t3.medium"
}

variable "db_replica_instance_class" {
  description = "Instance class for the RDS read replica."
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB for the primary RDS instance."
  type        = number
  default     = 100
}

variable "db_backup_window" {
  description = "Preferred daily backup window."
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Preferred weekly maintenance window."
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "redis_engine_version" {
  description = "Redis engine version for ElastiCache."
  type        = string
  default     = "7.1"
}

variable "redis_parameter_group_family" {
  description = "Parameter group family for Redis."
  type        = string
  default     = "redis7"
}

variable "redis_node_type" {
  description = "Node type for ElastiCache Redis."
  type        = string
  default     = "cache.t3.small"
}

variable "redis_snapshot_window" {
  description = "Preferred daily snapshot window for Redis."
  type        = string
  default     = "05:00-06:00"
}

variable "redis_maintenance_window" {
  description = "Preferred weekly maintenance window for Redis."
  type        = string
  default     = "sun:06:00-sun:07:00"
}