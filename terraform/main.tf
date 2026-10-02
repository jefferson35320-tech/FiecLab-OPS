# Criação do cluster Minikube com os novos parâmetros
resource "minikube_cluster" "custom_cluster" {
  cluster_name       = var.cluster_name
  driver             = var.driver
  memory             = var.memory
  cpus               = var.cpus
  nodes              = var.nodes
  kubernetes_version = var.kubernetes_version
  container_runtime  = var.container_runtime
  cni                = var.cni
  base_image         = var.base_image
  addons             = var.addons
}

# Salva os dados de saída em um arquivo local em formato JSON
resource "local_file" "outputs_file" {
  filename = "${path.module}/cluster_outputs.json"
  content = jsonencode({
    cluster_name           = minikube_cluster.custom_cluster.cluster_name
    host                   = minikube_cluster.custom_cluster.host
    client_certificate     = minikube_cluster.custom_cluster.client_certificate
    client_key             = minikube_cluster.custom_cluster.client_key
    cluster_ca_certificate = minikube_cluster.custom_cluster.cluster_ca_certificate
  })
}

resource "null_resource" "k8s_deploy" {
  triggers = {
    script_hash = filemd5("${path.module}/scripts/deploy.sh") # Corrigido aqui
    backend_manifest   = filemd5("${path.module}/scripts/k8s/backend/deployment.yaml")
    backend_secret     = filemd5("${path.module}/scripts/k8s/backend/secret.yaml")
  }

  depends_on = [
    minikube_cluster.custom_cluster,
    local_file.outputs_file
  ]

  provisioner "local-exec" {
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]

    environment = {
      CLUSTER_NAME = minikube_cluster.custom_cluster.cluster_name
    }

    command = "${path.module}/scripts/deploy.sh ${var.cluster_name}"
  }
}