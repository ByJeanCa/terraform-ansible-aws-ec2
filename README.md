# terraform-ansible-aws-ec2
Infrastructure as code to provision an EC2 instance with Terraform and configure NGINX with Ansible.
The goal is to launch a VM on AWS and have it serving a page via HTTP in just a few commands.

# #🧱 Architecture

* AWS EC2: 1 public instance (t2.micro by default).
* Security Group: allows SSH (22) and HTTP (80) from the Internet.
* Ansible: setup_nginx role to install and configure NGINX.
* Inventory: simple static (file) to point to the created EC2.

# # 📦 Project structure.
├─ infrastructure/           Terraform files (VPC/SG/EC2/outputs/vars)  
├─ inventory/                Inventory for Ansible (hosts.ini, group_vars, etc.)  
├─ roles/  
│  └─ setup_nginx/           Ansible role to install and configure NGINX  
├─ setup_nginx.yml           Main playbook  
├─ .gitignore  
└─ README.md


# # ✅ Requirements
* AWS CLI configured with valid credentials (aws configure)
* Terraform ≥ 1.5
* Ansible ≥ 2.14
* Existing SSH key pair in your AWS account (or create a new one)

## 🔧 Key variables (Terraform)
Edit infrastructure/terraform.tfvars (or export as environment variables) with something like:  
region         = “us-east-1”  
instance_type  = “t2.micro”  
key_name       = “my-keypair”           # Must exist in AWS  
public_key_path  = “~/.ssh/id_rsa.pub”  # Optional if you create the keypair from TF  
private_key_path = “~/.ssh/id_rsa”      # Used by Ansible/local SSH

> If the key pair already exists in AWS and Terraform attempts to import it again, you will see the error InvalidKeyPair.Duplicate. In that case, use the exact same key_name and avoid creating the key pair resource in Terraform.

## 🚀 Deployment

1. Provision the infrastructure
`cd infrastructure`
`terraform init`
`terraform plan`
`terraform apply -auto-approve`

2. Get the public IP

`terraform output -raw public_ip
`  
3. Update the Ansible inventory
Open inventory/hosts.ini and add the IP:

`[nginx]  
<PUBLIC_IP_EC2> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa`
* For Ubuntu, use ansible_user=ubuntu.
* For Amazon Linux, use ansible_user=ec2-user.

4. Run the playbook

`ansible -i inventory/hosts.ini all -m ping
` 
`ansible-playbook -i inventory/hosts.ini setup_nginx.yml
`

5. Verify
`curl http://<PUBLIC_EC2_IP> -I`

# Should respond with “HTTP/1.1 200 OK”

## 🧪 What does the setup_nginx role do?
* Install NGINX
* Enable and start the service
* (Optional) Deploy a base index.html
> Check roles/setup_nginx/ to customize templates, handlers, or tasks.

## 🧹 Destruction
When you are finished, delete the infrastructure to avoid generating costs:

`cd infrastructure
`
`terraform destroy -auto-approve
`
## 🛟 Troubleshooting
1. `InvalidKeyPair.Duplicate
`
A keypair with that name already exists in your account. Adjust key_name or delete the resource that is trying to recreate it.

2. No SSH connection / timeout
  * Verify zhat the Security Group allows port 22 from your IP.
  * Confirm the correct ansible_user (ubuntu vs ec2-user).
  * Check the path of ansible_ssh_private_key_file.

3. NGINX not responding
  * Ensure that port 80 is allowed in the SG.
  * sudo systemctl status nginx on the instance to view logs.

## 🔐 Security notes

* Limit SSH access by IP (instead of 0.0.0.0/0) when possible.
* Do not upload private keys to the repo.
* Consider remote backend (S3 + DynamoDB) for Terraform status on computers.

$$ 🗺️ Roadmap (ideas)
Author: @ByJeanCa — any PR or issue is welcome ✌️
