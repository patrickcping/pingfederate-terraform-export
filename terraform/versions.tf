terraform {
  required_providers {
    pingfederate = {
      source  = "pingidentity/pingfederate"
      version = ">= 0.5.0, < 1.0.0"
    }
  }
}

provider "pingfederate" {
  # Configuration options
  username                            = var.pingfederate_username
  password                            = var.pingfederate_password
  https_host                          = var.pingfederate_https_host
  insecure_trust_all_tls              = var.pingfederate_insecure_trust_all_tls
  x_bypass_external_validation_header = var.pingfederate_x_bypass_external_validation_header
  product_version                     = "12.0.0"
}
