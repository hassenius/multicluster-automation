variable "sl_apikey" {
  description = "Username for API Access to IBM Cloud"
}

variable "aadClientId" {
  description = "Auth information for azure cloud controller manager"
}

variable "aadClientSecret" {
  description = "Auth information for azure cloud controller manager"
}

### Providers block.
# It's strongly encouraged to keep providers outside modules, as removing a module can be
# problematic when keeping providers inside module configuration block. If the provider is only
# specified inside the module block, removing the block will prevent the removal of those
# resources as there is no longer a provider available to destroy the resources

provider "aws" {
  alias = "awsclusters"
  region = "eu-west-1"
}


provider "ibm" {
  alias = "ibmcloudclusters"
  softlayer_username = "hans.moen.case"
  softlayer_api_key = "${var.sl_apikey}"
}


module "ibmcloud" {
  source = "git::https://github.com/ibm-cloud-architecture/terraform-icp-ibmcloud.git//templates/icp-ce-with-loadbalancers?ref=v1"
  providers = {
    "ibm" = "ibm.ibmcloudclusters"
  }
  sl_username = "hans.moen.case"
  sl_api_key = "${var.sl_apikey}"
  icp_inception_image = "3.1.2"
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

module "azurecloud" {
  source = "github.com/ibm-cloud-architecture/terraform-icp-azure.git//templates/icp-ce?ref=v1"
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAmGOJtZF5FYrpmEBI9GBcbcr4577pZ90lLxZ7tpvfbPmgXQVGoolChAY165frlotd+o7WORtjPiUlRnr/+676xeYCZngLh46EJislXXvcmZrIn3eeQTRdOlIkiP3V4+LiR9WvpyvmMY9jJ05sTGgk39h9LKhBs+XgU7eZMXGYNU7jDiCZssslTvV1i7SensNqy5bziQbhFKsC7TFRld9leYPgCPtoiSeFIWoXSFbQQ0Lh1ayPpOPb0C2k4tYgDFNr927cObtShUOY1dGGBZygUVKQRro1LZzq39DhmvmMCawCnnQt6A8jz4PE69jP62gnlBsdXQDvEm/L/LBrO4CBbQ== hansmoen@oc3254063580.ibm.com"
  icp_version = "3.1.2"

  default_tags = {
    # tags.Clusterid:                                                   "29cfc3a1" => ""
    Environment = "Production"
    Name  = "ICPMCM"
    Owner = "hans.moen@ie.ibm.com"
    Stage = "preprod"
  }

  ## Authentication for azure kubernetes provider (cloud controller manager)
  aadClientId     = "${var.aadClientId}"
  aadClientSecret = "${var.aadClientSecret}"

  instance_name = "srerefarchimp"

  location = "West Europe"

  cluster_name = "srerefarchimp"


  virtual_network_cidr = "172.22.0.0/16"

  subnet_prefix = "172.22.0.128/25"

  controlplane_subnet_name = "icpcontrol"

  controlplane_subnet_prefix = "172.22.0.0/25"


  network_cidr = "172.22.128.0/17"

  cluster_ip_range = "172.22.127.0/24"

  # default_tags = {
  #   Owner       = "icp-sre"
  #   Environment = "icp"
  #   Stage       = "preprod"
  # }

  boot = {
    # This will also act as the VPN Gateway after creation
    nodes = "1"
    name          = "azbootnode"
    os_image      = "ubuntu"
    vm_size       = "Standard_A2_v2"
    os_disk_type  = "Standard_LRS"
    os_disk_size  = "100"
    docker_disk_size = "100"
    docker_disk_type = "StandardSSD_LRS"
    enable_accelerated_networking = "false"

  }

    worker = {
  #
       nodes         = "4"
      name          = "worker"
      vm_size       = "Standard_A4_v2"
      os_disk_type  = "Standard_LRS"
      docker_disk_size = "100"
      docker_disk_type = "Standard_LRS"
  #
  }

}


module "awscloud" {
  source = "github.com/ibm-cloud-architecture/terraform-icp-aws.git?ref=v1.1"

  providers = {
    "aws" = "aws.awsclusters"
  }

  aws_region = "eu-west-1"

  ami = "ami-0cbf7a0c36bde57c9"

  bastion = {
    nodes = "1"
    type      = "t2.micro"
    ami       = "ami-0cbf7a0c36bde57c9" // Leave blank to let terraform search for Ubuntu 16.04 ami. NOT RECOMMENDED FOR PRODUCTION
    disk      = "10" //GB
  }

  master = {
    nodes = "1"
    type      = "m4.2xlarge"
    ami       = "ami-0cbf7a0c36bde57c9" // Leave blank to let terraform search for Ubuntu 16.04 ami. NOT RECOMMENDED FOR PRODUCTION
    disk      = "300" //GB
    docker_vol = "100" // GB
    ebs_optimized = true    // not all instance types support EBS optimized
  }

  proxy = {
    nodes     = "1"
    type      = "m4.xlarge"
    ami       = "ami-0cbf7a0c36bde57c9" // Leave blank to let terraform search for Ubuntu 16.04 ami. NOT RECOMMENDED FOR PRODUCTION
    disk      = "150" //GB
    docker_vol = "100" // GB
    ebs_optimized = true    // not all instance types support EBS optimized
  }

  key_name = "hk_key"

  icp_inception_image = "ibmcom/icp-inception-amd64:3.2.0"

  icp_network_cidr = "172.23.0.0/17"

  icp_service_network_cidr = "172.23.128.0/17"

}


## IBM Cloud Environment
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

output "azurecloud_resource_group" {
  value = "${module.azurecloud.resource_group}"
}

output "azurecloud_icp_console_url" {
  value = "${module.azurecloud.icp_console_url}"
}

output "azurecloud_icp_console_server" {
  value = "${module.azurecloud.icp_console_server}"
}

output "azurecloud_icp_proxy" {
  value = "${module.azurecloud.icp_proxy}"
}

output "azurecloud_kubernetes_api_url" {
  value = "${module.azurecloud.kubernetes_api_url}"
}

output "azurecloud_icp_admin_username" {
  value = "admin"
}
