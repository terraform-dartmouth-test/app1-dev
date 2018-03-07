provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}

resource "aws_instance" "example" {
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  instance_type = "${var.aws_instance_type}"

  subnet_id = "${lookup(var.aws_subnets, var.aws_az)}"


  vpc_security_group_ids = "${var.security_groups}"


  key_name = "${var.lunch_key_pair_name}"

  tags {
    Name = "${var.instance_name}"
    DNS_A = "${var.instance_name}.aws.dartmouth.edu"
  }

  root_block_device {
    volume_type = "${var.volume_type}"
    volume_size = "${var.root_volume_size}"
  }

  user_data = "${file(var.user_data_script)}"

}
