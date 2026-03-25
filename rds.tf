# --------------------------------------------------------------------------
# rds.tf — PostgreSQL RDS instance in the private subnet
# --------------------------------------------------------------------------

# ---- DB Subnet Group (requires subnets in >= 2 AZs) --------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = { Name = "${var.project_name}-db-subnet-group" }
}

# ---- RDS Instance -------------------------------------------------------
resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-postgres"
  engine         = "postgres"
  engine_version = "15"

  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Security: not publicly accessible — only reachable from the VPC
  publicly_accessible = false
  multi_az            = false
  skip_final_snapshot = true

  backup_retention_period = 7

  tags = { Name = "${var.project_name}-postgres" }
}
