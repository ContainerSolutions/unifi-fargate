resource "aws_route53_record" "record_unifi" {
  zone_id = "${data.aws_route53_zone.unifizone.zone_id}"
  name    = "wifi.${data.aws_route53_zone.unifizone.name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.unifi_lb.dns_name}"
    zone_id                = "${aws_lb.unifi_lb.zone_id}"
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "unifizone" {
  name         = "${var.zone_name}."
  private_zone = false
}

resource "aws_service_discovery_private_dns_namespace" "unifi" {
  name        = "unifi.local"
  description = "unifi"
  vpc         = "${aws_vpc.unifi.id}"
}

resource "aws_service_discovery_service" "unifi" {
  name = "unifi"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.unifi.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "mongo" {
  name = "mongo"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.unifi.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
