resource "aws_subnet" "public_subnet_zoneA" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  availability_zone = "us-west-2a"
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "public_subnet_zoneB" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  availability_zone = "us-west-2b"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "private_subnet_zoneA" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  availability_zone = "us-west-2a"
  cidr_block = "10.0.10.0/24"
}

resource "aws_subnet" "private_subnet_zoneB" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  availability_zone = "us-west-2b"
  cidr_block = "10.0.11.0/24"
}
