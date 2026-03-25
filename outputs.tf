# --------------------------------------------------------------------------
# outputs.tf — Useful information printed after apply
# --------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "ec2_public_ips" {
  description = "Public IP addresses of the web servers"
  value       = aws_instance.web[*].public_ip
}

output "ec2_instance_ids" {
  description = "Instance IDs of the web servers"
  value       = aws_instance.web[*].id
}

output "rds_endpoint" {
  description = "RDS connection endpoint (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_database_name" {
  description = "Name of the PostgreSQL database"
  value       = aws_db_instance.postgres.db_name
}

output "ssh_command_web1" {
  description = "SSH command for web server 1"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.web[0].public_ip}"
}

output "ssh_command_web2" {
  description = "SSH command for web server 2"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.web[1].public_ip}"
}

output "rds_test_command" {
  description = "Command to test RDS connectivity from an EC2 instance"
  value       = "psql -h ${aws_db_instance.postgres.address} -U ${var.db_username} -d ${var.db_name}"
  sensitive   = false
}
