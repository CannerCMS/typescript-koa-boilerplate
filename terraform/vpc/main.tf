// provide default vpc and subnets
resource "aws_default_vpc" "default" {
  tags {
      Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "ap-northeast-1a"

    tags {
        Name = "Default subnet for ap-northeast-1a"
    }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "ap-northeast-1c"

    tags {
        Name = "Default subnet for ap-northeast-1c"
    }
}

/**
 * Outputs
 */

// The VPC ID
output "id" {
  value = "${aws_default_vpc.default.id}"
}

output "region" {
  value = "ap-northeast-1"
}

// The VPC CIDR
output "cidr_block" {
  value = "${aws_default_vpc.default.cidr_block}"
}

// A comma-separated list of subnet IDs.
output "subnets" {
  value = ["${aws_default_subnet.default_az1.id}", "${aws_default_subnet.default_az2.id}"]
}

output "availability_zones" {
  value = ["${aws_default_subnet.default_az1.availability_zone}", "${aws_default_subnet.default_az2.availability_zone}"]
}
