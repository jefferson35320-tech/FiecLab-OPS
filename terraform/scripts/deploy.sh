#!/usr/bin/env bash
set -e

# --------------------------------------------------
# PARÂMETROS E ALIASES
# --------------------------------------------------
# 1. Captura o nome do cluster passado como argumento ($1) pelo Terraform
CLUSTER_NAME=${1:-"minikube-custom"}

# Habilita o uso de aliases dentro de scripts Bash
shopt -s expand_aliases

# Define o alias dinamicamente usando a variável $CLUSTER_NAME
alias k="minikube -p ${CLUSTER_NAME} kubectl --"

# --------------------------------------------------
# OBTÉM O IP DO HOST (Compatível com Windows / Git Bash)
# --------------------------------------------------
echo "🔍 Obtendo o IP do host dentro do Minikube para resolução de DNS..."

# Captura o IP e remove a quebra de linha do Windows (\r)
HOST_IP=$(minikube -p ${CLUSTER_NAME} ssh "getent hosts host.minikube.internal" 2>/dev/null | awk '{print $1}' | tr -d '\r')

# Fallback se a busca falhar no Windows
if [ -z "$HOST_IP" ]; then
    HOST_IP="172.17.0.1"
fi

export HOST_IP
echo "📌 IP do Host detectado: ${HOST_IP}"

# --------------------------------------------------
# CONFIGURAÇÃO DE CREDENCIAIS E DEPLOY KUBERNETES
# --------------------------------------------------
# Caminho para o arquivo JSON de credenciais na raiz do projeto
JSON_FILE="./serviceAccountKey.json"

if [ ! -f "$JSON_FILE" ]; then
  echo "❌ Erro: Arquivo $JSON_FILE não encontrado na raiz do projeto."
  exit 1
fi

echo "🔐 Convertendo credenciais do Firebase para Base64..."
export FIREBASE_CREDENTIALS_BASE64=$(base64 -w 0 "$JSON_FILE")

echo "🚀 Aplicando manifestos do Kubernetes..."

# 1. Aplica o Secret do Backend substituindo a variável de ambiente no YAML
envsubst '${FIREBASE_CREDENTIALS_BASE64}' < scripts/k8s/backend/secret.yaml | k apply -f -

# 2. Aplica o Deployment do Backend substituindo a variável HOST_IP no YAML
envsubst '${HOST_IP}' < scripts/k8s/backend/deployment.yaml | k apply -f -

# 3. Aplica os recursos do Frontend (descomente quando for utilizar)
# envsubst < terraform/scripts/k8s/frontend/deployment.yaml | k apply -f -

# --------------------------------------------------
# LIBERAÇÃO DO SERVIÇO VIA PORT-FORWARD
# --------------------------------------------------
echo "🌐 Iniciando Port-Forward para o serviço na porta 8080..."
k port-forward --address 0.0.0.0 service/backend-service 8080:8080 

echo "✅ Deploy concluído com sucesso!"