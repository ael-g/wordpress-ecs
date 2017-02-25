resource "aws_vpc" "vpc_wordpress" {
  enable_dns_hostnames = true
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
}

resource "aws_eip" "natgw_ip_zoneA" {
  vpc      = true
}

resource "aws_eip" "natgw_ip_zoneB" {
  vpc      = true
}

resource "aws_nat_gateway" "natgw_zoneA" {
  allocation_id = "${aws_eip.natgw_ip_zoneA.id}"
  subnet_id = "${aws_subnet.public_subnet_zoneA.id}"
}

resource "aws_nat_gateway" "natgw_zoneB" {
  allocation_id = "${aws_eip.natgw_ip_zoneB.id}"
  subnet_id = "${aws_subnet.public_subnet_zoneB.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table" "private_zoneA" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.natgw_zoneA.id}"
  }
}

resource "aws_route_table" "private_zoneB" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.natgw_zoneB.id}"
  }
}

resource "aws_route_table_association" "public_zoneA" {
  subnet_id = "${aws_subnet.public_subnet_zoneA.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_zoneB" {
  subnet_id = "${aws_subnet.public_subnet_zoneB.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private_zoneA" {
  subnet_id = "${aws_subnet.private_subnet_zoneA.id}"
  route_table_id = "${aws_route_table.private_zoneA.id}"
}

resource "aws_route_table_association" "private_zoneB" {
  subnet_id = "${aws_subnet.private_subnet_zoneB.id}"
  route_table_id = "${aws_route_table.private_zoneB.id}"
}
