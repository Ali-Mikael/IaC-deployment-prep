# Task
Task goals:
- Find some application that can be tested with http protocol (80, no TLS).
- Some possible apps: Apache, Nginx, Lighttpd
- Prepare CLI commands to install application on VM
- Test public Internet access to prepared VM and include screenshot about passing test to task README.txt
- Create VM Image when setup is verified to work.
- Create VM from VM Image
- Test public Internet access to image based VM and include screenshot about passing test to task README.txt
- README.md contains instructions how to setup VM that is used to create VM Image.

# Note
I completed this task as a standalone section for the purpose of creating custom AMIs (might as well treat this as a `dev vpc`).    
What do I mean "Standalone"?:
- New VPC (with different main vpc cidr)
- New everything else as well.
- I came to the conclusion it would be better to have this kind of setup for testing purposes etc.
- I will ofcourse apply the same functionality to the main template (with all the rest of the configs) as well!      

Make sure you have this folder on your local machine, or navigate to the `/test` directory **within** the `/terraform` directory.       
Example location of `main.tf` file = `/terraform/test/main.tf`.     

## Preparing VM
**Initialize && apply**
```
$ terraform init
```

```
$ terraform apply
```
<img width="302" height="123" alt="Screenshot 2025-11-26 at 17 52 25" src="https://github.com/user-attachments/assets/aa8fbcd2-855d-4068-bafb-1abc3ccb5fe1" />      

**Side note:**
- For this to work, we have to have an external EBS storage device (which the template creates for us, you can see the code how it's done)
- <img width="1299" height="387" alt="Screenshot 2025-11-26 at 17 56 58" src="https://github.com/user-attachments/assets/d68f687c-776c-40f5-89d6-401c0db423e8" />
- <img width="731" height="374" alt="Screenshot 2025-11-26 at 17 57 20" src="https://github.com/user-attachments/assets/7d7a053b-aa99-4f67-a6a3-65cb1fe7d857" />       


**Log into your VM using the IP from the output**
```
$ ssh -i ~/.ssh/"key-name" ubuntu@"public-ip"
```
<img width="1031" height="126" alt="Screenshot 2025-11-26 at 17 54 54" src="https://github.com/user-attachments/assets/6ce0c97c-7a62-4695-aa73-0f5d3b5be50a" />        


**Run the following commands**
```
sudo apt update && sudo apt upgrade -y
```

```
sudo apt install -y apache2 python3-flask mariadb-server
```
<img width="950" height="97" alt="Screenshot 2025-11-26 at 19 47 34" src="https://github.com/user-attachments/assets/5d0c33d4-3408-4295-96db-5343d39e778e" />       
<img width="1039" height="255" alt="Screenshot 2025-11-26 at 19 48 11" src="https://github.com/user-attachments/assets/24c6066a-10bf-4b34-8c5f-ced0ee1b1a40" />     
<br> 

**Enabling and starting apache**
```
sudo systemctl enable apache2
```
```
sudo systemctl start apache2
```
<img width="1032" height="212" alt="Screenshot 2025-11-26 at 20 52 19" src="https://github.com/user-attachments/assets/911aae7f-ce6d-4048-8b08-501675132a51" />      

**Test that it works**
<img width="803" height="581" alt="Screenshot 2025-11-26 at 20 06 26" src="https://github.com/user-attachments/assets/ccb8fded-48b4-4946-92fc-9b838953ff74" />     
We're able to access the page using the instance public IP. We can now move on to creating the AMI.       

## Creating AMI
- <img width="1209" height="464" alt="Screenshot 2025-11-26 at 19 50 34" src="https://github.com/user-attachments/assets/7294a141-7853-4b44-8674-51408723b6a9" />
- <img width="1152" height="454" alt="Screenshot 2025-11-26 at 19 50 58" src="https://github.com/user-attachments/assets/da018416-8ec1-439b-ba7a-7754dc0ebf4a" />
```
$ terraform apply
```
- <img width="847" height="179" alt="Screenshot 2025-11-26 at 20 13 58" src="https://github.com/user-attachments/assets/bd3dc08e-6ab7-496a-9a12-338f807a23a1" />
- <img width="1460" height="174" alt="Screenshot 2025-11-26 at 20 14 25" src="https://github.com/user-attachments/assets/76d8ec55-e8b8-457d-9262-68c1c69459ca" />
- <img width="693" height="370" alt="Screenshot 2025-11-26 at 20 15 27" src="https://github.com/user-attachments/assets/76c8bbbd-4ed3-41da-a589-e646a54e7ef6" />    

Now that we have the AMI. We can crate a new VM using it.

# New VM from custom AMI
- Uncomment the following section for creating the the VM
- <img width="892" height="452" alt="Screenshot 2025-11-26 at 20 15 49" src="https://github.com/user-attachments/assets/39b76be1-26f6-4f17-b213-ee8faf1833e3" />
```
$ terraform apply
```
- <img width="995" height="221" alt="Screenshot 2025-11-26 at 20 21 10" src="https://github.com/user-attachments/assets/e410b041-2572-4176-8702-13c21a4e11f7" />
- <img width="924" height="452" alt="Screenshot 2025-11-26 at 20 22 29" src="https://github.com/user-attachments/assets/39b51bc3-59a2-4838-968b-c3e7d82f3ed0" />
- Forgot to add the output lol.
- Add it and `$ terraform apply`.
- <img width="606" height="118" alt="Screenshot 2025-11-26 at 20 24 16" src="https://github.com/user-attachments/assets/38fc652b-6ad8-4722-99e5-0770cf88de45" />
  - Had to come up with a unique name for the output. `cami` stands for `Custom AMI Instance` in this case. You can name it whatever you like.
- <img width="716" height="178" alt="Screenshot 2025-11-26 at 20 24 27" src="https://github.com/user-attachments/assets/888241e9-32b9-42ea-bc4d-0cb416a26502" />
- You don't even have to log in to the instance, as we already enabled apache before creating the AMI.
- Just copy the public IP from the output and paste it to your browser.
- <img width="1000" height="721" alt="Screenshot 2025-11-26 at 20 25 31" src="https://github.com/user-attachments/assets/506c87ae-2dca-479a-9307-7d8484bad6fb" />
- Last check before tf destroying it all
- <img width="869" height="260" alt="Screenshot 2025-11-26 at 20 26 04" src="https://github.com/user-attachments/assets/56584759-6f67-4a00-97db-ca77d16bef7f" />


















