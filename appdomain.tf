# We will use Route53 for managing our domain and IBM Cloud to manage our global load balancer


variable "app_domain_base" {
  default = "opencloudops.io"
}

variable "app_zone" {
  default = "apps"
}

data "aws_route53_zone" "appbase" {
  name         = "${var.app_domain_base}."
  private_zone = false
}

resource "aws_route53_zone" "dev" {
  name = "${var.app_zone}.${var.app_domain_base}"
  comment = "For multicloud apps. Managed by Terraform"

  tags = {
    Environment = "prod"
  }
}

provider "ibm" {

}
#
# resource "ibm_cis_global_load_balancer" "example" {
#   cis_id = "${ibm_cis.instance.id}"
#   domain_id = "${ibm_cis_domain.example.id}"
#   name = "www.example.com"
#   fallback_pool_id = "${ibm_cis_origin_pool.example.id}"
#   default_pool_ids = ["${ibm_cis_origin_pool.example.id}"]
#   description = "example load balancer using geo-balancing"
#   proxied = true
# }
#
# resource "ibm_cis_origin_pool" "example" {
#   cis_id = "${ibm_cis.instance.id}"
#   name = "example-lb-pool"
#   origins {
#     name = "example-1"
#     address = "192.0.2.1"
#     enabled = false
#   }
# }
