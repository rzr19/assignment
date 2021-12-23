 {
 "builders": [{
    "type": "amazon-ebs",
    "access_key": "{{user `aws_access_key`}}",
    "secret_key": "{{user `aws_secret_key`}}",
    "region": "us-east-1",
    "source_ami_filter": {
      "filters": {
        "virtualization-type": "hvm",
        "name": "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*",
        "root-device-type": "ebs"
      },
      "owners": ["099720109477"],
      "most_recent": true
    },
    "tags": {
      "Name": "xxxami",
      "Description": "foo"
    },
    "instance_type": "t2.micro",
    "ssh_username": "ubuntu",
    "ami_name": "xxxami-{{timestamp}}",
    "ami_regions": ["us-east-1"]
  }],
  "provisioners": [
    {
      "type": "file",
      "source": "xxxami_init.sh",
      "destination": "/tmp/xxxami_init.sh"
    },
    {
      "type": "shell",
      "execute_command": "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'",
      "inline": [
	    "cd /tmp",
        "chmod +x /tmp/xxxami_init.sh",
        "./xxxami_init.sh"
      ]
    }
  ]
}
