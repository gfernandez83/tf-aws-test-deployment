data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_acm_certificate" "nginx-domain" {
  domain   = "nginx.example.com"
  statuses = ["ISSUED"]
}

data "aws_region" "current" {}