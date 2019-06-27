### Providers block.
# It's strongly encouraged to keep providers outside modules, as removing a module can be
# problematic when keeping providers inside module configuration block. If the provider is only
# specified inside the module block, removing the block will prevent the removal of those
# resources as there is no longer a provider available to destroy the resources
# https://www.terraform.io/docs/configuration-0-11/modules.html#passing-providers-explicitly

provider "aws" {
  region = "eu-west-1"
}

### Module / Template configuration
module "awscloud" {
  source = "github.com/ibm-cloud-architecture/terraform-icp-aws.git?ref=v1.3"

  providers = {
    aws = "aws"
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

### Outputs
