variable "cluster_name" {
  type        = string
  description = "Nome do cluster Minikube"
  default     = "minikube-custom"
}

variable "driver" {
  type        = string
  description = "Driver de virtualização/containerização"
  default     = "docker"
}

variable "memory" {
  type        = string
  description = "Quantidade de memória RAM alocada para o cluster"
  default     = "4000mb"
}

variable "cpus" {
  type        = number
  description = "Quantidade de CPUs alocadas para o cluster"
  default     = 2
}

variable "nodes" {
  type        = number
  description = "Quantidade de nós do cluster Minikube"
  default     = 1
}

variable "kubernetes_version" {
  type        = string
  description = "Versão do Kubernetes a ser instalada"
  default     = "v1.37.0"
}

variable "container_runtime" {
  type        = string
  description = "Runtime de containers interno do Kubernetes"
  default     = "containerd"
}

variable "cni" {
  type        = string
  description = "Plugin CNI de rede do Kubernetes"
  default     = "flannel"
}

variable "base_image" {
  type        = string
  description = "Imagem base do container KIC (kicbase)"
  default     = "gcr.io/k8s-minikube/kicbase:v0.0.51"
}

variable "addons" {
  type        = list(string)
  description = "Lista de addons do Minikube ativados no boot"
  default = [
    "metrics-server",
    "dashboard",
    "default-storageclass",
    "storage-provisioner"
  ]
}
variable "firebase_api_key" {
  description = "Chave da API do Firebase para a aplicação frontend"
  type        = string
  default     = ""
}

variable "firebase_auth_domain" {
  description = "Domínio de autenticação do Firebase"
  type        = string
  default     = ""
}

variable "firebase_project_id" {
  description = "ID do projeto Firebase"
  type        = string
  default     = ""
}

variable "firebase_storage_bucket" {
  description = "Bucket de armazenamento do Firebase"
  type        = string
  default     = ""
}

variable "firebase_messaging_sender_id" {
  description = "ID do remetente de mensagens do Firebase"
  type        = string
  default     = ""
}

variable "firebase_app_id" {
  description = "ID da aplicação no Firebase"
  type        = string
  default     = ""
}

variable "firebase_measurement_id" {
  description = "ID de medição do Google Analytics no Firebase"
  type        = string
  default     = ""
}