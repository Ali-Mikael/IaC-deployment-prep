# Task goals
- Create and configure Public Object Storage container
- Create and configure Protected Object Storage container
- Upload test files to Public container by using CLI
- Upload test files to Protected container by using CLI
- Include screenshots about Public and Protected containers with test files to task README.txt




## main.tf
```hcl
# Bucket creation
resource "aws_s3_bucket" "b" {
  for_each = local.buckets

  bucket = each.value

  tags = {
    Name = "${each.key}-bucket"
  }
}

# ---- configs redacted for brevity -----
# ----- (check .tf files for more) ------

# Effectively making the public bucket -> Public
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.b["public"].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```


# Deploying
You can either copy the `*.tf` files in this folder to your machine of choice, navigate into the folder, initialise terraform from there:
```
$ terraform init
```
And then apply (to create resources):
```
$ terraform apply
```
This will effectively **only** create resources that are specified in this folder.       

## OR
You can **download** the main `/terraform` **folder** to your computer **locally** **-->** **navigate to the folder** **-->** and **execute the same steps:** to provision the whole infra in one go!
