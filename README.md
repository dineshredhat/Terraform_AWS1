Deploying Cloud Architecture in AWS with Terraform
I deployed a cloud architecture in the AWS Cloud. The main services I used was :- EC2 VPC RDS Subnet Internet Gateway Bastion Host Route Tables Nat Gateway

All these implementation was done with terraform code.

Terraform Code to :
Launch VMs, One in the public subnet(1-web server with 1- bastion host) and One in the private subnet(1- database server)
Attach a NAT gateway to a private subnet





![image](https://user-images.githubusercontent.com/109305854/190623314-29446bbd-3c21-40d2-9550-98de5761cd5e.png)
