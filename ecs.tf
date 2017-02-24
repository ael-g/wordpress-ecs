resource "aws_launch_configuration" "ecs" {
  name                 = "ecs-configuration"
  instance_type        = "t2.micro"
  image_id             = "ami-022b9262"
  security_groups      = ["${aws_security_group.ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  #user_data            = "${file("userdata.sh")}"
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.ecs.name} > /etc/ecs/ecs.config"
  key_name             = "kim2"
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "ecs-autoscale"
  vpc_zone_identifier  = ["${aws_subnet.zone1_subnet.id}", "${aws_subnet.zone2_subnet.id}"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  load_balancers       = ["${aws_elb.ecs.name}"]
}

resource "aws_ecs_cluster" "ecs" {
  name = "wordpress-cluster"
}

resource "aws_ecs_task_definition" "ecs" {
  family = "wordpress"
  container_definitions = "${file("wordpress-service.json")}"
}

resource "aws_ecs_service" "ecs" {
  name = "wordpress-service"
  cluster = "${aws_ecs_cluster.ecs.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.ecs.family}"
}

resource "aws_elb" "ecs" {
  name               = "wordpress-elb"
  security_groups    = ["${aws_security_group.ecs.id}"]
  subnets            = ["${aws_subnet.zone1_subnet.id}", "${aws_subnet.zone2_subnet.id}"]
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
    target              = "HTTP:80/"
    interval            = 30
  }
}
