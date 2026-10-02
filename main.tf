terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Mantener tu bucket actual
resource "aws_s3_bucket" "mi_bucket" {
  bucket        = "fabian-bucket-vcs-2026" 
  force_destroy = true
  tags = {
    Ambiente  = "Dev"
    ManagedBy = "GitHub-VCS-Workflow"
  }
}

# 1. Crear un Grupo de Seguridad para permitir tráfico web (HTTP)
resource "aws_security_group" "web_sg" {
  name        = "fabian-web-sg"
  description = "Permitir trafico HTTP entrante para el servicio web"

  ingress {
    description = "HTTP de cualquier parte"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Expuesto a todo internet
  }

  egress {
    description = "Permitir salida de internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Desplegar una instancia EC2 (Servidor Web Nginx)
resource "aws_instance" "web_server" {
  ami                         = "ami-0c7217cdde317cfec" # Ubuntu Server 22.04 LTS en us-east-1
  instance_type               = "t2.micro"             
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true 

  # Modifica este texto a tu gusto para probar el cambio
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>1-octubre-2026 Servicio expuesto con Exito via HCP Terraform GitOps!</h1>" | sudo tee /var/www/html/index.html
              EOF

  # 🟢 ESTA ES LA LÍNEA MÁGICA: Destruye y recrea la EC2 si el user_data cambia
  user_data_replace_on_change = true

  tags = {
    Name = "Servicio-Web-Fabian"
  }
}

# 1. Output para la dirección IP pública directa
output "nginx_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "La direccion IP publica del servidor web Nginx."
}

# 2. Output que indica que no hay operaciones pendientes en el estado
output "no-op" {
  value       = "Infraestructura sincronizada correctamente."
  description = "Indicador de estado sin operaciones pendientes."
}

# 3. Output para la URL usando el DNS público de AWS
output "nginx_url" {
  value       = "http://${aws_instance.web_server.public_dns}"
  description = "El enlace URL publica del servidor para abrir en el navegador."
}
