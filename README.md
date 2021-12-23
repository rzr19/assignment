# xxx
# This was tested with:
# ubuntu 20.04 LTS
# packer v1.7.8
# terraform v1.1.2


Step 0.
Define AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

```
export AWS_ACCESS_KEY_ID="foo"
export AWS_SECRET_ACCESS_KEY="bar"
```

Step 1.
Run packer
```
packer build xxxami.json.tpl
```

Step 2.
Run terraform
```
terraform init && terraform apply
```

Step 3.
Get the pip of the instance and check the http page
```
curl http://${pip}
```

Step 4.
Debug via ssh:
```
ssh ubuntu@${pip} -i key
```
