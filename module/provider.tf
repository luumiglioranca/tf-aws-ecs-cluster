########################################################################################################
#                                                                                                      #
#                                     CONNECT PROVIDER - AWS    :)                                     #
#                                                                                                      #
########################################################################################################

provider "aws" {
  #Região onde será configurado seu recurso. Deixei us-east-1 como default
  region = "us-east-1"

  #Conta mãe que será responsável pelo provisionamento do recurso.
  profile = ""

  #Assume Role necessária para o provisionamento de recurso, caso seja via role.
  assume_role {
    role_arn = "" #Role que será assumida pela sua conta principal :)
  }
}

#Configurações de backend, neste caso para armazenar o estado do recurso via Bucket S3.
terraform {
  backend "s3" {
    #Profile (conta) de onde está o bucket que você irá armazenar seu tfstate 
    profile = ""

    #Nome do Bucket
    bucket = ""

    #Caminho da chave para o recurso que será criado
    key = "caminho-da-chave/exemplo/terraform.tfstate"

    #Região onde será configurado seu recurso. Deixei us-east-1 como default
    region = "us-east-1"

    #Valores de segurança. Encriptação, Validação de credenciais e Check da API.
    encrypt                     = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

########################################################################################################
#                                                                                                      #
#                                     DECLARAÇÃO DE VARIÁVEIS LOCAIS   :)                              #
#                                                                                                      #
########################################################################################################

locals {
  resource_name                = ""
  vpc_id                       = ""
  account_id                   = ""
  region                       = ""
  cluster_type                 = ""
  minimum_scaling_step_size_cp = ""
  maximum_scaling_step_size_cp = ""
  asg_min_size                 = ""
  asg_max_size                 = ""
  asg_desired_capacity         = ""
  image_id                     = ""
  instance_type                = ""
  domain_name                  = ""
  cidr_blocks                  = [""]

  default_tags = {
    Area     = ""
    Ambiente = ""
    SubArea  = ""
  }

  ##################################################################################################
  #                                                                                                #
  #        VARIÁVEIS DEFAULT - NÃO É NECESSÁRIO ALTERAR NENHUM VALOR PARA O PROVISIONAMENTO ;)     #
  #                                                                                                #
  ##################################################################################################

  /* CONFIGURAÇÕES INGRESS RULE */
  description         = "Acesso Interno - VPC Local"
  from_port           = "0"
  to_port             = "65535"
  protocol            = "tcp"
  security_group_type = "ingress"
  tcp_protocol        = "tcp"

  # CONFIGURAÇÕES DO ECS CLUSTER
  status_cp                 = "ENABLED"
  target_capacity           = "60"
  instance_warmup_period_cp = "60"

  # CONFIGIRAÇÕES DO AUTO SCALLING
  asg_health_check_type         = "EC2"
  asg_health_check_grace_period = "300"
  asg_default_cooldown          = "300"
  maximum_healthy_percent       = "300"
  asg_scale_in_protection       = "true"
  asg_protect_from_scale_in     = "true"

  # CONFIGURAÇÕES DO LAUNCH CONFIGURATION
  associate_public_ip_address = "true"
  target_value                = "false"
  enable_monitoring           = "true"
  retention_in_days           = "7"

  #CONFIGURAÇÕES DO VOLUME (DISK)
  volume_type           = "gp3"
  volume_size           = "50"
  delete_on_termination = "true"
  encrypted             = "true"
  throughput            = "300"
}
