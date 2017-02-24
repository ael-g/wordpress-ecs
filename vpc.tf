variable "vpc_subnet" {
  description = "Full address range for the VPC"
  default = "10.0.0.0/16"
}

variable "zone1_subnet" {
  description = "Project subnet"
  default = "10.0.0.0/24"
}

variable "zone2_subnet" {
  description = "Project subnet"
  default = "10.0.1.0/24"
}

resource "aws_subnet" "zone1_subnet" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  availability_zone = "us-west-2a"
  cidr_block = "${var.zone1_subnet}"
}

resource "aws_subnet" "zone2_subnet" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  availability_zone = "us-west-2b"
  cidr_block = "${var.zone2_subnet}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_wordpress.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_vpc" "vpc_wordpress" {
  enable_dns_hostnames = true
  cidr_block = "${var.vpc_subnet}"
}

resource "aws_security_group" "ecs" {                      
  name = "wordpress-http"                                  
  vpc_id      = "${aws_vpc.vpc_wordpress.id}"
  description = "Allow HTTP port for wordpress containers" 
  ingress {                                                
    from_port = 80                                         
    to_port   = 80                                         
    protocol  = "tcp"                                      
    cidr_blocks = ["0.0.0.0/0"]                            
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
    cidr_blocks = ["${aws_subnet.zone1_subnet.cidr_block}", "${aws_subnet.zone2_subnet.cidr_block}"]
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
    cidr_blocks     = ["${aws_subnet.zone1_subnet.cidr_block}", "${aws_subnet.zone2_subnet.cidr_block}"]
  }
}
