data "aws_ami" "AmazonLinuxAMI2" {

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a VPC
resource "aws_vpc" "my_first_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Terraform_VPC"
  }

}

resource "aws_subnet" "my_first_subnet" {
  vpc_id            = aws_vpc.my_first_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.AZ[0]
  map_public_ip_on_launch = true


  tags = {
    Name = "Terraform_Subnet"
  }
}

resource "aws_subnet" "my_first_private_subnet" {
  vpc_id            = aws_vpc.my_first_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.AZ[0]
  tags = {
    Name = "Terraform_First_Private_Subnet"
  }
}

resource "aws_subnet" "my_second_private_subnet" {
  vpc_id            = aws_vpc.my_first_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.AZ[1]


  tags = {
    Name = "Terraform_Second_Private_Subnet"
  }
}

resource "aws_internet_gateway" "my_first_internet_gateway" {
  vpc_id = aws_vpc.my_first_vpc.id

  tags = {
    Name = "Terraform_Internet_Gateway"
  }
}


resource "aws_route_table" "my_first_route_table" {
  vpc_id = aws_vpc.my_first_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_first_internet_gateway.id
  }

  tags = {
    Name = "Terraform_Route_Table"
  }
}

resource "aws_route_table" "my_first_private_route_table" {
  vpc_id = aws_vpc.my_first_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "Terraform_Private_Route_Table"
   }
  
}


resource "aws_route_table_association" "my_route_association" {
  subnet_id      = aws_subnet.my_first_subnet.id
  route_table_id = aws_route_table.my_first_route_table.id
}

resource "aws_route_table_association" "my_private_route_association" {
  subnet_id      = aws_subnet.my_first_private_subnet.id
  route_table_id = aws_route_table.my_first_private_route_table.id
}

resource "aws_route_table_association" "my_private_route_association2" {
  subnet_id      = aws_subnet.my_second_private_subnet.id
  route_table_id = aws_route_table.my_first_private_route_table.id
}


resource "aws_security_group" "my_first_SG" {
  name        = "Terraform_SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_first_vpc.id
}

resource "aws_security_group" "my_first_Private_SG" {
  name        = "Terraform_Private_SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_first_vpc.id
}


resource "aws_security_group_rule" "sec_group_allow_tcp" {
  type              = "ingress"
  from_port         = 22 // first part of port range 
  to_port           = 22 // second part of port range
  protocol          = "tcp" // Protocol, could be "tcp" "udp" etc. 
  security_group_id = aws_security_group.my_first_SG.id // Which group to attach it to
  source_security_group_id = aws_security_group.my_first_Private_SG.id // Which group to specify as source
}

resource "aws_security_group_rule" "sec_egress_group_allow_tcp" {
  type              = "egress"
  from_port         = 0 // first part of port range 
  to_port           = 0 // second part of port range
  protocol          = "-1" // Protocol, could be "tcp" "udp" etc. 
  security_group_id = aws_security_group.my_first_SG.id // Which group to attach it to
  cidr_blocks = ["0.0.0.0/0"] // Which group to specify as source
}

resource "aws_security_group_rule" "sec_egress_group_allow_tcp2" {
  type              = "egress"
  from_port         = 0 // first part of port range 
  to_port           = 0 // second part of port range
  protocol          = "-1" // Protocol, could be "tcp" "udp" etc. 
  security_group_id = aws_security_group.my_first_Private_SG.id  // Which group to attach it to
  cidr_blocks = ["0.0.0.0/0"] // Which group to specify as source
}

resource "aws_security_group_rule" "sec_group_allow_tcp1" {
  type              = "ingress"
  from_port         = 80 // first part of port range 
  to_port           = 80 // second part of port range
  protocol          = "tcp" // Protocol, could be "tcp" "udp" etc. 
  security_group_id = aws_security_group.my_first_SG.id // Which group to attach it to
  cidr_blocks = ["68.203.81.187/32"] // Which group to specify as source
}

resource "aws_security_group_rule" "sec_group_allow_tcp2" {
  type              = "ingress"
  from_port         = 80 // first part of port range 
  to_port           = 80 // second part of port range
  protocol          = "tcp" // Protocol, could be "tcp" "udp" etc. 
  security_group_id = aws_security_group.my_first_Private_SG.id // Which group to attach it to
  source_security_group_id =  aws_security_group.my_first_SG.id // Which group to specify as source
}


