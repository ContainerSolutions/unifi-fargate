Unifi on ECS Fargate
====================

This repository contains a collection of Terraform scripts that set up a Unifi Controller to run on AWS Fargate.

Current state: It works, but there is no persistence. Also, you cannot restore any previous configuration because this causes the controller process to restart, resulting in a new container.

External MongoDB works, but only if you use a fixed IP. I was not able to successfully do Service Discovery yet.
