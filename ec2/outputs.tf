output "instance_ids" {
  value = [for i in aws_instance.ec2_instance : i.id]
}

output "public_ips" {
  value = [for i in aws_instance.ec2_instance : i.public_ip]
}

output "names" {
  value = [for i in aws_instance.ec2_instance : i.tags.Name]
}
