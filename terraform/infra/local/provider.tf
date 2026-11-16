terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.67.0"
    }
  }

  backend "s3" {
    bucket       = "eks-platform-backend"
    key          = "tf-state-deploy"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

    endpoints = {
      s3 = "http://localhost:4566"
    }

    use_path_style              = true # Note: not s3_use_path_style
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"


  skip_credentials_validation = true # Skip validaiton with real STS
  skip_requesting_account_id  = true # Dont look up real accc
  skip_metadata_api_check     = true # Stops looking for ec2 creds
  s3_use_path_style           = true # Sends s3 requsts to 4566/bucket-name


  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    sts      = "http://localhost:4566"
    ec2      = "http://localhost:4566"  
    eks      = "http://localhost:4566"
    iam      = "http://localhost:4566"
    route53  = "http://localhost:4566"
    ecr      = "http://localhost:4566"
  }
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:us-east-1:000000000000:cluster/eks-platform-cluster"
  }
}