resource "aws_route53_zone" "wordpress_ael" {
  name          = "wordpress.ael."
  vpc_id        = "${aws_vpc.vpc_wordpress.id}"
}

resource "aws_route53_record" "db_wordpress_ael" {
    zone_id = "${aws_route53_zone.wordpress_ael.zone_id}"
    name    = "${var.db_fqdn}"
    type    = "CNAME"
    ttl     = "300"
    records = [
        "${aws_db_instance.rds.address}"
    ]
}

# zoneA and zoneB should have same dns name (?)
resource "aws_route53_record" "nfs_wordpress_ael" {
    zone_id = "${aws_route53_zone.wordpress_ael.zone_id}"
    name    = "${var.nfs_fqdn}"
    type    = "CNAME"
    ttl     = "300"
    records = [
        "${aws_efs_mount_target.efs_private_zoneA.dns_name}"
    ]
}

variable "db_fqdn" {
  default = "db.wordpress.ael"
}

variable "nfs_fqdn" {
  default = "nfs.wordpress.ael"
}
