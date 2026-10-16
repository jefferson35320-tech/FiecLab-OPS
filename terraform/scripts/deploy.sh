#!/usr/bin/env bash
set -e

# --------------------------------------------------
# PARÂMETROS E ALIASES
# --------------------------------------------------
CLUSTER_NAME=${1:-"minikube-custom"}

shopt -s expand_aliases
alias k="minikube -p ${CLUSTER_NAME} kubectl --"

# --------------------------------------------------
# OBTÉM O IP DO HOST (Compatível com Windows / Git Bash)
# --------------------------------------------------
echo "🔍 Obtendo o IP do host dentro do Minikube para resolução de DNS..."

HOST_IP=$(minikube -p ${CLUSTER_NAME} ssh "getent hosts host.minikube.internal" 2>/dev/null | awk '{print $1}' | tr -d '\r')

if [ -z "$HOST_IP" ]; then
    HOST_IP="172.17.0.1"
fi

export HOST_IP
echo "📌 IP do Host detectado: ${HOST_IP}"

# --------------------------------------------------
# CONFIGURAÇÃO DE CREDENCIAIS E DEPLOY KUBERNETES
# --------------------------------------------------
JSON_FILE="./serviceAccountKey.json"

if [ ! -f "$JSON_FILE" ]; then
  echo "❌ Erro: Arquivo $JSON_FILE não encontrado na raiz do projeto."
  exit 1
fi

echo "🔐 Convertendo credenciais do Firebase para Base64..."
export FIREBASE_CREDENTIALS_BASE64=$(base64 -w 0 "$JSON_FILE")

echo "🚀 Aplicando manifestos do Kubernetes..."

envsubst '${FIREBASE_CREDENTIALS_BASE64}' < scripts/k8s/backend/secret.yaml | k apply -f -
envsubst '${HOST_IP}' < scripts/k8s/backend/deployment.yaml | k apply -f -

# --------------------------------------------------
# AGUARDA OS PODS FICAREM PRONTOS
# --------------------------------------------------
echo "⏳ Aguardando o Deployment e os Pods ficarem 100% Ready..."
k rollout status deployment/backend-deployment --timeout=180s

# --------------------------------------------------
# LIBERAÇÃO DO SERVIÇO VIA PORT-FORWARD (BACKGROUND)
# --------------------------------------------------
echo "🚀 Pods prontos! Iniciando o port-forward em background na porta 8080..."
nohup minikube -p ${CLUSTER_NAME} kubectl -- port-forward --address 0.0.0.0 service/backend-service 8080:8080 > /dev/null 2>&1 &

echo "✅ Deploy e Port-Forward concluídos com sucesso!"
exit 0