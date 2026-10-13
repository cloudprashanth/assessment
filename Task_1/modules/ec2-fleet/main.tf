resource "random_shuffle" "subnet_order" {
  input        = data.aws_subnets.default_vpc.ids
  result_count = length(data.aws_subnets.default_vpc.ids)

  # Re-select if the set of available subnet IDs changes.
  keepers = {
    subnet_ids = join(",", sort(data.aws_subnets.default_vpc.ids))
  }
}

locals {
  instance_names = sort(keys(var.instances))
  subnet_count   = length(random_shuffle.subnet_order.result)

  instance_subnets = {
    for index, name in local.instance_names :
    name => random_shuffle.subnet_order.result[
      index % local.subnet_count
    ]
  }

  protected_instance_name = "prod-db"

  unprotected_instances = {
    for name, config in var.instances :
    name => config
    if name != local.protected_instance_name
  }

  protected_instances = {
    for name, config in var.instances :
    name => config
    if name == local.protected_instance_name
  }
}

resource "aws_instance" "this" {
  for_each = local.unprotected_instances

  ami                    = data.aws_ami.amazon.id
  instance_type          = each.value.instance_type
  subnet_id              = local.instance_subnets[each.key]
  vpc_security_group_ids = var.security_group_ids
  key_name               = each.value.key_name

  root_block_device {
  volume_type = each.value.root_volume_type
  volume_size = each.value.root_volume_size
  iops        = each.value.root_volume_iops
}

  tags = {
    Name        = each.key
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_instance" "protected" {
  for_each = local.protected_instances

  ami                    = data.aws_ami.amazon.id
  instance_type          = each.value.instance_type
  subnet_id              = local.instance_subnets[each.key]
  vpc_security_group_ids = var.security_group_ids
  key_name               = each.value.key_name

  root_block_device {
  volume_type = each.value.root_volume_type
  volume_size = each.value.root_volume_size
  iops        = each.value.root_volume_iops
}

  tags = {
    Name        = each.key
    Environment = var.environment
    Owner       = var.owner
  }

  lifecycle {
    prevent_destroy = true
  }
}