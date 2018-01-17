variable "name" {
  description = "the name of your stack, e.g. \"segment\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod-west\""
}

variable "ecs_instance_type" {
  description = "the instance type to use for your default ecs cluster"
  default     = "t2.micro"
}

variable "ecs_instance_ebs_optimized" {
  description = "use EBS - not all instance types support EBS"
  default     = false
}

variable "ecs_min_size" {
  description = "the minimum number of instances to use in the default ecs cluster"

  // create 3 instances in our cluster by default
  // 2 instances to run our service with high-availability
  // 1 extra instance so we can deploy without port collisions
  default = 3
}

variable "ecs_max_size" {
  description = "the maximum number of instances to use in the default ecs cluster"
  default     = 100
}

variable "ecs_desired_capacity" {
  description = "the desired number of instances to use in the default ecs cluster"
  default     = 3
}

variable "ecs_root_volume_size" {
  description = "the size of the ecs instance root volume"
  default     = 25
}

variable "ecs_docker_volume_size" {
  description = "the size of the ecs instance docker volume"
  default     = 25
}

variable "ecs_docker_auth_type" {
  description = "The docker auth type, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the possible values"
  default     = ""
}

variable "ecs_docker_auth_data" {
  description = "A JSON object providing the docker auth data, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the supported formats"
  default     = ""
}

variable "ecs_security_groups" {
  description = "A comma separated list of security groups from which ingest traffic will be allowed on the ECS cluster, it defaults to allowing ingress traffic on port 22 and coming grom the ELBs"
  default     = ""
}

variable "ecs_ami" {
  description = "The AMI that will be used to launch EC2 instances in the ECS cluster"
  default     = ""
}

variable "extra_cloud_config_type" {
  description = "Extra cloud config type"
  default     = "text/cloud-config"
}

variable "extra_cloud_config_content" {
  description = "Extra cloud config content"
  default     = ""
}

module "vpc" {
  source = "../vpc"
}

module "defaults" {
  source = "../defaults"
  region = "${module.vpc.region}"
  cidr   = "${module.vpc.cidr_block}"
}

module "security_groups" {
  source      = "../security-groups"
  name        = "${var.name}"
  vpc_id      = "${module.vpc.id}"
  environment = "${var.environment}"
  cidr        = "${module.vpc.cidr_block}"
}

module "iam_role" {
  source      = "../iam-role"
  name        = "${var.name}"
  environment = "${var.environment}"
}

module "ecs_cluster" {
  source                 = "../ecs-cluster"
  name                   = "${var.name}"
  environment            = "${var.environment}"
  vpc_id                 = "${module.vpc.id}"
  image_id               = "${coalesce(var.ecs_ami, module.defaults.ecs_ami)}"
  subnet_ids             = "${module.vpc.subnets}"
  instance_type          = "${var.ecs_instance_type}"
  instance_ebs_optimized = "${var.ecs_instance_ebs_optimized}"
  iam_instance_profile   = "${module.iam_role.profile}"
  min_size               = "${var.ecs_min_size}"
  max_size               = "${var.ecs_max_size}"
  desired_capacity       = "${var.ecs_desired_capacity}"
  region                 = "${module.vpc.region}"
  availability_zones     = "${module.vpc.availability_zones}"
  root_volume_size       = "${var.ecs_root_volume_size}"
  docker_volume_size     = "${var.ecs_docker_volume_size}"
  docker_auth_type       = "${var.ecs_docker_auth_type}"
  docker_auth_data       = "${var.ecs_docker_auth_data}"
  security_groups        = "${coalesce(var.ecs_security_groups, format("%s,%s,%s", module.security_groups.internal_ssh, module.security_groups.internal_elb, module.security_groups.external_elb))}"
  extra_cloud_config_type     = "${var.extra_cloud_config_type}"
  extra_cloud_config_content  = "${var.extra_cloud_config_content}"
}

// The environment of the stack, e.g "prod".
output "environment" {
  value = "${var.environment}"
}

// The default ECS cluster name.
output "cluster" {
  value = "${module.ecs_cluster.name}"
}

// ECS Service IAM role.
output "iam_role" {
  value = "${module.iam_role.arn}"
}

// Security group for external ELBs.
output "external_elb" {
  value = "${module.security_groups.external_elb}"
}

// Comma separated list of external subnet IDs.
output "subnets" {
  value = "${module.vpc.subnets}"
}
