#################################################################################################
#                                                                                               #
#                                CLUSTER ECS + ATTACH CAPACITY PROVIDER                         #
#                                                                                               #
#################################################################################################

resource "aws_ecs_cluster" "main" {
  count = var.create ? 1 : 0

  name = var.cluster_name
  #cluster_type = var.cluster_type

  dynamic "setting" {
    for_each = var.setting
    content {
      name  = lookup(setting.value, "name", null)
      value = lookup(setting.value, "value", null)
    }
  }

  tags = var.default_tags
}

#################################################################################################
#                                                                                               #
#                                CAPACITY PROVIDER (AUTO SCALLING GROUP [EC2])                  #
#                                                                                               #
#################################################################################################

/*resource "aws_ecs_capacity_provider" "ec2" {
  depends_on = [aws_ecs_cluster.main]

  count = var.create && var.cluster_type == "EC2" ? length(var.capacity_provider) : 0

  name = lookup(var.capacity_provider[count.index], "name_capacity_provider", null)

  dynamic "auto_scaling_group_provider" {
    for_each = lookup(var.capacity_provider[count.index], "auto_scaling_group_provider", null)

    content {
      auto_scaling_group_arn         = aws_autoscaling_group.ec2.0.arn
      managed_termination_protection = lookup(auto_scaling_group_provider.value, "managed_termination_protection", null)

      dynamic "managed_scaling" {
        for_each = lookup(auto_scaling_group_provider.value, "managed_scaling", null)

        content {
          minimum_scaling_step_size = lookup(managed_scaling.value, "minimum_scaling_step_size", null)
          maximum_scaling_step_size = lookup(managed_scaling.value, "maximum_scaling_step_size", null)
          status                    = lookup(managed_scaling.value, "status", null)
          target_capacity           = lookup(managed_scaling.value, "target_capacity", null)
          instance_warmup_period    = lookup(managed_scaling.value, "instance_warmup_period", null)
        }
      }
    }
  }
}*/

#################################################################################################
#                                                                                               #
#                             AUTO SCALLING GROUP - ECS CLUSTER [EC2]                           #
#                                                                                               #
#################################################################################################

resource "aws_autoscaling_group" "ec2" {
  count = var.create && var.cluster_type == "EC2" ? length(var.autoscaling_group) : 0

  name                      = "${upper(var.cluster_name)}-ASG"
  launch_configuration      = aws_launch_configuration.ec2.0.name
  min_size                  = lookup(var.autoscaling_group[count.index], "min_size", null)
  max_size                  = lookup(var.autoscaling_group[count.index], "max_size", null)
  desired_capacity          = lookup(var.autoscaling_group[count.index], "desired_capacity", null)
  health_check_type         = lookup(var.autoscaling_group[count.index], "health_check_type", null)
  health_check_grace_period = lookup(var.autoscaling_group[count.index], "health_check_grace_period", null)
  default_cooldown          = lookup(var.autoscaling_group[count.index], "default_cooldown", null)
  protect_from_scale_in     = lookup(var.autoscaling_group[count.index], "scale_in_protection", null)
  vpc_zone_identifier       = lookup(var.autoscaling_group[count.index], "vpc_zone_identifier", null)
  wait_for_capacity_timeout = lookup(var.autoscaling_group[count.index], "wait_for_capacity_timeout", null)

tag {
    key                 = "Name"
    value               = "${upper(var.cluster_name)}-ASG"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_launch_configuration.ec2]

}

#################################################################################################
#                                                                                               #
#                             LAUNCH CONFIGURATION - ECS CLUSTER [EC2]                          #
#                                                                                               #
#################################################################################################

resource "aws_launch_configuration" "ec2" {
  count = var.create && var.cluster_type == "EC2" ? length(var.launch_configuration) : 0

  name_prefix          = "LC-${upper(var.cluster_name)}"
  image_id             = var.launch_configuration[count.index]["image_id"]
  instance_type        = var.launch_configuration[count.index]["instance_type"]
  security_groups      = var.launch_configuration[count.index]["security_groups"]
  iam_instance_profile = aws_iam_instance_profile.ec2.0.name

  user_data = <<EOF
    #!/bin/bash
    yum update -y kernel
    yum update -y python-requests
    yum update -y python3-pip
    yum update -y libcap
    yum update -y
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
    echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config
  EOF

  associate_public_ip_address = lookup(var.launch_configuration[count.index], "associate_public_ip_address", null)
  enable_monitoring           = lookup(var.launch_configuration[count.index], "enable_monitoring", null)
  ebs_optimized               = lookup(var.launch_configuration[count.index], "ebs_optimized", null)
  spot_price                  = lookup(var.launch_configuration[count.index], "spot_price", null)
  key_name                    = var.launch_configuration[count.index]["key_name"]

  dynamic "root_block_device" {
        for_each = length(keys(lookup(var.launch_configuration[count.index], "root_block_device", {}))) == 0 ? [] : [lookup(var.launch_configuration[count.index], "root_block_device", {})]
    
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
    }
  }

  lifecycle {
    create_before_destroy = "true"
  }

  depends_on = [aws_iam_role.ec2]

}

############################################################################################
#                                                                                          #
#                         Políticas de escalonamento (AUTO SCALLING)                       #
#                                                                                          # 
############################################################################################

resource "aws_autoscaling_policy" "policy_for_cluster" {
  name                   = "policy-as-${var.cluster_name}"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.ec2.0.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 90
  }
}

############################################################################################
#                                                                                          #
#                              BOOTSTRAP MONSTRÃO VÉIO DE GUERRA                           #
#                                                                                          # 
############################################################################################

data "template_file" "bootstrap" {
  count = var.create && var.cluster_type == "EC2" ? length(var.cluster_resources) : 0

  template = file("${path.module}/template/bootstrap")
  vars = {
    cluster_name = var.cluster_name
  }
}