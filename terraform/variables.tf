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