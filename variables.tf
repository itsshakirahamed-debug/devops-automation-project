variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "key_name" {
  description = "Name of your AWS EC2 Key Pair (create this in AWS EC2 Console in ap-southeast-2 before running)"
  type        = string
  default     = "webserver-key"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}
