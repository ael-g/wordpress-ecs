resource "aws_security_group" "ecs" {
  name = "http"
  vpc_id      = "${aws_vpc.vpc_wordpress.id}"
  description = "Allow http port for wordpress containers"
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_egress" {
  name = "ec2_egress"
  vpc_id      = "${aws_vpc.vpc_wordpress.id}"
  description = "Every needed rules for the ec2 instances (nfs, mysql, http/S for yum install)"
  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
  egress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}

resource "aws_security_group" "elb" {
  name = "http-egress"
  vpc_id      = "${aws_vpc.vpc_wordpress.id}"
  description = "Allow http from elb to ecs instances"
  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}

resource "aws_security_group" "rds" {
  name        = "mysql"
  vpc_id      = "${aws_vpc.vpc_wordpress.id}"
  description = "Allow mysql port"
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}

resource "aws_security_group" "efs" {
  name              = "nfs"
  vpc_id            = "${aws_vpc.vpc_wordpress.id}"
  description       = "Allow nfs port"
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["${aws_subnet.private_subnet_zoneA.cidr_block}", "${aws_subnet.private_subnet_zoneB.cidr_block}"]
  }
}
