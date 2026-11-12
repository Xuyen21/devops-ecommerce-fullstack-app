variable "domain_name" {
  description = "The custom (sub)domain name for the frontend"
  type        = string
}

variable "origin_id" {
  description = "The origin ID for the CloudFront distribution"
  type        = string
  default     = "random-origin-id"
}