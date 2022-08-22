# DEPLOY HELM CHARTS LIKE JENKINS AND EKS USING TERRAFORM 

Need some apps on that cluster really fast? Use Terraforms Helm Provider on top of their Kubernetes provider to quickly deploy EKS clusters with your apps on top
of them. In this example, I'm deploying Jenkins on EKS. It takes about 15 minutes from start to finish and minimal work. 

>Note: This is not meant for production!!

### Pre-requisites

* Terraform CLI installed or a Terraform Cloud account.
* AWS credentials configured.
* kubectl installed.

### Deployment Instructions
* Clone this repository
* Edit ```terraform.tfvars``` to match your values.
* Run a ```terraform init``` to grab providers and modules.
* Run a ```terraform plan``` to view the plan.
* Run a ```terraform_apply``` and wait 10 - 15 minutes. 
>Note: If it fails for HTTP timeout while waiting to apply the Helm chart, retry ```terraform_apply```
* Run ```aws eks --region us-east-1 update-kubeconfig --name dev-cluster``` to add the cluster context to your kubeconfig.
* Run ```kubectl get pods``` to ensure Jenkins deployed as expected.
* Run ```kubectl get svc``` to grab the AWS created DNS address for the jenkins service.
* Go to your browser and navigate to ```http://<dns-address>:8080``` Note: This may take 3 - 5 minutes to resolve while waiting for Jenkins to fully initialize. 
* Log in with the credentials you set in  ```terraform.tfvars```.

### Connecting
* Run ```aws eks --region us-east-1 update-kubeconfig --name dev-cluster``` to add the context to your kubeconfig file.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.2.6 |

## Providers

| Name | Version |
|------|---------|
| aws | 4.21.0 |
| helm | 2.6.0 |
| kubernetes | 2.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| my-cluster | terraform-aws-modules/eks/aws | 18.28.0 |

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.dev-gw](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/internet_gateway) | resource |
| [aws_route_table.dev-route-table](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/route_table) | resource |
| [aws_route_table_association.dev1-sub-to-dev-rt](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.dev2-sub-to-dev-rt](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/route_table_association) | resource |
| [aws_security_group.allow-web-traffic](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/security_group) | resource |
| [aws_subnet.dev1-subnet](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/subnet) | resource |
| [aws_subnet.dev2-subnet](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/subnet) | resource |
| [aws_vpc.dev-vpc](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/resources/vpc) | resource |
| [helm_release.jenkins](https://registry.terraform.io/providers/hashicorp/helm/2.6.0/docs/resources/release) | resource |
| [aws_eks_cluster.dev-cluster](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.dev-cluster](https://registry.terraform.io/providers/hashicorp/aws/4.21.0/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| autoscaling\_group\_desired\_capacity | The desired number of nodes the worker group should attempt to maintain. | `number` | `2` | no |
| autoscaling\_group\_max\_size | The maximum number of nodes the worker group can scale to. | `number` | `3` | no |
| autoscaling\_group\_min\_size | The minimum number of nodes the worker group can scale to. | `number` | `1` | no |
| aws\_region | The AWS region for the provider to deploy resources into. | `string` | `"us-east-1"` | no |
| cluster\_name | The name of the EKS cluster. | `string` | `"dev-cluster"` | no |
| cluster\_version | The version of the EKS cluster. | `string` | `"1.22"` | no |
| create\_cluster\_primary\_security\_group\_tags | Indicates whether or not to tag the cluster's primary security group. This security group is created by the EKS service, not the module, and therefore tagging is handled after cluster creation | `bool` | `true` | no |
| dev1\_subnet\_az | Availability Zone of the subnet 1. | `string` | `"us-east-1a"` | no |
| dev1\_subnet\_cidr\_block | CIDR block of subnet 1 to create. | `string` | `"10.0.1.0/24"` | no |
| dev1\_subnet\_nic\_private\_ip | CIDR block of subnet 1 to create. | `list(string)` | <pre>[<br>  "10.0.1.50"<br>]</pre> | no |
| dev2\_subnet\_az | Availability zone of subnet 2. | `string` | `"us-east-1b"` | no |
| dev2\_subnet\_cidr\_block | CIDR block of subnet 1 to create. | `string` | `"10.0.2.0/24"` | no |
| jenkins\_admin\_password | Admin password of the Jenkins Application. | `string` | n/a | yes |
| jenkins\_admin\_user | Admin user of the Jenkins Application. | `string` | `"admin"` | no |
| vpc\_cidr\_block | CIDR block of the VPC to create. | `string` | `"10.0.0.0/16"` | no |
| worker\_group\_instance\_type | The instance type of the worker group nodes. Must be large enough to support the amount of NICS assigned to pods. | `list(string)` | <pre>[<br>  "t3.medium"<br>]</pre> | no |
| worker\_group\_name | The name of the EKS worker node group. | `string` | `"dev-worker-group-1"` | no |

### Troubleshooting

#### Pods stuck in Pending
* Possibility of resources not efficient. The instances in the worker group could be too small to assign IP addresses to all the pods

#### Workers not joining the cluster
* Ensure the workers are getting public IP addresses

#### Pods Crashing
* Run ```kubectl logs --previous -p jenkins-0 -c init``` to view the logs for the Jenkins init container. 

