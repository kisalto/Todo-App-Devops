provider "aws" {
    region = "us-east-1"
}

# ID da Imagem
data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

# Alternativamente, procurando pelo painel da aws:
# EC2 -> Launch instance -> ubuntu 24.04
# resource "aws_instance" "teste" {
#    ami =           "ami-xxxxxxxxxxxxxxxxx"
#    instance_type = "t3.micro"
#}

# chave SSH:
# gerar: ssh-keygen -t ed25519 -f %USERPROFILE%\.ssh\todo-feira
resource "aws_key_pair" "minha-chave" {
    key_name   = "teste-chave"
    public_key = file(pathexpand("~/.ssh/todo-feira.pub"))
}

# Firewall
resource "aws_security_group" "ssh" {
    name = "teste-ssh"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["SEU.IP.AQUI/32"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# A maquina
resource "aws_instance" "teste" {
    ami                    = data.aws_ami.ubuntu.id
    intance_type           = "t3.micro"
    key_name               = aws_key_pair.minha_chave.key_name
    vpc_security_group_ids = [aws_security_group.ssh.id]

    tags = { Name = "minha-primeira-vm" }
}

# mostra ip no final
output "ip" {
    value = aws_instance.teste.public_ip
}