

resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "name" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "name2" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_db_subnet_group" "name" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.name.id, aws_subnet.name2.id]
}

resource "aws_security_group" "name" {
  name        = "my-db-security-group"
  description = "Allow MySQL traffic"
  vpc_id      = aws_vpc.name.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "name" {
  identifier             = "my-rds-instance"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.name.name
  vpc_security_group_ids = [aws_security_group.name.id]
  skip_final_snapshot    = true
  username               = "admin"
  password               = var.db_password
  maintenance_window     = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"


}

resource "aws_secretsmanager_secret" "rds" {
  name        = "my-rds-master-credentials"
  description = "Master credentials for the RDS instance"
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id

  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
    engine   = "mysql"
    host     = aws_db_instance.name.address
    port     = 3306
  })
}

