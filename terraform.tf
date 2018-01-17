terraform {
  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "mongo_url" {
  description = "mongo_url"
}

variable "http_port" {
  description = "http_port"
}

module "stack" {
  source      = "./terraform/stack"
  name        = "koa-boilerplate"
  environment = "${var.environment}"
}

module "koa-boilerplate" {
  source = "./terraform/web-service"
  name = "koa-boilerplate"
  image = "<your own image id>"
  port = 1234
  image_version = "v1.0.0"
  container_port = "${var.http_port}"
  ssl_certificate_id = "<your own ssl arn>"

  environment      = "${module.stack.environment}"
  cluster          = "${module.stack.cluster}"
  iam_role         = "${module.stack.iam_role}"
  security_groups  = ["${module.stack.external_elb}"]
  subnet_ids       = "${module.stack.subnets}"
  env_vars = <<EOF
[
  { "name": "NODE_ENV", "value": "${var.environment}" },
  { "name": "MONGO_URL", "value": "${var.mongo_url}" },
  { "name": "NODE_PORT", "value": "${var.http_port}" }
]
EOF
}

module "domain" {
  source = "github.com/segmentio/stack//dns"
  name   = "koa.boilerlate.com"
}

resource "aws_route53_record" "root" {
  zone_id = "${module.domain.zone_id}"
  name    = "${module.domain.name}"
  type    = "A"

  alias {
    name                   = "${module.koa-boilerplate.dns}"
    zone_id                = "${module.koa-boilerplate.zone_id}"
    evaluate_target_health = false
  }
}
