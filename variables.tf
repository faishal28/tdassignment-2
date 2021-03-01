variable "region" {
  description = "AWS region for hosting our your network"
  default     = "us-west-2"
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "/home/faishal/aws-ansible/VM-us-west-2.pem"
}

variable "key_name" {
  description = "Key name for SSHing into EC2"
  default     = "VM-us-west-2"
}

variable "amis" {
  description = "Base AMI to launch the instances"
  default = {
    us-west-2 = "ami-0928f4202481dfdf6"
  }
}

variable "certificate" {
  description = "self signed certificate arn"
  default     = "arn:aws:iam::295971227144:server-certificate/elb-demo-1"
}