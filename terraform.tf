terraform {
  cloud {
    organization = "earthquake_pipeline_proj"

    workspaces {
      project = "Earthquake Pipeline"
      name = "earthquake-pipeline"
    }
  }  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.38.0"
    }
  }
  required_version = "~> 1.14.8"
}