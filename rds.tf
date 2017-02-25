resource "aws_db_instance" "rds" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.6.27"
  instance_class       = "db.t2.micro"
  name                 = "wordpress"
  username             = "wp"
  password             = "myverystrongpassword"
  db_subnet_group_name = "${aws_db_subnet_group.rds.name}"
  vpc_security_group_ids   = ["${aws_security_group.rds.id}"]
}

resource "aws_db_subnet_group" "rds" {
  name       = "subnet_group"
  subnet_ids = ["${aws_subnet.private_subnet_zoneA.id}", "${aws_subnet.private_subnet_zoneB.id}"]
}
