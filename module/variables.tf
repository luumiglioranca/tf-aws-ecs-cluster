variable "create" {
  type    = bool
  default = true
}
variable "cluster_type" {
  description = "permite apenas valores FARGATE e EC2. Que são compativeis com o base no tipo que precisa iniciar sua task."
  type        = string
  default     = "EC2"
}
variable "cluster_resources" {
  type    = any
  default = []
}
