provider "cloudinit" {}


data "template_file" "shell-script" {
  template = file("scripts/shellscript.sh")
}

data "template_cloudinit_config" "cloudinit-example" {
  gzip          = false
  base64_encode = false

  part {
    filename = "shell-script"
    content_type = "text/x-shellscript"
    content  = data.template_file.shell-script.rendered
  }
}

