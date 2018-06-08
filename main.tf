provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  version = "~> 1.22"
}

resource "aws_ecs_cluster" "unifargate" {
  name = "unifargate"
}

resource "aws_ecs_task_definition" "unifitask" {
  family                = "unifi"
  container_definitions = "${file("containerdefinition.json")}"
}

resource "aws_ecs_service" "unifiservice" {
  name            = "unificontroller"
  cluster         = "${aws_ecs_cluster.unifargate.name}"
  task_definition = "${aws_ecs_task_definition.unifitask.arn}"
  desired_count   = 1

  #iam_role
  #load_balancer {
  #  target_group_arn = "${aws_lb_target_group.foo.arn}"
  #  container_name   = "unifi"
  #  container_port   = 8080
  #}
}
