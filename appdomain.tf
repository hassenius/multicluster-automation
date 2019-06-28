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

### Create a zone and set the name servers from IBM Cloud Internet Services
resource "aws_route53_zone" "appdomain" {
  name = "${var.app_zone}.${var.app_domain_base}"
  comment = "For multicloud apps. Managed by Terraform"

  tags = {
    Environment = "prod"
  }
}

resource "aws_route53_record" "appdomain-ns" {
  allow_overwrite = true
  zone_id         = "${aws_route53_zone.appdomain.zone_id}"
  name            = "${var.app_zone}.${var.app_domain_base}"
  type            = "NS"
  ttl             = "30"

  records = ["${ibm_cis_domain.appdomain.name_servers}"]
}

provider "ibm" {

}


data "ibm_resource_group" "sre" {
  name = "SREREFARCH"
}

resource "ibm_cis" "multicloudapps" {
  name              = "MultiCloudApps"
  plan              = "standard"
  resource_group_id = "${data.ibm_resource_group.sre.id}"
  tags              = ["sre", "multicloud"]
  location          = "global"

  //User can increase timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# resource "ibm_cis_global_load_balancer" "appsloadbalancer" {
#   cis_id = "${ibm_cis.multicloudapps.id}"
#   domain_id = "${ibm_cis_domain.example.id}"
#   name = "www.example.com"
#   fallback_pool_id = "${ibm_cis_origin_pool.example.id}"
#   default_pool_ids = ["${ibm_cis_origin_pool.example.id}"]
#   description = "example load balancer using geo-balancing"
#   proxied = true
# }
#

### Register the domain to use with IBM Cloud Internet Services
resource "ibm_cis_domain" "appdomain" {
    domain = "${var.app_zone}.${var.app_domain_base}"
    cis_id = "${ibm_cis.multicloudapps.id}"
}

resource "ibm_cis_origin_pool" "ingresspool" {
  cis_id        = "${ibm_cis.multicloudapps.id}"
  name          = "ingresspool"
  check_regions = ["WEU"]
  enabled       = true

  origins {
    name    = "azure"
    address = "${module.azurecloud.icp_proxy}"
    enabled = true
  }
  origins {
    name    = "aws"
    address = "${module.awscloud.icp_proxy_host}"
    enabled = true
  }
  origins {
    name    = "ibm"
    address = "${module.ibmcloud.icp_proxy_host}"
    enabled = true
  }
}
