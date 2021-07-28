terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      version = ">= 2.53.0"
    }
    tls = {
      version = ">= 2.1.1"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = ">= 1.2.1"
    }
    local = {
      version = ">= 1.4.0"
    }
  }
}
