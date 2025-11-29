# Task goals
- Use CLI commands to install application on VM from previous task
- Update VM creation script, to run app install CLI commands as user data
- Test public Internet access to VM and include screenshot about passing test to task README.txt
- README.md contains instructions how to deploy IaC templating.

# Setup
In the last task we installed applications manually, this time we are going to provision the VM using `user_data`.

We have a `init-script.sh` file inside `/terraform/files/`. Which we are referencing in our configuration.     

## The script
Looks like the following:
```sh
#!/bin/bash

apt update && apt updgrade -y

apt install -y apache2 python3-flask mariadb-server

systemctl enable apache2

echo "<h1> -*- Hello from VM1! -*- </h1>" > /var/www/html/index.html

systemctl start apache2
```

## And the config:
```hcl
  # config redacted for brevity #
  user_data                   = file("./files/init-script.sh")
  # If user_data changes, tf will create a new VM and destroy old one
  user_data_replace_on_change = true

  tags = {
    Name = "VM-1"
  }
}
```

# tf apply
When we apply the whole thing, we just get the IP from the output:
- <img width="306" height="121" alt="Screenshot 2025-11-29 at 17 37 50" src="https://github.com/user-attachments/assets/2cd248d3-0e7a-4553-b4c8-131927d26c66" />     

Now we don't even have to SSH into the VM. We can just paste the IP in our browser to **confirm that it worked**.     
Like so:
- <img width="819" height="232" alt="Screenshot 2025-11-29 at 17 40 32" src="https://github.com/user-attachments/assets/a633ca72-fd03-4f2b-8a61-05707b74cfec" />     

But if that isn't enough:
- <img width="1150" height="29" alt="Screenshot 2025-11-29 at 18 05 40" src="https://github.com/user-attachments/assets/24fefdc4-8dac-4859-a954-642286bec88a" />
- <img width="1170" height="269" alt="Screenshot 2025-11-29 at 18 06 39" src="https://github.com/user-attachments/assets/ae233942-1313-468d-8a1f-8853c3ab25a1" />     


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
