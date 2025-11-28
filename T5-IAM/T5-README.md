# Task goals
- Create credential management managed service secret like dummy username + password
- Create IAM/RBAC Permissions that allow to read secret
- Attach Permissions to VM (through Role in AWS)
- SSH to VM
- Test Permissions by reading secret from cloud management CLI on VM.
- Inlude screenshot to task README.txt

# Problem
With the AWS sandbox environment, you cannot create IAM roles or users, nor can you attach policies to existing roles. 
You can't even read the policies attached to `LabRole`...    
- <img width="1241" height="68" alt="Screenshot 2025-11-28 at 21 27 45" src="https://github.com/user-attachments/assets/e8807c35-245e-4702-8f85-f6be69afa947" />
- <img width="1076" height="288" alt="Screenshot 2025-11-28 at 14 53 34" src="https://github.com/user-attachments/assets/454cfa48-069b-4dbb-893f-ba8d9647bf76" />
- <img width="1877" height="558" alt="Screenshot 2025-11-28 at 19 58 23" src="https://github.com/user-attachments/assets/fb06853a-2ac8-43e5-acf5-cdf7268cc5d4" />     

I also tried to attach role to Instance from terraform, but it didn't work.     
I then tried to import the role and attach it that way, didn't work...    

# BUT
I was able to create a secrets manager secret:
```
resource "aws_secretsmanager_secret" "secret" {
  name = "dummy-user"
}

# The secret (password) 
resource "aws_secretsmanager_secret_version" "v" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.secret)
}

variable "secret" {
  type = map(string)
  sensitive = true
  default = {
  user1 = "Password1!"
  }
}
```
- <img width="739" height="142" alt="Screenshot 2025-11-28 at 22 09 20" src="https://github.com/user-attachments/assets/d9b41ed3-48f2-4e38-b59c-69ec7023921d" />
- <img width="1639" height="676" alt="Screenshot 2025-11-28 at 22 12 37" src="https://github.com/user-attachments/assets/21e0f6e1-677b-4aab-8322-ef9188acaa7c" />


# Conclusion
The task was not possible to execute verbatum to instructions, but there was a small workaround, and it needs some manual operation.    
The whole "automation" part takes a big hit, but we do what we can.      

**Basically here's how it went down:**
- Now we have the secret, but no way of accessing it from the VM.
- **Step 1:** Stop the VM
  - <img width="118" height="51" alt="Screenshot 2025-11-28 at 22 47 48" src="https://github.com/user-attachments/assets/d650e259-bbd6-4653-805d-3f514661e733" />
- **Step 2:** Attach LabRole to VM
  - <img width="519" height="231" alt="Screenshot 2025-11-28 at 22 20 33" src="https://github.com/user-attachments/assets/b0b003b7-aee2-44c2-be6c-c4574480d05a" />
  - <img width="1105" height="432" alt="Screenshot 2025-11-28 at 22 20 59" src="https://github.com/user-attachments/assets/cb4a4965-d8af-46b9-9cec-0e1064b8f424" />
  - <img width="1662" height="342" alt="Screenshot 2025-11-28 at 22 48 06" src="https://github.com/user-attachments/assets/ea8ac2ff-4390-4bd9-baa7-431e3549fe53" />
  - Press `Update IAM role`
  - <img width="164" height="101" alt="Screenshot 2025-11-28 at 22 48 31" src="https://github.com/user-attachments/assets/a3ce8f00-a026-40f3-99bf-d8c87ab210fb" />
- **Step 3:** Spin it back up and download awscli with `sudo apt install -y awscli`
  - <img width="604" height="29" alt="Screenshot 2025-11-28 at 22 57 57" src="https://github.com/user-attachments/assets/f3b14027-6935-47e4-baf9-3176485f72a2" />
- **Step 4:** Quick sanity check that the role is properly attached
  - <img width="1015" height="150" alt="Screenshot 2025-11-28 at 22 54 19" src="https://github.com/user-attachments/assets/8c8d015f-f26a-43e2-a616-9bb2cd6371fc" />
- **Step 5:** Get the secret     

```bash
aws secretsmanager get-secret-value --secret-id dummy-user --region us-east-1 --query SecretString --output text
```
<img width="1087" height="75" alt="Screenshot 2025-11-28 at 23 04 48" src="https://github.com/user-attachments/assets/c2a3e2e3-dff9-4e0c-ad26-1365c9f6a6b9" />       


# Side note unrelated
The `main.tf` file was getting so big, so I decided to refactor it to a light version of a modular monolithic implementation.     
Each `*.tf` file serves its own distinct purpose from now on. This can also be seen in the main `terraform` folder!
