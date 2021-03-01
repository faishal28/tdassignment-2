terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

###fetch public ip
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "all" {}

### Creating Security Group for EC2
resource "aws_security_group" "SG" {
  name = "assignment-2"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creating Launch Configuration
resource "aws_launch_configuration" "launch_config" {
  name            = "assign2-config"
  image_id        = lookup(var.amis, var.region)
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.SG.id]
  key_name        = var.key_name
  user_data       = base64encode(file("launch.sh"))
  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "auto_group" {
  name                 = "assign2-autogroup"
  launch_configuration = aws_launch_configuration.launch_config.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size             = 3
  max_size             = 3
  load_balancers       = [aws_elb.balancer.name]
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

### Creating ELB
resource "aws_elb" "balancer" {
  name               = "assign2-balancer"
  security_groups    = [aws_security_group.SG.id]
  availability_zones = data.aws_availability_zones.all.names
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:8900/index.html"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "8900"
    instance_protocol = "http"
  }
  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = "8900"
    instance_protocol  = "http"
    ssl_certificate_id = var.certificate
  }

}