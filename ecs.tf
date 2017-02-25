resource "aws_ecs_cluster" "ecs" {
  name = "wordpress-cluster"
}

resource "aws_ecs_service" "ecs" {
  name = "wordpress-service"
  cluster = "${aws_ecs_cluster.ecs.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.ecs.family}"
}

resource "aws_ecs_task_definition" "ecs" {
  family = "wordpress"
  container_definitions = "${data.template_file.wordpress_task.rendered}"
  volume {
    name = "nfs-storage"
    host_path = "/mnt/wordpress"
  }
}

data "template_file" "wordpress_task" {
  template = "${file("wordpress_task.json")}"
  vars {
    repository_url = "${aws_ecr_repository.ecr.repository_url}"
  }
}
