resource "aws_instance" "jenkins_server" {

  ami           = "ami-091138d0f0d41ff90"
  instance_type = var.instance_type
  key_name      = var.key_name

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "DevSecOps-Server"
  }
}
