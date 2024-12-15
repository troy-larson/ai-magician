variable "do_api_token" {
  type        = string
  description = "DigitalOcean API Token"
}

variable "region" {
  type        = string
  default     = "nyc3"
  description = "DigitalOcean region to deploy in"
}

variable "image" {
  type        = string
  default     = "ubuntu-22-04-x64"
  description = "Base image for the Droplet"
}

variable "droplet_size" {
  type        = string
  default     = "s-1vcpu-1gb"
  description = "Size of the Droplet"
}

variable "ssh_username" {
  type        = string
  default     = "root"
  description = "SSH username for the Droplet"
}
