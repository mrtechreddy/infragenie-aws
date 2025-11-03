# =========================================================
# Outputs
# =========================================================
output "instances" {
  value = {
    for name, instance in aws_instance.ec2_instance :
    name => {
      id   = instance.id
      type = instance.instance_type
      key  = instance.key_name
      sgs  = [
        for sg_key, sg_val in aws_security_group.instance_sg :
        sg_val.name if sg_key == name
      ]
      ip   = instance.public_ip
    }
  }
}
