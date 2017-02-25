output "ecr_repository" {
  value = "${aws_ecr_repository.ecr.repository_url}"
}

output "elb_dns" {
  value = "${aws_elb.ec2.dns_name}"
}
