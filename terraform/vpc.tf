module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.2"

  name        = "assessment-vpc"
  environment = "dev"
}
