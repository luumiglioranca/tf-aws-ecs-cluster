#################################################################################################
#                                                                                               #
#              IAM ROLE - POLICY - ATTACHMENT - INSTANCE PROFILE - ECS CLUSTER [EC2]            #
#                                                                                               #
#################################################################################################

data "aws_iam_policy_document" "ec2" {
  count = var.create && var.cluster_type == "EC2" ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#################################################################################################
#                                                                                               #
#                                         INSTANTE PROFILE                                      #
#                                                                                               #
#################################################################################################

resource "aws_iam_instance_profile" "ec2" {
  count = var.create && var.cluster_type == "EC2" ? 1 : 0

  name = "${var.cluster_name}-Role"
  role = aws_iam_role.ec2.0.name
}

#################################################################################################
#                                                                                               #
#                             IAM ROLES E POLICES PARA A >>> EC2 <<<                            #
#                                                                                               #
#################################################################################################

resource "aws_iam_role" "ec2" {
  count = var.create && var.cluster_type == "EC2" ? 1 : 0

  name               = "${var.cluster_name}-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2.0.json
  path               = "/"
  description        = var.description
  tags = var.default_tags
}

#################################################################################################
#                                                                                               #
#                                         POLICY ATTACHMENT                                     #
#                                                                                               #
#################################################################################################

resource "aws_iam_role_policy_attachment" "ec2_0" {
  count = var.create && var.cluster_type == "EC2" ? 1 : 0

  role       = aws_iam_role.ec2.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ec2_1" {
  count = var.create && var.cluster_type == "EC2" ? 1 : 0

  role       = aws_iam_role.ec2.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}


############################################################################################
#                                                                                          #
#                        AssumeRole (IAM ROLE) - ECS SCALE APPLICATION                     #
#                                                                                          # 
############################################################################################

resource "aws_iam_role" "ecs_autoscale_role" {
  name = lower("ecs-scale-application-${var.cluster_name}")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-autoscale" {
  role       = aws_iam_role.ecs_autoscale_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

