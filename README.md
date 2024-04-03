# AWS Terraform - ECS Cluster
Este módulo irá provisionar os seguintes recursos:

1: [ECS Cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)

2: [Capacity Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider)

3: [Key Pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)

4: [Auto Scalling Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)

5: [Launch Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration)

6: [EBS Volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume)

7: [Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

8: [ECR Repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

**_Importante:_** A documentação da haschicorp é bem completa, se quiserem dar uma olhada, segue o link do glossário com todos os recursos do terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Variables Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | --------- | ---- | ------- |
| cluster_name | O nome do cluster. | `yes` | `string` | ` ` |
| cluster_type | O tipo que será inicializado o cluster. Valores validos, FARGATE e EC2. | `yes` | `string` | ` ` |
| task_definition | O bloco task_definition é necessario para rodar containers Dockers em ECS. Segue detalhes abaixo. | `yes` | `list` | `[ ]` |
| capacity_providers | Lista de um ou mais provedores de capacidade para associar ao cluster. Valores validos, FARGATE e FARGATE_SPOT. | `no` | `list` | `[ ]` |
| default_capacity_provider_strategy | Capacity Provider Strategy para ser usado por default para o cluster. Segue detalhes abaixo.  | `no` | `list` | `[ ]` |
| cluster_resources | Construção da EC2 Instance para o EC2 Cluster. Obrigatorio quando o valor de `cluster_type` for EC2. | `no` | `list` | `[ ]` |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Variables Inputs
| Name | Description | 
| ---- | ----------- |
| cluster_name | O nome do cluster ECS criado. |

**_Importante:_** Qualquer dificuldade encontrada, melhoria ou se precisarem alterar alguma linha de código, só entrar em contato que te ajudo <3