resource "aws_network_interface" "my_nic" {
  subnet_id       = aws_subnet.my_first_private_subnet.id
  private_ips     = ["10.0.2.50"]
}

resource "aws_network_interface" "my_nic2" {
  subnet_id       = aws_subnet.my_second_private_subnet.id
  private_ips     = ["10.0.3.51"]
}

resource "aws_network_interface" "my_nic0" {
  subnet_id       = aws_subnet.my_first_subnet.id
  private_ips     = ["10.0.1.51"]
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.my_first_SG.id
  network_interface_id = aws_network_interface.my_nic0.id
}

resource "aws_network_interface_sg_attachment" "sg_attachment1" {
  security_group_id    = aws_security_group.my_first_Private_SG.id
  network_interface_id = aws_network_interface.my_nic2.id
}

resource "aws_network_interface_sg_attachment" "sg_attachment2" {
  security_group_id    = aws_security_group.my_first_Private_SG.id
  network_interface_id = aws_network_interface.my_nic.id
}


resource "aws_key_pair" "mykey" {
  key_name   = "TerraformAccess"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}


#resource "aws_eip_association" "eip_assoc" {
  #instance_id   = aws_instance.my_first_instance.id
  #allocation_id = aws_eip.ElasticIp.id
#

resource "aws_instance" "jump_box" {
  ami           = data.aws_ami.AmazonLinuxAMI2.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name

  network_interface {
    network_interface_id = aws_network_interface.my_nic0.id
    device_index         = 0
  }

  tags = {
    Name = "Terraform_Public__Instance"
  }
}

resource "aws_instance" "my_first_instance" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name

  network_interface {
    network_interface_id = aws_network_interface.my_nic.id
    device_index         = 0
  }

  tags = {
    Name = "Terraform_Instance"
  }
  #provisioner "file" {
    #source      = "shellscript.sh"
    #destination = "/tmp/shellscript.sh"
  #}


  #provisioner "remote-exec" {
    #inline = [
    #"chmod +x /tmp/shellscript.sh",
    #"sudo sed -i -e 's/\r$//' /tmp/shellscript.sh", # Remove the spurious CR characters.
    #"sudo /tmp/shellscript.sh",
    #]
  #}

  # This command does not work when executed from windows laptop 
  # provisioner "local-exec"{

  #   command = "echo aws_instance.my_first_instance.private_ip >> private_ips.txt"
  # }

  #user_data = data.template_cloudinit_config.cloudinit-example.rendered
  #connection {
    #host        = coalesce(self.public_ip, self.private_ip)
    #type        = "ssh"
    #user        = var.INSTANCE_USERNAME
    #private_key = file(var.PATH_TO_PRIVATE_KEY)
  #}
}

resource "aws_instance" "my_second_instance" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name

  network_interface {
    network_interface_id = aws_network_interface.my_nic2.id
    device_index         = 0
  }

  tags = {
    Name = "Terraform_Instance"
  }
  #provisioner "file" {
    #source      = "shellscript.sh"
    #destination = "/tmp/shellscript.sh"
  #}


  #provisioner "remote-exec" {
    #inline = [
    #"chmod +x /tmp/shellscript.sh",
    #"sudo sed -i -e 's/\r$//' /tmp/shellscript.sh", # Remove the spurious CR characters.
    #"sudo /tmp/shellscript.sh",
    #]
  #}

  # This command does not work when executed from windows laptop 
  # provisioner "local-exec"{

  #   command = "echo aws_instance.my_first_instance.private_ip >> private_ips.txt"
  # }

  #user_data = data.template_cloudinit_config.cloudinit-example.rendered
  #connection {
    #host        = coalesce(self.public_ip, self.private_ip)
    #type        = "ssh"
    #user        = var.INSTANCE_USERNAME
    #private_key = file(var.PATH_TO_PRIVATE_KEY)
  #}


}
resource "aws_eip" "nat" {
  vpc = true
  depends_on = [aws_internet_gateway.my_first_internet_gateway]
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.my_first_subnet.id
}


resource "aws_elb" "elb" {
  name = "terraform-elb"
  subnets = [aws_subnet.my_first_subnet.id , aws_subnet.my_second_private_subnet.id]
  security_groups = [aws_security_group.my_first_SG.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 5
  }
  instances                   = [aws_instance.my_first_instance.id,aws_instance.my_second_instance.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = "terraform-elb"
  }

}