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

So we had to work around this.     

