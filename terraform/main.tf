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
# 3. Automação do Backend
resource "null_resource" "k8s_backend_deploy" {
  triggers = {
    script_hash      = filemd5("${path.module}/scripts/deploy.sh")
    backend_manifest = filemd5("${path.module}/scripts/k8s/backend/deployment.yaml")
    backend_secret   = filemd5("${path.module}/scripts/k8s/backend/secret.yaml")
  }

  depends_on = [
    minikube_cluster.custom_cluster,
    local_file.outputs_file
  ]

  # Aplica os manifestos do Backend e aguarda disponibilidade
  provisioner "local-exec" {
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]

    environment = {
      CLUSTER_NAME = minikube_cluster.custom_cluster.cluster_name
    }

    command = <<EOT
      echo "🚀 Aplicando manifestos do Backend..."
      ${path.module}/scripts/deploy.sh ${var.cluster_name}

      echo "⏳ Aguardando o Backend ficar 100% Ready..."
      minikube -p ${var.cluster_name} kubectl -- rollout status deployment/backend-deployment --timeout=180s

      echo "🔌 Iniciando port-forward do Backend em background..."
      nohup minikube -p ${var.cluster_name} kubectl -- port-forward service/backend-service --address 0.0.0.0 8080:8080 > /dev/null 2>&1 &
    EOT
  }

  # Encerra o port-forward do backend ao rodar 'terraform destroy'
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]
    command     = "taskkill /F /IM kubectl.exe || true"
  }
}

# 4. Automação do Frontend (Apenas após o sucesso do Backend)

resource "null_resource" "k8s_frontend_deploy" {
  triggers = {
    frontend_manifest = filemd5("${path.module}/scripts/k8s/frontend/deployment.yaml")
    tfvars_hash       = md5(jsonencode([
      var.firebase_api_key,
      var.firebase_auth_domain,
      var.firebase_project_id,
      var.firebase_storage_bucket,
      var.firebase_messaging_sender_id,
      var.firebase_app_id,
      var.firebase_measurement_id
    ]))
  }

  depends_on = [
    null_resource.k8s_backend_deploy
  ]

  provisioner "local-exec" {
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]

    command = <<EOT
      cat <<EOF "-c"| minikube -p ${var.cluster_name} kubectl -- apply -f -
      ${templatefile("${path.module}/scripts/k8s/frontend/deployment.yaml", {
        FIREBASE_API_KEY            = var.firebase_api_key
        FIREBASE_AUTH_DOMAIN        = var.firebase_auth_domain
        FIREBASE_PROJECT_ID         = var.firebase_project_id
        FIREBASE_STORAGE_BUCKET     = var.firebase_storage_bucket
        FIREBASE_MESSAGING_SENDER_ID = var.firebase_messaging_sender_id
        FIREBASE_APP_ID             = var.firebase_app_id
        FIREBASE_MEASUREMENT_ID     = var.firebase_measurement_id
      })}
EOF

      echo "⏳ Aguardando o Frontend ficar 100% Ready..."
      minikube -p ${var.cluster_name} kubectl -- rollout status deployment/frontend-deployment --timeout=180s

      echo "🔌 Iniciando port-forward do Frontend em background..."
      nohup minikube -p ${var.cluster_name} kubectl -- port-forward service/frontend-service --address 0.0.0.0 3000:80 > /dev/null 2>&1 &
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]
    command     = "taskkill /F /IM kubectl.exe || true"
  }
}