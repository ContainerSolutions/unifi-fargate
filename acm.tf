data "aws_acm_certificate" "unifi_ssl_certificate" {
  domain      = "${var.host_name}.${var.zone_name}"
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
