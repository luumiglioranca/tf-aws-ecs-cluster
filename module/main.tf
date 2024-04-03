#################################################################################################
#                                                                                               #
#                                       ECS CLUSTER [EC2]                                       #
#                                                                                               #
#################################################################################################

module "ecs_cluster" {
  source = "git@github.com:luumiglioranca/tf-aws-ecs-cluster.git//resource"

  cluster_name = local.resource_name
  cluster_type = local.cluster_type

  setting = [{
    name  = "containerInsights"
    value = "enabled"
  }]

  ecs_capacity_providers = ["${local.resource_name}-CP"]

  #################################################################################################
  #                                                                                               #
  #                                CAPACITY PROVIDER - ECS CLUSTER [EC2]                          #
  #                                                                                               #
  #################################################################################################

  capacity_provider = [{
    name_capacity_provider = "${local.resource_name}-CP"

    auto_scaling_group_provider = [{
      managed_termination_protection = "ENABLED"

      managed_scaling = [{
        minimum_scaling_step_size = "${local.maximum_scaling_step_size_cp}"
        maximum_scaling_step_size = "${local.minimum_scaling_step_size_cp}"
        status                    = "${local.status_cp}"
        target_capacity           = "${local.target_capacity}"
        instance_warmup_period    = "${local.instance_warmup_period_cp}"
      }]
    }]
  }]

  #################################################################################################
  #                                                                                               #
  #                             AUTO SCALLING GROUP - ECS CLUSTER [EC2]                           #
  #                                                                                               #
  #################################################################################################

  autoscaling_group = [{
    min_size                  = "${local.asg_min_size}"
    max_size                  = "${local.asg_max_size}"
    desired_capacity          = "${local.asg_desired_capacity}"
    health_check_type         = "${local.asg_health_check_type}"
    health_check_grace_period = "${local.asg_health_check_grace_period}"
    default_cooldown          = "${local.asg_default_cooldown}"
    protect_from_scale_in     = "${local.asg_protect_from_scale_in}"
    scale_in_protection       = "${local.asg_scale_in_protection}"

    vpc_zone_identifier = [
      data.aws_subnet.priv_1a.id,
      data.aws_subnet.priv_1b.id,
      data.aws_subnet.priv_1c.id
    ]

    security_groups = [module.security_group.security_group_id]

  }]

  #################################################################################################
  #                                                                                               #
  #                             LAUNCH CONFIGURATION - ECS CLUSTER [EC2]                          #
  #                                                                                               #
  #################################################################################################

  launch_configuration = [{
    image_id                    = "${local.image_id}"
    instance_type               = "${local.instance_type}"
    security_groups             = [module.security_group.security_group_id]
    associate_public_ip_address = "${local.associate_public_ip_address}"
    enable_monitoring           = "${local.enable_monitoring}"
    key_name                    = aws_key_pair.main.key_name
  }]

  root_block_device = {
    volume_type           = "${local.volume_type}"
    volume_size           = "${local.volume_size}"
    delete_on_termination = "${local.delete_on_termination}"
    encrypted             = "${local.encrypted}"
    throughput            = "${local.throughput}"
  }

  log_driver = [
    {
      log_name          = "${local.resource_name}/svc-${local.resource_name}"
      retention_in_days = "${local.retention_in_days}"
      default_tags      = local.default_tags
    }
  ]
}

#################################################################################################
#                                                                                               #
#                                     AWS KEY PAIR [ECS - EC2]                                  #
#                                                                                               #
#################################################################################################

resource "aws_key_pair" "main" {
  key_name   = lower(local.resource_name)
  public_key = data.tls_public_key.ecs_cluster_public_key.public_key_openssh
}

resource "tls_private_key" "ecs_cluster_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "ecs_cluster_public_key" {
  private_key_pem = tls_private_key.ecs_cluster_private_key.private_key_pem
}

############################################################################################
#                                                                                          #
#                         MÓDULO PARA CRIAÇÃO DO SECURITY GROUP :)                         #
#                                                                                          #
############################################################################################

module "security_group" {

  source = "git@github.com:luumiglioranca/tf-aws-security-group.git//resource"

  description         = "Security Group para o ${local.resource_name} :)"
  security_group_name = "${local.resource_name}-sg"
  vpc_id              = data.aws_vpc.main.id

  ingress_rule = [
    {
      description = "${local.description}"
      type        = "${local.security_group_type}"
      from_port   = "${local.from_port}"
      to_port     = "${local.to_port}"
      protocol    = "${local.tcp_protocol}"
      cidr_blocks = [data.aws_vpc.main.cidr_block]
    }
  ]

  default_tags = merge({

    Name = "sg-${local.resource_name}"

    },

    local.default_tags

  )
}

#################################################################################################
#                                                                                               #
#                                ECR REPOSITORY - ECS CLUSTER [EC2]                             #
#                                                                                               #
#################################################################################################

module "ecr_repository" {
  source = "git@github.com:luumiglioranca/tf-aws-ecr-repository.git//resource"

  name_repo            = local.resource_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration = [{
    scan_on_push = "true"
  }]

  #docker_source_path  = "docker-image/"
  #docker_image_name     = local.resource_name
  #docker_image_tag      = local.image_tags

  lifecycle_policy = [
    {
      rulePriority      = "1"
      ruleActionType    = "expire"
      ruleDescription   = "Keep last 30 images"
      ruleTagStatus     = "tagged"
      ruleTagPrefixList = "v"
      ruleCountType     = "imageCountMoreThan"
      ruleCountUnit     = "days"
      ruleCountNumber   = "30"
    }
  ]

  default_tags = local.default_tags

}

/*#################################################################################################
#                                                                                               #
#                                ECR REPOSITORY - ECS CLUSTER [EC2]                             #
#                                                                                               #
#################################################################################################

module "ecr_repository" {
  source = "git@github.com:uoledtech-infra-as-code/tf-aws-ecr-repository"

  name_repo            = local.resource_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration = [{
    scan_on_push = "true"
  }]

  #docker_source_path  = "docker-image/"
  #docker_image_name     = local.resource_name
  #docker_image_tag      = local.image_tags

  lifecycle_policy = [
    {
      rulePriority      = "1"
      ruleActionType    = "expire"
      ruleDescription   = "Keep last 30 images"
      ruleTagStatus     = "tagged"
      ruleTagPrefixList = "v"
      ruleCountType     = "imageCountMoreThan"
      ruleCountUnit     = "days"
      ruleCountNumber   = "30"
    }
  ]

  default_tags = local.default_tags

}*/

/*############################################################################################
#                                                                                          #
#                              BOOTSTRAP MONSTRÃO VÉIO DE GUERRA                           #
#                                                                                          # 
############################################################################################

data "template_file" "bootstrap" {
  count = var.create && var.cluster_type == "EC2" ? length(var.cluster_resources) : 0

  template = file("bootstrap")

  vars = {
    resource_name = local.resource_name
  }

}*/