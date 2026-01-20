resource "minikube_cluster" "Nike_cluster" {
  driver       = "docker"         
  cluster_name = "nike-cluster"
  memory       = "1024" 
  cpus         = "2"
  addons = [
    "default-storageclass",
    "storage-provisioner",
    "ingress"
  ]
}