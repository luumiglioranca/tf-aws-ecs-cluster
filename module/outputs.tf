output "cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_cluster_private_key" {
  value     = tls_private_key.ecs_cluster_private_key.private_key_pem
  sensitive = true
}

output "ecs_cluster_public_key" {
  value     = data.tls_public_key.ecs_cluster_public_key.public_key_pem
  sensitive = true
}