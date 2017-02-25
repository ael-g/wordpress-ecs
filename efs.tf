resource "aws_efs_file_system" "efs" {
  creation_token = "wordpress-assets"
}

resource "aws_efs_mount_target" "efs_private_zoneA" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  security_groups = ["${aws_security_group.efs.id}"]
  subnet_id       = "${aws_subnet.private_subnet_zoneA.id}"
}

resource "aws_efs_mount_target" "efs_private_zoneB" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  security_groups = ["${aws_security_group.efs.id}"]
  subnet_id       = "${aws_subnet.private_subnet_zoneB.id}"
}
