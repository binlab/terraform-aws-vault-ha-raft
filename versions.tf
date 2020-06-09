terraform {
  required_version = ">= 0.12"
  required_providers {
    aws      = "~> 2.53.0"
    tls      = "~> 2.1.1"
    ignition = "~> 1.2.1"
    local    = "~> 1.4.0"
  }
}
