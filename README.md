# IaC deployment prepping

These preparatory tasks are part of the **course:** **Public Cloud Solution Architech** // *Assigment:* *Practical IaC Deployment*
> <https://pekkakorpi-tassi.fi/courses/pkt-arc/pkt-arc-edu-olt-2025-1e/iac_deployment.html>         
<br> 

Each file with the `"T" prefix` will provide some insight on the specificied task, but ultimately all code is stored in the `/terraform` folder!     

## How to deploy?     
- Copy the `/terraform` folder unto your machine of choice.
- Paste your **AWS credentials** into `~/.aws/credentials`.
  - (For example: `$ nano ~/.aws/credentials` > paste > `Ctrl + X` to save and `y + enter` to confirm)
- Make sure you are within the folder! `$ cd <path-to-tf-folder>`.      
  
**Initialize terraform**
```bash
$ terraform init
```
Once you're set, go ahead and **deploy:**
```bash
$ terraform apply
```
### Let terraform do its magic and enjoy!        

## Alternatively
You can copy the `*.tf` files from your folder of choice, and only deploy that specific setup!
