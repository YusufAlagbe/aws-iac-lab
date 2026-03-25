# --------------------------------------------------------------------------
# ec2.tf — Two web/app server instances in the public subnet
# --------------------------------------------------------------------------

# ---- Look up the latest Amazon Linux 2023 AMI --------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ---- User-data script (bonus: installs PostgreSQL client) ---------------
locals {
  user_data = <<-USERDATA
    #!/bin/bash
    set -euo pipefail

    # Update packages
    dnf update -y

    # Install PostgreSQL 15 client for RDS connectivity testing
    dnf install -y postgresql15

    # Install a lightweight web server to prove HTTP works
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd

    # Drop a simple health-check page (IMDSv2-compatible)
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)
    cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html><body>
      <h1>AWS IaC Lab</h1>
      <p>Instance: $INSTANCE_ID</p>
      <p>Status: healthy</p>
    </body></html>
    HTML
  USERDATA
}

# ---- EC2 Instances ------------------------------------------------------
resource "aws_instance" "web" {
  count = 2

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = local.user_data

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required" # IMDSv2 only — security best practice
    http_endpoint = "enabled"
  }

  tags = { Name = "${var.project_name}-web-${count.index + 1}" }
}
