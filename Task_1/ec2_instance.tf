data "aws_vpc" "default" {
  default = true
  state   = "available"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

module "ec2_fleet" {
  source = "./modules/ec2-fleet"

  #ami_id             = "ami-0123456789abcdef0"  ## Defaulted to Amazon Linux Latest
  #subnet_id          = "subnet-0123456789abcdef0"
  security_group_ids = [data.aws_security_group.default.id]
  environment        = "production"
  owner              = "platform-team"

  instances = {
    web-1 = {
      instance_type    = "t3.micro"
      root_volume_type = "gp3"
      root_volume_size = 20
      key_name         = "web-key"
      root_volume_iops = null
    }
    app-1 = {
      instance_type    = "t3.small"
      root_volume_type = "gp2"
      root_volume_size = 30
      key_name         = "app-key"
      root_volume_iops = null
    }
    worker-1 = {
      instance_type    = "m6i.large"
      root_volume_type = "gp3"
      root_volume_size = 50
      key_name         = "worker-key"
      root_volume_iops = null
    }
    analytics-1 = {
      instance_type    = "r6i.large"
      root_volume_type = "io1"
      root_volume_size = 100
      key_name         = "analytics-key"
      root_volume_iops = 3000
    }
    prod-db = {
      instance_type    = "m6i.xlarge"
      root_volume_type = "io2"
      root_volume_size = 200
      key_name         = "prod-db-key"
      root_volume_iops = 5000
    }
  }
}
