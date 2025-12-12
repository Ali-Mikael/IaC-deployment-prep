# Task goals
- Draw solution architecture diagram for your deployment.
- Diagram must be as complete as possible, as it was for production.
- Note that the actual IaC deployment does not need to be production ready (no custom Domain etc.).
- Include as annotations all DNS, IP, TLS, Port and other critical details.
- Use diagram tool like: draw.io, Lucidchart, etc.
- Use AWS/Azure calculator to estimate costs.      



# CI/CD platform
The [deployment](https://github.com/Ali-Mikael/C2ID) <-- repo.     


![Architectural Diagram](https://github.com/user-attachments/assets/7bdf6ff1-3504-422a-a67d-1dbcb95e018e)


# What does it cost?
Terraform manages just under a 100 resources (not even latest picture):          
<img width="499" height="301" alt="Screenshot 2025-12-12 at 3 12 26" src="https://github.com/user-attachments/assets/c2eb2ea3-7df9-4afe-adc3-fb544263f64d" />     
AWS Dashboard:     
<img width="190" height="62" alt="Screenshot 2025-12-12 at 23 21 22" src="https://github.com/user-attachments/assets/a0ded196-8614-4fd5-b745-389a3055ddd6" />      


We have implemented a **highly available environment**, using **redundancy** and **load balancing**, with best practices in mind like Redis caching and S3 storage for repositories and artefacts (not implemented fully here though, as it would require a lot of configuration management, which is outside the scope of this course, PLUS the IAM restrictions make it a lot more difficult, somewhere even impossible to setup proper connections).      
Anyway, at full speed ahead, with daily users and moderate traffic, I would estimate a monthly cost of **50$ - 100$**.     
The AWS sandbox environment which we used for this project, **denies access to the cost calculator**, or any service like it for that matter. But based on my own usage, plus the small crumb of information AWS does give in the console:     
<img width="222" height="201" alt="Screenshot 2025-12-12 at 23 26 46" src="https://github.com/user-attachments/assets/0ef882ca-53c6-44aa-9df7-d8ac0ee39a77" />     
We can easily double the amount we see on the picture, and pick a "baseline" from there!
