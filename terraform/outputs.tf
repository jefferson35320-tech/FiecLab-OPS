output "cluster_name" {
  description = "Nome do cluster criado"
  value       = minikube_cluster.custom_cluster.cluster_name
}

output "cluster_host" {
  description = "Endereço host/IP do API Server do Minikube"
  value       = minikube_cluster.custom_cluster.host
}

output "client_certificate" {
  description = "Certificado de cliente para o cluster"
  value       = minikube_cluster.custom_cluster.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Chave do certificado de cliente"
  value       = minikube_cluster.custom_cluster.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Certificado da Autoridade Certificadora (CA)"
  value       = minikube_cluster.custom_cluster.cluster_ca_certificate
  sensitive   = true
}