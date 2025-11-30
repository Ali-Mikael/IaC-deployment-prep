# Task goals
- setup VM automated backups and lifecycle rules
- README.md contains instructions how to deploy IaC templating.     

# Changes
In order to create backups, we need an EBS volume for the instance.    

**I made two changes:**
1. Added a filter to our data source for the AMI
2. Configured the instance so that it uses an EBS volume as root volume     


**1. The data source:**
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  region      = var.aws_region

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  # This one right here -->
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
```
The filter makes sure that the `Root device type` is => `EBS`     

**2. The** `root_block_device` **block:**
```hcl
resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type

  # config redacted for brevity #

  # This one right here -->
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name   = "vm1-root-volume"
      Backup = "Daily"
    }
  }
}
```

## Apply
- <img width="968" height="155" alt="Screenshot 2025-11-29 at 21 13 55" src="https://github.com/user-attachments/assets/52a76695-0bd7-4aac-a90a-b867621bd399" />
- <img width="708" height="488" alt="Screenshot 2025-11-29 at 21 13 28" src="https://github.com/user-attachments/assets/dfadd179-7c7e-40b8-88ec-abbf0639a1f7" />
- <img width="750" height="133" alt="Screenshot 2025-11-29 at 21 14 18" src="https://github.com/user-attachments/assets/6e306e9e-141c-4b8b-a97a-e2b8bb53c154" />
- <img width="959" height="336" alt="Screenshot 2025-11-29 at 21 16 41" src="https://github.com/user-attachments/assets/ccf37a13-ef6c-49a0-b501-e38be5faecc2" />    

The VM can now be backed up!     


# Backups
We'll first apply this:
- <img width="724" height="798" alt="Screenshot 2025-11-29 at 21 37 26" src="https://github.com/user-attachments/assets/ad82c82a-690b-461d-9adf-cc6122b93be0" />
- <img width="191" height="35" alt="Screenshot 2025-11-29 at 21 37 05" src="https://github.com/user-attachments/assets/451815c7-7d29-4b9e-abb5-432a75ac446d" />
- In the AWS console you can navigate to the -> `AWS Backup` page to check out what we created
- The `vaults` section (from the menu on the left):
  - <img width="867" height="608" alt="Screenshot 2025-11-29 at 21 40 23" src="https://github.com/user-attachments/assets/5f1b6cc6-4ad1-429a-9671-5e119cf17258" />
- And then the `Backup plans` section (from the menu on the left)
  - <img width="523" height="375" alt="Screenshot 2025-11-29 at 21 40 58" src="https://github.com/user-attachments/assets/5662e82b-7aa6-4ca8-aed3-6cc466537b47" />
  - <img width="1607" height="390" alt="Screenshot 2025-11-29 at 21 41 25" src="https://github.com/user-attachments/assets/f2c4f2a8-baa8-42a5-b91f-128f94e8cda5" />    

We have one `backup rule`:
  - **Backups** area taken between 10-12 **every day**.
  - **Start time** is 10am and has to be completed within 2 hours.
  - **Retention period** for the backup is **2 weeks**.

### Now we just need the target (the commented out section you saw)
```hcl
# Selecting resource to back up
resource "aws_backup_selection" "myselection" {
  iam_role_arn = data.aws_iam_role.lab_role.arn
  name         = "ec2-backup-selection"
  plan_id      = aws_backup_plan.ec2_backup.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "Daily"
  }
}
```

I left this for last, as I had some problems with IAM before (only the sandbox environment i'm with working tho, if you have a normal account, feel free to apply the whole thing at once).          
The thing here is, you have to assign the service a role, so it can create backups of your resources.     

### Uncomment --> terraform apply --> pray

# Result:
- <img width="1231" height="140" alt="Screenshot 2025-11-29 at 21 50 48" src="https://github.com/user-attachments/assets/479057a2-2354-483e-8d47-d1c4f7fca228" />     

And from the console, we can now see that a target has been created:
- <img width="727" height="215" alt="Screenshot 2025-11-29 at 21 52 23" src="https://github.com/user-attachments/assets/4d4a8fbd-b121-455f-8ef7-471f1afb3c11" />
- <img width="368" height="312" alt="Screenshot 2025-11-29 at 21 54 01" src="https://github.com/user-attachments/assets/93298b80-3934-48f9-82a4-1048c70c3d1f" />     

Because of the tags in our EC2 instance config (`root_block_device` block):
- <img width="416" height="280" alt="Screenshot 2025-11-29 at 21 54 31" src="https://github.com/user-attachments/assets/1faefdbb-2d07-4aee-a391-b75a65b07acc" />
- The service is able to locate it.
- This is especially useful, as you can add/modify tags to create more fine grained backup operations!     

Scroll down to the end of the page for confirmation.


## Note: To whom it may concern
Remember to configure your IAM stuff properly if you end up using this yourself!     

# Deploying
You can either copy the `*.tf` files in this folder to your machine of choice, navigate into the folder, and initialise terraform from there:
```bash
$ terraform init
```
And then apply (to create resources):
```bash
$ terraform apply
```
This will effectively **only** create resources that are *specified in this folder*.       

## OR
You can **download** the main `/terraform` **folder** to your computer **locally** **-->** **navigate to the folder** **-->** and **execute the same steps:** to provision the whole infra in one go! 


# Update a day later
Confirmation that it works:
- <img width="1601" height="351" alt="Screenshot 2025-11-30 at 16 28 19" src="https://github.com/user-attachments/assets/73a154d0-ee0f-4a4f-afab-d2ddadd67a6b" />
- <img width="1595" height="425" alt="Screenshot 2025-11-30 at 18 34 38" src="https://github.com/user-attachments/assets/6b220e16-7236-4e76-8897-deb3708da4cc" />
