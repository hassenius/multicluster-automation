### Providers block.
# It's strongly encouraged to keep providers outside modules, as removing a module can be
# problematic when keeping providers inside module configuration block. If the provider is only
# specified inside the module block, removing the block will prevent the removal of those
# resources as there is no longer a provider available to destroy the resources
# https://www.terraform.io/docs/configuration-0-11/modules.html#passing-providers-explicitly

provider "ibm" {
  alias = "ibmcloudclusters"
}

### Module / Template configuration
module "ibmcloud" {
  source = "git::https://github.com/ibm-cloud-architecture/terraform-icp-ibmcloud.git//templates/icp-ce-with-loadbalancers?ref=v1"
  providers = {
    ibm = "ibm.ibmcloudclusters"
  }

  sl_username = "dummy_value" # We override this with root provider
  sl_api_key  = "dummy_value" # We override this with root provider

  icp_inception_image = "3.2.0"
  deployment = "srerefarchimp"
  key_name = ["hk_key"]
  datacenter = "lon06"

  worker = {
    nodes = "4"
    cpu_cores   = "4"
    memory      = "4096"

    disk_size         = "100" // GB
    docker_vol_size   = "100" // GB
    local_disk  = false

    network_speed= "1000"

    hourly_billing = true
  }

  boot = {
    # This will also act as the VPN Gateway after creation
    nodes = "1"
    cpu_cores         = "2"
    memory            = "4096"

    disk_size         = "100" // GB
    docker_vol_size   = "100" // GB
    local_disk        = true
    os_reference_code = "UBUNTU_16_64"

    network_speed     = "1000"

    hourly_billing = true

  }

  network_cidr = "172.21.128.0/17"


  service_network_cidr  = "172.21.127.0/24"

}

### Outputs
output "ibmcloud_icp_console_host" {
  value = "${module.ibmcloud.icp_console_host}"
}

output "ibmcloud_icp_proxy_host" {
  value = "${module.ibmcloud.icp_proxy_host}"
}

output "ibmcloud_icp_console_url" {
  value = "${module.ibmcloud.icp_console_url}"
}

output "ibmcloud_icp_registry_url" {
  value = "${module.ibmcloud.icp_registry_url}"
}

output "ibmcloud_kubernetes_api_url" {
  value = "${module.ibmcloud.kubernetes_api_url}"
}

output "ibmcloud_icp_admin_username" {
  value = "admin"
}

## We will not output the passwords since
## we do our builds in public
##
# output "ibmcloud_icp_admin_password" {
#   value = "${module.ibmcloud.icp_admin_password}"
# }

# Azure environment
## We will not output the passwords since
## we do our builds in public
##
# output "azurecloud_icp_admin_password" {
#   value = "${module.azurecloud.icp_admin_password}"
# }
