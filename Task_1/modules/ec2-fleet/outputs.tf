locals {
  all_instances = merge(
    aws_instance.this,
    aws_instance.protected
  )
}

output "instance_ids" {
  description = "Map of instance name to EC2 instance ID."
  value = {
    for name, instance in local.all_instances :
    name => instance.id
  }
}

output "private_ips" {
  description = "Map of instance name to private IP address."
  value = {
    for name, instance in local.all_instances :
    name => instance.private_ip
  }
}