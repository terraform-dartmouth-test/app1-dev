variable "access_key" {}
variable "secret_key" {}
variable "instance_name" {}
variable "aws_az" {}

variable "security_groups" {
  type = "list"
  default = ["sg-35003546"]

}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_instance_type" {
  description = "AWS instance type by default."
  default     = "t2.micro"
}

variable "aws_amis" {
  default = {
    us-east-1 = "ami-1d4e7a66"
  }
}

variable "root_volume_size" {
  description = "OS root volume size"
  default = "20"
}

variable "aws_subnets" {
  default = {
    AZ1 = "subnet-87c0cdab"
    AZ2 = "subnet-6d75c109"
  }
}

variable "volume_type" {
  default = "gp2"
}

variable "user_data_script" {
  description = "User data script for linux instances"
  default = "userdata-aws-rhel7.sh"
}

variable "lunch_key_pair_name" {
  description = "Key pair used for lunching instance"
  default = "test-lunch"
}

variable "sg_default" {
  default = "sg-35003546"
}

variable "sg_test-sg-automation" {
  default = "sg-80e6caf7"
}

variable "aws_security_groups" {
  default = {
    sg_default = "sg-35003546"
    sg_test-sg-automation = "sg-80e6caf7"
  }

}

