# 1. Cria o Cluster
resource "minikube_cluster" "client_cluster" {
  driver       = "docker"
  cluster_name = "${var.client_name}-cluster"
  memory       = "4096"
  cpus         = "2"
  addons       = ["default-storageclass", "storage-provisioner", "ingress"]
}

# 2. (NOVO) Espera 90 segundos para o Ingress acordar
resource "time_sleep" "wait_for_ingress" {
  # Só começa a contar DEPOIS do cluster ser criado
  depends_on = [minikube_cluster.client_cluster]

  create_duration = "90s" 
}

# 3. Provider Kubernetes
provider "kubernetes" {
  host                   = minikube_cluster.client_cluster.host
  client_certificate     = minikube_cluster.client_cluster.client_certificate
  client_key             = minikube_cluster.client_cluster.client_key
  cluster_ca_certificate = minikube_cluster.client_cluster.cluster_ca_certificate
}

# 4. Módulo da Aplicação
module "odoo_stack" {
  source   = "./modules/odoo"
  for_each = toset(var.environments)

  client_name = var.client_name
  env_name    = each.key

  # (IMPORTANTE) O módulo agora espera pelo TEMPO, não só pelo cluster
  depends_on = [time_sleep.wait_for_ingress]
}