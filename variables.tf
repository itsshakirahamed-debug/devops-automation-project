variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "key_name" {
  description = "Name of your AWS EC2 Key Pair in ap-southeast-2 (leave blank '' if no SSH key pair exists)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}
