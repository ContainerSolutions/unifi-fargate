variable "aws_region" {}
variable "aws_profile" {}

variable "host_name" {
  description = "The name you want the controller to be available under. This will be appended with the zone name below to make up the DNS name."
}

variable "zone_name" {
  description = "The name of the zone you want to create a record under"
}
