resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

  values = [
    "${file("jenkins-values.yaml")}"
  ]

  set_sensitive {
    name  = "adminUser"
    value = var.jenkins_admin_user
  }

  set_sensitive {
    name  = "adminPassword"
    value = var.jenkins_admin_password
  }
}

variable "create_cluster_primary_security_group_tags" {
  description = "Indicates whether or not to tag the cluster's primary security group. This security group is created by the EKS service, not the module, and therefore tagging is handled after cluster creation"
  type        = bool
  default     = false
}