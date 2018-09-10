resource "aws_ecs_cluster" "unifargate" {
  name = "unifargate"
}

resource "aws_ecs_task_definition" "unifitask" {
  family                   = "unifi"
  container_definitions    = "${data.template_file.unifi_container_definition.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
  cpu                      = 1024
  memory                   = 4096

  volume {
    name      = "unifi"
    host_path = "/tmp/unifi"
  }
}

resource "aws_ecs_service" "unifiservice" {
  name            = "unificontroller"
  cluster         = "${aws_ecs_cluster.unifargate.name}"
  task_definition = "${aws_ecs_task_definition.unifitask.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["${aws_subnet.unifi_private.*.id}"]
    security_groups  = ["${aws_security_group.unifi.id}"]
    assign_public_ip = "false"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.tg_unifi.arn}"
    container_name   = "unifi"
    container_port   = 8443
  }

  service_registries {
    registry_arn   = "${aws_service_discovery_service.unifi.arn}"
    container_name = "unifi"
  }

  depends_on = ["aws_lb_listener.listener_unifi"]
}

data "template_file" "unifi_container_definition" {
  template = "${file("${path.module}/unifi_container_definition.json")}"

  vars = {
    aws_region = "${var.aws_region}"
  }
}

resource "aws_ecs_task_definition" "mongotask" {
  family                   = "mongo"
  container_definitions    = "${data.template_file.mongo_container_definition.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
  cpu                      = 1024
  memory                   = 4096
}

resource "aws_ecs_service" "mongoservice" {
  name            = "mongo"
  cluster         = "${aws_ecs_cluster.unifargate.name}"
  task_definition = "${aws_ecs_task_definition.mongotask.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["${aws_subnet.unifi_private.*.id}"]
    security_groups  = ["${aws_security_group.mongo.id}"]
    assign_public_ip = "false"
  }

  service_registries {
    registry_arn   = "${aws_service_discovery_service.mongo.arn}"
    container_name = "mongo"
  }
}

data "template_file" "mongo_container_definition" {
  template = "${file("${path.module}/mongo_container_definition.json")}"

  vars = {
    aws_region = "${var.aws_region}"
  }
}
