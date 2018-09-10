# Get all the Availability Zones in the current region
data "aws_availability_zones" "unifi" {}

# How many Availability Zones are we going to use?
variable "azcount" {
  #default = "${length(data.aws_availability_zones.unifi.names)}"
  default = "2"
}

# The VPC
resource "aws_vpc" "unifi" {
  cidr_block = "10.100.0.0/16"

  tags {
    Name = "unifi-vpc"
  }
}

# private subnets for each AZ
resource "aws_subnet" "unifi_private" {
  count             = "${var.azcount}"
  vpc_id            = "${aws_vpc.unifi.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.unifi.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.unifi.names[count.index]}"

  tags {
    Name = "unifi-private-subnet-${data.aws_availability_zones.unifi.names[count.index]}"
  }
}

# Public subnet for routing to the internet
resource "aws_subnet" "unifi_public" {
  count                   = "${var.azcount}"
  vpc_id                  = "${aws_vpc.unifi.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.unifi.cidr_block, 8, var.azcount + count.index)}"
  availability_zone       = "${data.aws_availability_zones.unifi.names[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "unifi-public-subnet-${data.aws_availability_zones.unifi.names[count.index]}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "unifi_gateway" {
  vpc_id = "${aws_vpc.unifi.id}"

  tags {
    Name = "unifi Internet Gateway"
  }
}

# Route to the internet
resource "aws_route" "unifi_internet_route" {
  route_table_id         = "${aws_vpc.unifi.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.unifi_gateway.id}"
}

# Elastic IP for each AZ
resource "aws_eip" "unifi_eip" {
  count      = "${var.azcount}"
  vpc        = true
  depends_on = ["aws_internet_gateway.unifi_gateway"]

  tags {
    Name = "unifi EIP ${data.aws_availability_zones.unifi.names[count.index]}"
  }
}

# NAT gateway for each AZ
resource "aws_nat_gateway" "unifi_nat" {
  count         = "${var.azcount}"
  allocation_id = "${element(aws_eip.unifi_eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.unifi_public.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.unifi_gateway"]

  tags {
    Name = "unifi NAT ${data.aws_availability_zones.unifi.names[count.index]}"
  }
}

# Route table for each private subnet
resource "aws_route_table" "unifi_private_route_table" {
  count  = "${var.azcount}"
  vpc_id = "${aws_vpc.unifi.id}"

  tags {
    Name = "unifi Private Route Table ${data.aws_availability_zones.unifi.names[count.index]}"
  }
}

# Route traffic in each private subnet through the respective NAT gateway
resource "aws_route" "unifi_private_subnet_route" {
  count                  = "${var.azcount}"
  route_table_id         = "${element(aws_route_table.unifi_private_route_table.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.unifi_nat.*.id, count.index)}"
}

# Associate each routing table with the respective subnet
resource "aws_route_table_association" "unifi_private_subnet_route_association" {
  count          = "${var.azcount}"
  subnet_id      = "${element(aws_subnet.unifi_private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.unifi_private_route_table.*.id, count.index)}"
}
