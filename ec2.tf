resource "aws_launch_configuration" "ec2" {
  name                 = "ecs-configuration"
  instance_type        = "t2.micro"
  image_id             = "ami-022b9262"
  security_groups      = ["${aws_security_group.ecs.id}", "${aws_security_group.ec2_egress.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  user_data            = "${data.template_file.ec2_userdata.rendered}"
}

# We need this 'depend_on' line otherwise we may not be able to reach internet at first terraform apply command
resource "aws_autoscaling_group" "ec2" {
  depends_on           = ["aws_nat_gateway.natgw_zoneA", "aws_nat_gateway.natgw_zoneB"]
  name                 = "ecs-autoscale"
  vpc_zone_identifier  = ["${aws_subnet.private_subnet_zoneA.id}", "${aws_subnet.private_subnet_zoneB.id}"]
  launch_configuration = "${aws_launch_configuration.ec2.name}"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  load_balancers       = ["${aws_elb.ec2.name}"]
}

resource "aws_elb" "ec2" {
  name               = "wordpress-elb"
  security_groups    = ["${aws_security_group.ecs.id}", "${aws_security_group.elb.id}"]
  subnets            = ["${aws_subnet.public_subnet_zoneA.id}", "${aws_subnet.public_subnet_zoneB.id}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/wp-admin/install.php"
    interval            = 30
  }
}

data "template_file" "ec2_userdata" {
  template = "${file("userdata.sh")}"
  vars {
    ecs_cluster = "${aws_ecs_cluster.ecs.name}"
    nfs_fqdn    = "${var.nfs_fqdn}"
  }
}
