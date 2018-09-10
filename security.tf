resource "aws_security_group" "unifi" {
  name   = "unifi"
  vpc_id = "${aws_vpc.unifi.id}"

  tags {
    Name = "unifi"
  }
}

resource "aws_security_group" "unifi_lb" {
  name   = "unifi_lb"
  vpc_id = "${aws_vpc.unifi.id}"

  tags {
    Name = "unifi_lb"
  }
}

resource "aws_security_group" "mongo" {
  name   = "mongo"
  vpc_id = "${aws_vpc.unifi.id}"

  tags {
    Name = "mongo"
  }
}

resource "aws_security_group_rule" "unifi_device_controller" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.unifi_lb.id}"
  security_group_id        = "${aws_security_group.unifi.id}"
}

resource "aws_security_group_rule" "unifi_web" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.unifi_lb.id}"
  security_group_id        = "${aws_security_group.unifi.id}"
}

resource "aws_security_group_rule" "unifi_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.unifi.id}"
}

resource "aws_security_group_rule" "unifi_https_external" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.unifi_lb.id}"
}

resource "aws_security_group_rule" "outbound_internet_access_unifi" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.unifi_lb.id}"
}

resource "aws_security_group_rule" "mongo_in" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id  = "${aws_security_group.mongo.id}"
}

resource "aws_security_group_rule" "mongo_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.mongo.id}"
}
