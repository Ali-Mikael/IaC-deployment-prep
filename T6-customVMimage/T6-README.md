# Task
<img width="795" height="395" alt="Screenshot 2025-11-16 at 15 57 25" src="https://github.com/user-attachments/assets/fe02df95-a670-4a81-b1f4-eb8868106a4f" />

# Note
I created this task as a standalone section for the purpose of creating custom AMIs (might as well treat this as a `dev vpc`).    
What do I mean "Standalone"?:
- New VPC (with different main vpc cidr)
- New everything else as well.
- I came to the conclusion it would be better to have this kind of setup for testing purposes etc.
- I will ofcourse apply the same functionality to the main template (with all the rest of the configs) as well!     

## Preparing VM
**Initialize && apply**
```
$ terraform init
```

```
$ terraform apply
```

**Log into your VM using the IP from the output**

```
$ ssh -i ~/.ssh/"key-name" ubuntu@"public-ip"
```

**Run the following commands**
```
$ sudo apt update && sudo apt upgrade -y
```

```
$ sudo apt install -y apache2 python3-flask mariadb-server
```
