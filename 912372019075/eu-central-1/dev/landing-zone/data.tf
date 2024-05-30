data "aws_route53_zone" "decartel_root" {
  name         = "${var.base_domain}." # Replace with your domain, ensure it ends with a dot
  private_zone = false
}