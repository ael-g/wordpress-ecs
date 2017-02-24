resource "aws_efs_file_system" "efs" {
  creation_token = "wordpress-assets"
}

#resource "aws_efs_mount_target" "efs_zone1" {
#  file_system_id  = "${aws_efs_file_system.efs.id}"
#  security_groups = ["${aws_security_group.efs.id}"]
#  subnet_id       = "${aws_subnet.zone1_subnet.id}"
#}
#
#resource "aws_efs_mount_target" "efs_zone2" {
#  file_system_id  = "${aws_efs_file_system.efs.id}"
#  security_groups = ["${aws_security_group.efs.id}"]
#  subnet_id       = "${aws_subnet.zone2_subnet.id}"
#}
