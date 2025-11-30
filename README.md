# IaC deployment prepping

These preparatory tasks are part of the **course:** **Public Cloud Solution Architech** // *Assigment:* *Practical IaC Deployment*
> <https://pekkakorpi-tassi.fi/courses/pkt-arc/pkt-arc-edu-olt-2025-1e/iac_deployment.html>         
<br> 

Each task is contained inside a folder with the `"T" prefix`, but ultimately all code is stored in the `/terraform` folder!     

## How to deploy?     
- Download Terraform.
  - Instructions here: <https://developer.hashicorp.com/terraform/install>
- Download AWS CLI.
  - Instructions here: <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>
- Download git repo.
```bash
git clone https://github.com/Ali-Mikael/IaC-deployment-prep
```
- Navigate to the `/terraform` directory.
- Paste your **AWS credentials** into `~/.aws/credentials`.
  - (For example: `$ nano ~/.aws/credentials` > paste > `Ctrl + X` to save and `y + enter` to confirm)
- Make sure you are within the folder! `$ pwd`      
  
**Initialize terraform**
```bash
terraform init
```
Once you're set, go ahead and **deploy:**
```bash
terraform apply
```
### Let terraform do its magic and enjoy!        

## Alternatively
You can copy the `*.tf` files from your folder of choice, and only deploy that specific setup!     
(See folder specific `T*-README.md` for more)
