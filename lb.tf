resource "aws_lb" "unifi_lb" {
  name     = "unifi-lb"
  internal = false

  #load_balancer_type         = "application"
  enable_deletion_protection = false

  subnets         = ["${aws_subnet.unifi_public.*.id}"]
  security_groups = ["${aws_security_group.unifi_lb.id}"]

  tags {
    Name = "unifi_lb"
  }
}

resource "aws_lb_target_group" "tg_unifi" {
  name        = "tg-unifi"
  port        = "8443"
  protocol    = "HTTPS"
  vpc_id      = "${aws_vpc.unifi.id}"
  target_type = "ip"

  health_check {
    path                = "/"
    unhealthy_threshold = "5"
    interval            = "60"
    matcher             = "302"
    protocol            = "HTTPS"
  }
}

resource "aws_lb_listener" "listener_unifi" {
  load_balancer_arn = "${aws_lb.unifi_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.unifi_ssl_certificate.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.tg_unifi.arn}"
    type             = "forward"
  }
}
