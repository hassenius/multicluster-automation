variable "iks_resource_group" { }
variable "iks_public_vlan" { }
variable "iks_private_vlan" { }
variable "iks_slack_webhook" { }
variable "iks_region" { default = "eu-gb" }

data "ibm_resource_group" "refarch" {
  name = "${var.iks_resource_group}"
}


resource "ibm_container_cluster" "iks_refarch_cluster" {
  name            = "sre_refarch"
  datacenter      = "lon06"
  kube_version    = "3.11.104_openshift"
  machine_type    = "b3c.4x16"
  hardware        = "shared"
  public_vlan_id  = "${var.iks_public_vlan}"
  private_vlan_id = "${var.iks_private_vlan}"
  region          = "${var.iks_region}"
  resource_group_id = "${data.ibm_resource_group.refarch.id}"

  default_pool_size      = 1

  webhook = [{
    level = "Normal"
    type = "slack"
    url = "${var.iks_slack_webhook}"
  }]

}

### This doesn't work at the moment.
# See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/656
# data "ibm_container_cluster_config" "refarch_ds_cluster" {
#   cluster_name_id = "${ibm_container_cluster.iks_refarch_cluster.id}"
#   resource_group_id = "${data.ibm_resource_group.refarch.id}"
#   region          = "${var.iks_region}"
# }

## Use this as a workaround
## Pass server_url as query string and
## pickup IC_API_KEY from environment variable
data "external" "iks_token" {
  program = ["sh", "${path.module}/bin/get_iks_openshift_token.sh"]

  query = {
    server_url = "${ibm_container_cluster.iks_refarch_cluster.server_url}"
  }
}

provider "kubernetes" {
  host      = "${ibm_container_cluster.iks_refarch_cluster.server_url}"
  token    = "${data.external.iks_token.result.token}"
  alias     = "ikskube"
}

resource "kubernetes_namespace" "example" {
  provider = "kubernetes.ikskube"

  metadata {
    annotations {
      name = "example-annotation"
    }

    labels {
      mylabel = "label-value"
    }

    name = "my-terraform-ns"
  }
}
