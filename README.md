# IaC deployment prepping

These preparatory tasks are part of the course: **Public Cloud Solution Architech**      
<https://pekkakorpi-tassi.fi/courses/pkt-arc/pkt-arc-edu-olt-2025-1e/iac_deployment.html>         
<br> 

Each **startswith("T")** file will give some insight into the specific task, but ultimately all code is stored in the `/terraform` folder! 

## How to deploy?     
> Copy the `/terraform` folder unto your machine of choice.   
> Paste your **AWS credentials** into `~/.aws/credentials`.
  > (For example: `$ nano ~/.aws/credentials` > paste > `Ctrl + X` to save and `y + enter` to confirm)
> Make sure you are within the folder! `$ cd <path-to-tf-folder>`.
> Initialize terraform `$ terraform init`.
> Once you're set, go ahead and deploy: `$ terraform apply`.
> Let terraform do its magic and enjoy!
