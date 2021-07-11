terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    tls = {
      version = "~> 3.1"
    }
    local = {
      version = "~> 2.1"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "~> 1.3.0"
      # Ignition version 0.34 supported by flatcar
      # https://registry.terraform.io/providers/community-terraform-providers/ignition/latest/docs#ignition-versions
      # https://kinvolk.io/flatcar-container-linux/releases/
    }
  }
}
