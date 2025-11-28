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
- <img width="1076" height="288" alt="Screenshot 2025-11-28 at 14 53 34" src="https://github.com/user-attachments/assets/454cfa48-069b-4dbb-893f-ba8d9647bf76" />
- <img width="1877" height="558" alt="Screenshot 2025-11-28 at 19 58 23" src="https://github.com/user-attachments/assets/fb06853a-2ac8-43e5-acf5-cdf7268cc5d4" />

So we had to work around this.     
I attached the `LabRole` to the EC2 instance, and just prayed it would be able to read the dummy credentials.
- <img width="718" height="439" alt="Screenshot 2025-11-28 at 15 08 40" src="https://github.com/user-attachments/assets/420ed84c-f220-47cd-bd04-c71459bc655e" />


