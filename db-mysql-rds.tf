resource "aws_db_subnet_group" "mysql_rds_subnet_group" {
  name       = "tf-aws-test-mysql-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name      = "TF-AWS-Test-MySQL-RDS-Subnet-Group"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "mysql_rds_sg" {
  name        = "tf-aws-test-mysql-rds-sg"
  description = "Security group for MySQL RDS instance"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "random_password" "mysql_rds_password" {
  length  = 16
  special = true
  override_special = "!@#$%^&*()_+"
}

resource "aws_secretsmanager_secret" "mysql_rds_secret" {
  name        = "tf-aws-test-mysql-rds-secret"
  description = "MySQL RDS instance credentials"
  recovery_window_in_days = 7

  tags = {
    Name      = "TF-AWS-Test-MySQL-RDS-Secret"
    ManagedBy = "Terraform"
  }
}


resource "aws_secretsmanager_secret_version" "mysql_rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.mysql_rds_secret.id
  secret_string = jsonencode({
    password = random_password.mysql_rds_password.result
  })
}

resource "aws_db_instance" "mysql_rds_instance" {
  identifier              = "tf-aws-test-mysql-rds-instance"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_subnet_group_name    = aws_db_subnet_group.mysql_rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.mysql_rds_sg.id]
  username                = var.db_username
  password                = random_password.mysql_rds_password.result
  skip_final_snapshot     = true

  tags = {
    Name      = "TF-AWS-Test-MySQL-RDS-Instance"
    ManagedBy = "Terraform"
  }
}