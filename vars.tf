variable "AWS_REGION" {
  
  default = "us-east-1"

}

variable "AZ" {

  
}

#variable "AWS_ACCESS_KEY_ID" {

#}

#variable "AWS_SECRET_ACCESS_KEY" {

#}

#variable "AMI" {

#    default = {
#         us-east-1 = "ami-0be2609ba883822ec"
#    }

#}

variable "PATH_TO_PRIVATE_KEY" {
  default = "TerraformKey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "TerraformKey.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ec2-user"
}




