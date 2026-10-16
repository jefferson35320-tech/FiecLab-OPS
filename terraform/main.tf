# 1. Criação do cluster Minikube
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

# 2. Salva os dados de saída em um arquivo JSON local
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

# 3. Automação de deploy e port-forward persistente
resource "null_resource" "k8s_deploy" {
  triggers = {
    script_hash      = filemd5("${path.module}/scripts/deploy.sh")
    backend_manifest = filemd5("${path.module}/scripts/k8s/backend/deployment.yaml")
    backend_secret   = filemd5("${path.module}/scripts/k8s/backend/secret.yaml")
  }

  depends_on = [
    minikube_cluster.custom_cluster,
    local_file.outputs_file
  ]

  # Provisioner 1: Aplica os manifestos via deploy.sh
  provisioner "local-exec" {
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]

    environment = {
      CLUSTER_NAME = minikube_cluster.custom_cluster.cluster_name
    }

    command = "${path.module}/scripts/deploy.sh ${var.cluster_name}"
  }

  # Provisioner 2: Aguarda os Pods e inicia o port-forward desacoplado no Windows
  provisioner "local-exec" {
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]

    command = <<EOT
      echo "⏳ Aguardando o Deployment e os Pods ficarem 100% Ready..."
      minikube -p ${var.cluster_name} kubectl -- rollout status deployment/backend-deployment --timeout=180s

      echo "🚀 Pods prontos! Iniciando o port-forward persistente..."
      cmd.exe /c "start /B minikube -p ${var.cluster_name} kubectl -- port-forward service/backend-service --address 0.0.0.0 8080:8080"
    EOT
  }

  # Provisioner 3: Encerra o port-forward ao rodar 'terraform destroy'
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]
    command     = "taskkill /F /IM kubectl.exe || true"
  }
}