data "aws_eks_cluster" "dev-cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "dev-cluster" {
  name = module.my-cluster.cluster_id
}